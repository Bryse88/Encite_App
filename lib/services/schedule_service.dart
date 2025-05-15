import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/models/activity.dart';
import 'package:encite/models/schedule.dart';

class ScheduleService {
  final String apiUrl =
      'https://encite-mvp-backend.onrender.com/generate_schedule';

  // Future<Schedule?> generateSchedule(Map<String, dynamic> payload) async {
  //   try {
  //     print('Sending request to: $apiUrl');
  //     print('Payload: ${json.encode(payload)}');

  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(payload),
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       print('Received schedule response: ${response.body}');
  //       return Schedule.fromJson(data);
  //     } else {
  //       print('Error: HTTP status ${response.statusCode}');
  //       print('Response: ${response.body}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error generating schedule: $e');
  //     return null;
  //   }
  // }
  Future<Map<String, dynamic>> generateSchedule(
      Map<String, dynamic> payload) async {
    // Fake mock schedule instead of API call
    await Future.delayed(const Duration(seconds: 2)); // simulate loading

    return {
      "activities": [
        {
          "title": "Coffee at Indie Coffee",
          "startTime": "4:00pm",
          "endTime": "5:00pm",
          "location": "1225 Regent St, Madison, WI",
          "imageUrl":
              "https://s3-media0.fl.yelpcdn.com/bphoto/IZtXZIMnIxAAuDSnGaUExQ/o.jpg",
          "cost": 6.0,
          "transportation": "Walking"
        },
        {
          "title": "Early Dinner at Greenbush Bar",
          "startTime": "5:00pm",
          "endTime": "6:00pm",
          "location": "914 Regent St, Madison, WI",
          "imageUrl":
              "https://s3-media0.fl.yelpcdn.com/bphoto/t7j0Gk16NLlubcMKlXOeyA/o.jpg",
          "cost": 12.0,
          "transportation": "Walking"
        },
        {
          "title": "Attend Midwest Mix-Up Show",
          "startTime": "6:30pm",
          "endTime": "7:00pm",
          "location": "1206 Regent St, Madison, WI (The Annex)",
          "imageUrl":
              "https://www.theredzonemadison.com/wp-content/uploads/2013/12/Live-Music1.jpg",
          "cost": 24.5,
          "transportation": "Walking"
        },
      ],
      "totalCost": 42.5,
    };
  }

  Future<Activity?> requestSubstituteActivity(
      String activityId, Schedule schedule) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final activityToReplace = schedule.activities.firstWhere(
        (activity) => activity.id == activityId,
        orElse: () => throw Exception('Activity not found'),
      );

      final prefDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('onboarding')
          .doc('main')
          .get();

      final prefs = prefDoc.data() ?? {};

      final payload = {
        "replace_activity": activityToReplace.toJson(),
        "existing_activities": schedule.activities
            .where((a) => a.id != activityId)
            .map((a) => a.toJson())
            .toList(),
        "location": prefs['location'] ?? "Madison, WI",
        "experience_vibes": prefs['experience_vibes'] ?? ["Social & Outgoing"],
        "activities": prefs['activities'] ?? ["Try new restaurants / cafes"],
        "dietary_preference": prefs['dietary_preference'] ?? "No Preference",
        "travel_willingness":
            prefs['travel_willingness'] ?? "Walking Distance (< 15 min)",
        "transportation_modes": prefs['transportation_modes'] ?? ["Walking"],
        "budget": prefs['budget'] ?? 100.0,
        "location_priorities": {
          "Ambience & Atmosphere": prefs['ambience_priority'] ?? 3,
          "Cost / Budget": prefs['budget_priority'] ?? 2,
          "Distance / Travel Time": prefs['distance_priority'] ?? 3,
          "Food & Drink Quality": prefs['food_quality_priority'] ?? 4,
          "Reviews & Popularity": prefs['popularity_priority'] ?? 2,
          "Unique or Specialty Offerings": prefs['uniqueness_priority'] ?? 6
        }
      };

      print('Substitute payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$apiUrl/substitute'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Substitute response: ${response.body}');

        if (data != null && data.containsKey('activity')) {
          return Activity.fromJson(data['activity']);
        }
        return null;
      } else {
        print('Error substituting activity: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error substituting activity: $e');
      return null;
    }
  }

  Future<void> saveSchedule(Schedule schedule) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .doc(schedule.id)
          .set({
        'id': schedule.id,
        'createdAt':
            DateTime.parse(schedule.createdAt).toUtc().toIso8601String(),
        'activities': schedule.activities.map((a) => a.toJson()).toList(),
      });
    } catch (e) {
      print('Error saving schedule: $e');
      throw e;
    }
  }

  Future<String?> getActivityExplanation(String activityId) async {
    return null;
  }

  Future<List<Schedule>> getUserSchedules() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .orderBy('createdAt', descending: true)
          .get();

      final schedules = snapshot.docs.map((doc) {
        final data = doc.data();

        List<Activity> activities = [];
        if (data['activities'] != null && data['activities'] is List) {
          activities = (data['activities'] as List).map((activityData) {
            return Activity(
              id: activityData['id'] ?? '',
              title: activityData['title'] ?? '',
              description: activityData['description'] ?? '',
              startTime: _normalizeTime(activityData['startTime']),
              endTime: _normalizeTime(activityData['endTime']),
              price: _parsePrice(activityData['price']),
              imageUrl: activityData['imageUrl'] ?? '',
              explanation: activityData['explanation'] ?? '',
            );
          }).toList();
        }

        return Schedule(
            id: data['id'] ?? doc.id,
            activities: activities,
            createdAt: data['createdAt']);
      }).toList();

      return schedules;
    } catch (e) {
      print('Error in getUserSchedules: $e');
      return [];
    }
  }

  DateTime _normalizeTime(dynamic timeValue) {
    if (timeValue == null) return DateTime.now();
    if (timeValue is DateTime) return timeValue.toLocal();
    if (timeValue is String) {
      try {
        return DateTime.parse(timeValue).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
    if (timeValue is Timestamp) {
      return timeValue.toDate().toLocal();
    }
    if (timeValue is Map && timeValue.containsKey('seconds')) {
      final seconds = timeValue['seconds'] as int;
      final nanoseconds = timeValue['nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds ~/ 1000000),
      ).toLocal();
    }
    return DateTime.now();
  }

  double _parsePrice(dynamic priceValue) {
    if (priceValue == null) return 0.0;
    if (priceValue is int) return priceValue.toDouble();
    if (priceValue is double) return priceValue;
    if (priceValue is String) {
      try {
        return double.parse(priceValue);
      } catch (_) {
        final numericString = priceValue.replaceAll(RegExp(r'[^\d.]'), '');
        if (numericString.isNotEmpty) {
          try {
            return double.parse(numericString);
          } catch (_) {
            return 0.0;
          }
        }
      }
    }
    return 0.0;
  }
}
