import 'package:flutter/material.dart';

class ImpalerBar extends StatelessWidget {
  const ImpalerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1A3A8F), Color(0xFF3E6CDF)],
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E6CDF).withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}
