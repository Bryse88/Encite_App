import 'package:encite/models/activity.dart';
import 'package:encite/pages/scheduler.dart';

class Schedule {
  final String id;
  final DateTime createdAt;
  final List<Activity> activities;

  Schedule({
    required this.id,
    required this.createdAt,
    required this.activities,
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

  String get timeFrame => '${_format(startTime)} – ${_format(endTime)}';

  String _format(DateTime dt) =>
      '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
}
