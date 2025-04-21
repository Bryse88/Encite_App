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
      print('Generating schedule with data: ${jsonEncode(userData)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('Received schedule response: ${response.body}');

        if (decoded['activities'] == null ||
            (decoded['activities'] as List).isEmpty) {
          print('Response contained no activities');
          return null;
        }

        // Extract original user-selected times from the input
        final userStartTime = DateTime.parse(userData['startTime']).toLocal();
        final userEndTime = DateTime.parse(userData['endTime']).toLocal();

        return Schedule(
          id: decoded['id'] ?? 'schedule_${const Uuid().v4().substring(0, 8)}',
          createdAt: DateTime.parse(decoded['createdAt']),
          activities: (decoded['activities'] as List).map((activityJson) {
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
          userStartTime: userStartTime,
          userEndTime: userEndTime,
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

  Future<Activity?> requestSubstituteActivity(
      String activityId, Schedule schedule) async {
    try {
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

      final response = await http.post(
        Uri.parse('$apiUrl/substitute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(substitutionRequest),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final activityJson = decoded['activity'];

        if (activityJson != null) {
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

      return _generateMockSubstitute(activityId, schedule);
    } catch (e) {
      print('Error requesting substitute: $e');
      return _generateMockSubstitute(activityId, schedule);
    }
  }

  Activity _generateMockSubstitute(String activityId, Schedule schedule) {
    final originalActivity = schedule.activities.firstWhere(
      (a) => a.id == activityId,
      orElse: () => schedule.activities.first,
    );

    final alternativeTitles = [
      'Alternative ${originalActivity.title.split(' ').last}',
      'Different ${originalActivity.title.split(' ').last}',
      'New ${originalActivity.title.split(' ').last} Experience',
      'Exciting ${originalActivity.title.split(' ').last}',
    ];

    final title = alternativeTitles[
        DateTime.now().millisecond % alternativeTitles.length];
    final newId = 'substitute_${const Uuid().v4().substring(0, 8)}';

    _saveActivityExplanation(newId,
        'AI-suggested alternative that fits within your schedule timeframe.');

    return Activity(
      id: newId,
      title: title,
      description:
          'This is an alternative activity suggested by our AI based on your preferences.',
      startTime: originalActivity.startTime,
      endTime: originalActivity.endTime,
      price: originalActivity.price * 0.9,
      imageUrl:
          'https://picsum.photos/200?random=${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<void> saveSchedule(Schedule schedule) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final schedulesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('schedules')
        .doc(schedule.id);

    await schedulesRef.set({
      'id': schedule.id,
      'createdAt': schedule.createdAt.toIso8601String(),
      'totalCost': schedule.totalCost,
      'startTime': schedule.startTime.toIso8601String(),
      'endTime': schedule.endTime.toIso8601String(),
      'userStartTime': schedule.userStartTime?.toIso8601String(),
      'userEndTime': schedule.userEndTime?.toIso8601String(),
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
          userStartTime: data['userStartTime'] != null
              ? DateTime.parse(data['userStartTime']).toLocal()
              : null,
          userEndTime: data['userEndTime'] != null
              ? DateTime.parse(data['userEndTime']).toLocal()
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error getting user schedules: $e');
      return [];
    }
  }
}
