import 'package:encite/models/activity.dart';
import 'package:encite/pages/scheduler.dart';
import 'package:intl/intl.dart';

class Schedule {
  final String id;
  final DateTime createdAt;
  final List<Activity> activities;

  final DateTime? userStartTime;
  final DateTime? userEndTime;

  Schedule({
    required this.id,
    required this.createdAt,
    required this.activities,
    this.userStartTime,
    this.userEndTime,
  });

  double get totalCost => activities.fold(0.0, (sum, a) => sum + a.price);

  DateTime get startTime => activities.isNotEmpty
      ? activities
          .map((a) => a.startTime)
          .reduce((a, b) => a.isBefore(b) ? a : b)
      : DateTime.now();

  DateTime get endTime => activities.isNotEmpty
      ? activities.map((a) => a.endTime).reduce((a, b) => a.isAfter(b) ? a : b)
      : DateTime.now();

  String get timeFrame {
    final start = userStartTime ?? startTime;
    final end = userEndTime ?? endTime;
    return '${_format(start)} – ${_format(end)}';
  }

  String _format(DateTime dt) => DateFormat.jm().format(dt.toLocal());
}

// class Schedule {
//   final String id;
//   final DateTime createdAt;
//   final List<Activity> activities;

//   final DateTime? userStartTime; // ⬅️ NEW
//   final DateTime? userEndTime;   // ⬅️ NEW

//   Schedule({
//     required this.id,
//     required this.createdAt,
//     required this.activities,
//     this.userStartTime,
//     this.userEndTime,
//   });

//   double get totalCost => activities.fold(0.0, (sum, a) => sum + a.price);

//   DateTime get startTime => activities.isNotEmpty
//       ? activities
//           .map((a) => a.startTime)
//           .reduce((a, b) => a.isBefore(b) ? a : b)
//       : DateTime.now();

//   DateTime get endTime => activities.isNotEmpty
//       ? activities.map((a) => a.endTime).reduce((a, b) => a.isAfter(b) ? a : b)
//       : DateTime.now();

//   String get timeFrame => '${_format(startTime)} – ${_format(endTime)}';

//   String _format(DateTime dt) => DateFormat.jm().format(dt);
// }
