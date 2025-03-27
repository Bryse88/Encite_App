import 'dart:math' as math;
import 'package:flutter/material.dart';

class BackgroundPainter1 extends CustomPainter {
  final double animationValue;

  BackgroundPainter1(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    Paint paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.5 + 0.3 * math.sin(animationValue * 2 * math.pi),
          0.5 + 0.3 * math.cos(animationValue * 2 * math.pi),
        ),
        radius: 1.2,
        colors: const [
          Color(0xFF1A1A1A),
          Color(0xFF0C0C0C),
          Colors.black,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final offset = i / 20;
      final x = size.width *
          (0.2 + 0.6 * math.sin(2 * math.pi * (offset + animationValue)));
      final y = size.height *
          (0.2 + 0.6 * math.cos(2 * math.pi * (offset + animationValue * 1.2)));
      final radius = 5 + 5 * math.sin(animationValue * 2 * math.pi + i);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter1 oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
