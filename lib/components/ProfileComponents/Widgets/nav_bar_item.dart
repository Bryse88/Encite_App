import 'package:flutter/material.dart';

Widget buildNavBarItem(IconData icon, String label, {bool isActive = false}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: isActive ? const Color(0xFF007AFF) : Colors.white,
        size: 26,
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          color: isActive
              ? const Color(0xFF007AFF)
              : Colors.white.withOpacity(0.8),
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ],
  );
}
