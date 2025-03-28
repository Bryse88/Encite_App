import 'package:flutter/material.dart';

class HomeMenuItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  HomeMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });

  factory HomeMenuItem.fromMap(Map<String, dynamic> map, String documentId) {
    // Convert string color to Color
    Color itemColor = Color(int.parse(map['color'] ?? '0xFFFFFFFF', radix: 16));

    // Convert string icon to IconData
    IconData itemIcon = _getIconData(map['icon'] ?? 'settings');

    return HomeMenuItem(
      id: documentId,
      title: map['title'] ?? 'Unknown',
      icon: itemIcon,
      color: itemColor,
      route: map['route'] ?? '/',
    );
  }

  // Helper method to convert string icon name to IconData
  static IconData _getIconData(String iconName) {
    // Map of string icon names to Icons
    Map<String, IconData> iconMap = {
      'chat_bubble_outline': Icons.chat_bubble_outline,
      'today': Icons.today,
      'schedule': Icons.schedule,
      'explore': Icons.explore,
      'add_circle_outline': Icons.add_circle_outline,
      'people': Icons.people,
      'calendar_month': Icons.calendar_month,
      'public': Icons.public,
      'travel_explore': Icons.travel_explore,
      'settings': Icons.settings,
      // Add more icons as needed
    };
    return iconMap[iconName] ?? Icons.help_outline;
  }
}
