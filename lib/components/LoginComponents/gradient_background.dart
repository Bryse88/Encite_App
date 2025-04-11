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
            Color.fromARGB(255, 0, 0, 0), // Dark charcoal
            Color.fromARGB(255, 40, 43, 48), // Muted plum-ish purple
            Color.fromARGB(255, 45, 58, 95)
          ],
        ),
      ),
      child: child,
    );
  }
}
