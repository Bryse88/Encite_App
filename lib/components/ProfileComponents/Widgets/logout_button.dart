import 'package:flutter/material.dart';

Widget buildLogoutButton() {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: GestureDetector(
      onTap: () {
        // Logout logic
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: 1.0,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFFFF2D55).withOpacity(0.8),
                const Color(0xFFFF9500).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF2D55).withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
