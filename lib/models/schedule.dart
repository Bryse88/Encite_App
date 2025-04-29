import 'package:intl/intl.dart';
import 'activity.dart';

class Schedule {
  final String id;
  final List<Activity> activities;
  final String createdAt;

  Schedule({
    required this.id,
    required this.activities,
    required this.createdAt,
  });

  // Display the time frame from the first to the last activity
  String get localTimeFrame {
    if (activities.isEmpty) return 'No time frame';

    final formatter = DateFormat('h:mm a');
    return '${formatter.format(activities.first.startTime)} - ${formatter.format(activities.last.endTime)}';
  }

  // Total cost of all activities
  double get totalCost {
    return activities.fold(0.0, (sum, activity) => sum + activity.price);
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final List<dynamic> activityData = json['activities'] ?? [];
    final List<Activity> activities =
        activityData.map((data) => Activity.fromJson(data)).toList();

    return Schedule(
      id: json['id'] ?? '',
      activities: activities,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activities': activities.map((a) => a.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}
