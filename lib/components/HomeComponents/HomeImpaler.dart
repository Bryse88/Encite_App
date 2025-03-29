import 'package:flutter/material.dart';

class HomeImpalerBar extends StatelessWidget {
  const HomeImpalerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4, // Instead of height, since it's vertical now
      height: MediaQuery.of(context).size.height *
          0.6, // Optional: set vertical length
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A3A8F), Color(0xFF3E6CDF)],
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E6CDF).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
