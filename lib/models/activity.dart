class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final String imageUrl;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.imageUrl,
  });
}
