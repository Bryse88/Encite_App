import 'package:intl/intl.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime startTime; // 🔄 Changed to DateTime
  final DateTime endTime; // 🔄 Changed to DateTime
  final double price;
  final String imageUrl;
  final String explanation;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.imageUrl,
    required this.explanation,
  });

  // Getters for formatted display
  String get formattedStartTime => DateFormat('h:mm a').format(startTime);
  String get formattedEndTime => DateFormat('h:mm a').format(endTime);

  String get formattedDuration {
    final difference = endTime.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hr ${minutes}min';
    } else if (hours > 0) {
      return hours == 1 ? '1 hour' : '$hours hours';
    } else {
      return minutes == 1 ? '1 minute' : '$minutes minutes';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'price': price,
      'imageUrl': imageUrl,
      'explanation': explanation,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime']).toLocal(), // ✅ Convert here
      endTime: DateTime.parse(json['endTime']).toLocal(), // ✅ Convert here
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}
