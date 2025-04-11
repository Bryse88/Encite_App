import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
          colors: [
            Color(0xFF1C1C1E), // Dark charcoal
            Color(0xFF2A2438), // Muted plum-ish purple
            Color.fromARGB(255, 44, 43, 93)
          ],
        ),
      ),
      child: child,
    );
  }
}
