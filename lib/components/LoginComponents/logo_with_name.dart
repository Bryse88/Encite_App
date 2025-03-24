import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class LogoWithName extends StatelessWidget {
  final double animationValue;

  const LogoWithName({super.key, required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo circle with glow
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A3A8F).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F111A).withOpacity(0.8),
                      const Color(0xFF141828).withOpacity(0.6),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF3E6CDF).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.travel_explore,
                      size: 50, color: Color(0xFF3E6CDF)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A3A8F),
                const Color(0xFF3E6CDF),
                const Color(0xFF5377E8),
                const Color(0xFF1A3A8F),
              ],
              stops: [
                0.0,
                0.3 + (0.2 * sin(animationValue * 2 * pi)),
                0.6 + (0.2 * sin(animationValue * 2 * pi)),
                1.0,
              ],
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: const Text(
            "ENCITE",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4.0,
            ),
          ),
        ),
      ],
    );
  }
}
