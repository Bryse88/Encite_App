import 'dart:ui';
import 'package:flutter/material.dart';

class PrimaryBar extends StatelessWidget {
  final double width;
  final double height;

  const PrimaryBar({
    super.key,
    this.width = 300,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              colors: [
                Colors.blueGrey.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
                Colors.blueGrey.withOpacity(0.2),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
