import 'package:flutter/material.dart';

// Uber dark theme colors
class UberColors {
  static const Color primary = Color(0xFF276EF1); // Uber Blue
  static const Color background = Color(0xFF121212); // Very dark gray/black
  static const Color surface = Color(0xFF1C1C1E); // Slightly lighter dark
  static const Color cardBg = Color(0xFF222222); // Card background
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFAAAAAA); // Light gray
  static const Color accent = Color(0xFF15D071); // Success green
  static const Color divider = Color(0xFF2A2A2A); // Dark gray divider
  static const Color error = Color(0xFFE51919); // Error/alert red
  static const Color cardBackground = Color(0xFF1E1E1E); // Card background
}

class SchedulePresentationPage1 extends StatefulWidget {
  final Map<String, dynamic> schedule;

  const SchedulePresentationPage1({Key? key, required this.schedule})
      : super(key: key);

  @override
  _SchedulePresentationPageState1 createState() =>
      _SchedulePresentationPageState1();
}

class _SchedulePresentationPageState1 extends State<SchedulePresentationPage1> {
  late List<Map<String, dynamic>> activities;

  @override
  void initState() {
    super.initState();
    activities = List<Map<String, dynamic>>.from(widget.schedule['activities']);
  }

  void _removeActivity(int index) {
    setState(() {
      activities.removeAt(index);
    });
  }

  void _saveSchedule() {
    // Save logic here (for now, just pop back to home)
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _discardSchedule() {
    // Discard and go back home
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UberColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: UberColors.background,
        centerTitle: false,
        title: const Text(
          "Your Itinerary",
          style: TextStyle(
            color: UberColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: UberColors.textPrimary),
      ),
      body: activities.isEmpty
          ? Center(
              child: Text(
                "No activities planned",
                style: TextStyle(
                  color: UberColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildActivityCard(activity, index),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: UberColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _discardSchedule,
                  style: TextButton.styleFrom(
                    foregroundColor: UberColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Discard",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UberColors.primary,
                    foregroundColor: UberColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save Itinerary",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, int index) {
    return Container(
      decoration: BoxDecoration(
        color: UberColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with time overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  activity['imageUrl'] ?? '',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: UberColors.surface,
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: UberColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: UberColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${activity['startTime']} - ${activity['endTime']}",
                    style: const TextStyle(
                      color: UberColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: UberColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                    Icons.location_on_outlined, activity['location'] ?? ''),
                const SizedBox(height: 4),
                // _buildInfoRow(Icons.attach_money, "\${activity['cost']}"),
                _buildInfoRow(Icons.attach_money, "\$${activity['cost']}"),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.directions_car_outlined,
                    activity['transportation'] ?? ''),
                const SizedBox(height: 16),

                // Remove activity button
                GestureDetector(
                  onTap: () => _removeActivity(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: 16,
                          color: UberColors.error,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Remove",
                          style: TextStyle(
                            color: UberColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: UberColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: UberColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
