import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child; // Add a child property
  const GradientBackground(
      {super.key, required this.child}); // Modify constructor to accept a child

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color.fromRGBO(1, 5, 25, 1), // Darker color at the bottom
            Color.fromRGBO(48, 55, 52, 1), // Lighter color towards the top
          ],
        ),
      ),
      child: child, // Use the child property here
    );
  }
}
