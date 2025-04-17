import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/models/schedule.dart';
import 'package:encite/models/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ScheduleService {
  static const String apiUrl =
      'https://encite-mvp-backend.onrender.com/generate_schedule';

  // Generate a new schedule using the backend API
  Future<Schedule?> generateSchedule(Map<String, dynamic> userData) async {
    try {
      // Print data for debugging
      print('Generating schedule with data: ${jsonEncode(userData)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        // Decode the response body
        final decoded = jsonDecode(response.body);
        print('Received schedule response: ${response.body}');

        // Check if we have activities
        if (decoded['activities'] == null ||
            (decoded['activities'] as List).isEmpty) {
          print('Response contained no activities');
          return null;
        }

        // Build the Schedule object - using existing model structure
        return Schedule(
          id: decoded['id'] ?? 'schedule_${const Uuid().v4().substring(0, 8)}',
          createdAt: DateTime.parse(decoded['createdAt']),
          activities: (decoded['activities'] as List).map((activityJson) {
            // Save explanation in a separate Firebase document if needed
            String? explanation = activityJson['explanation'];
            if (explanation != null && explanation.isNotEmpty) {
              _saveActivityExplanation(activityJson['id'], explanation);
            }

            return Activity(
              id: activityJson['id'],
              title: activityJson['title'],
              description: activityJson['description'],
              startTime: DateTime.parse(activityJson['startTime']),
              endTime: DateTime.parse(activityJson['endTime']),
              price: (activityJson['price'] as num).toDouble(),
              imageUrl: activityJson['imageUrl'],
            );
          }).toList(),
        );
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating schedule: $e');
      return null;
    }
  }

  // Temporarily store explanations in a separate collection
  Future<void> _saveActivityExplanation(
      String activityId, String explanation) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('activity_explanations')
            .doc(activityId)
            .set({
          'activityId': activityId,
          'explanation': explanation,
          'userId': uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving explanation: $e');
    }
  }

  // Get explanation for an activity
  Future<String?> getActivityExplanation(String activityId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('activity_explanations')
          .doc(activityId)
          .get();

      if (doc.exists) {
        return doc.data()?['explanation'];
      }
      return null;
    } catch (e) {
      print('Error getting explanation: $e');
      return null;
    }
  }

  // Request a substitute activity for a specific activity in the schedule
  Future<Activity?> requestSubstituteActivity(
      String activityId, Schedule schedule) async {
    try {
      // Create payload for substitute request
      final activityToReplace = schedule.activities.firstWhere(
        (a) => a.id == activityId,
        orElse: () => schedule.activities.first,
      );

      final substitutionRequest = {
        'replace_activity': {
          'id': activityToReplace.id,
          'start_time': activityToReplace.startTime.toIso8601String(),
          'end_time': activityToReplace.endTime.toIso8601String(),
        },
        'existing_activities': schedule.activities
            .where((a) => a.id != activityId)
            .map((a) => {
                  'id': a.id,
                  'title': a.title,
                  'startTime': a.startTime.toIso8601String(),
                  'endTime': a.endTime.toIso8601String(),
                })
            .toList(),
      };

      // Send request to substitution endpoint
      final response = await http.post(
        Uri.parse('$apiUrl/substitute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(substitutionRequest),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final activityJson = decoded['activity'];

        if (activityJson != null) {
          // Save explanation separately if it exists
          String? explanation = activityJson['explanation'];
          if (explanation != null && explanation.isNotEmpty) {
            _saveActivityExplanation(activityJson['id'], explanation);
          }

          return Activity(
            id: activityJson['id'] ??
                'activity_${const Uuid().v4().substring(0, 8)}',
            title: activityJson['title'],
            description: activityJson['description'],
            startTime: DateTime.parse(activityJson['startTime']),
            endTime: DateTime.parse(activityJson['endTime']),
            price: (activityJson['price'] as num).toDouble(),
            imageUrl: activityJson['imageUrl'],
          );
        }
      }

      // If the API isn't available yet or returns an error, fallback to a mock
      return _generateMockSubstitute(activityId, schedule);
    } catch (e) {
      print('Error requesting substitute: $e');
      // Fallback to a mock implementation
      return _generateMockSubstitute(activityId, schedule);
    }
  }

  // Generate a mock substitute activity (temporary until API endpoint is ready)
  Activity _generateMockSubstitute(String activityId, Schedule schedule) {
    // Find the activity to replace
    final originalActivity = schedule.activities.firstWhere(
      (a) => a.id == activityId,
      orElse: () => schedule.activities.first,
    );

    // List of alternative titles
    final alternativeTitles = [
      'Alternative ${originalActivity.title.split(' ').last}',
      'Different ${originalActivity.title.split(' ').last}',
      'New ${originalActivity.title.split(' ').last} Experience',
      'Exciting ${originalActivity.title.split(' ').last}',
    ];

    // Random select a title
    final title = alternativeTitles[
        DateTime.now().millisecond % alternativeTitles.length];
    final newId = 'substitute_${const Uuid().v4().substring(0, 8)}';

    // Save a mock explanation
    _saveActivityExplanation(newId,
        'AI-suggested alternative that fits within your schedule timeframe.');

    // Create a substitute with same time slot but different details
    return Activity(
      id: newId,
      title: title,
      description:
          'This is an alternative activity suggested by our AI based on your preferences.',
      startTime: originalActivity.startTime,
      endTime: originalActivity.endTime,
      price: originalActivity.price * 0.9, // Slightly cheaper alternative
      imageUrl:
          'https://picsum.photos/200?random=${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // Save schedule to Firestore
  Future<void> saveSchedule(Schedule schedule) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    // Reference to the user's schedules collection
    final schedulesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('schedules')
        .doc(schedule.id);

    // Save the schedule
    await schedulesRef.set({
      'id': schedule.id,
      'createdAt': schedule.createdAt.toIso8601String(),
      'totalCost': schedule.totalCost,
      'startTime': schedule.startTime.toIso8601String(),
      'endTime': schedule.endTime.toIso8601String(),
      'activities': schedule.activities
          .map((a) => {
                'id': a.id,
                'title': a.title,
                'description': a.description,
                'startTime': a.startTime.toIso8601String(),
                'endTime': a.endTime.toIso8601String(),
                'price': a.price,
                'imageUrl': a.imageUrl,
              })
          .toList(),
    });

    print('Schedule saved to Firestore: ${schedule.id}');
  }

  // Get all user schedules from Firestore
  Future<List<Schedule>> getUserSchedules() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return [];
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Schedule(
          id: data['id'],
          createdAt: DateTime.parse(data['createdAt']),
          activities: (data['activities'] as List).map((activityData) {
            return Activity(
              id: activityData['id'],
              title: activityData['title'],
              description: activityData['description'],
              startTime: DateTime.parse(activityData['startTime']),
              endTime: DateTime.parse(activityData['endTime']),
              price: (activityData['price'] as num).toDouble(),
              imageUrl: activityData['imageUrl'],
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      print('Error getting user schedules: $e');
      return [];
    }
  }
}
