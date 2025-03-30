import 'dart:ui';

import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Gradient gradient;

  const GradientButton({
    required this.onPressed,
    required this.label,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
    ),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
