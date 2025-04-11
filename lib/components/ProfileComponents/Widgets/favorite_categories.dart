import 'dart:ui';
import 'package:flutter/material.dart';

Widget buildIdentityTags(Map<String, dynamic> userData) {
  final List<dynamic>? tags = userData['identityTags'];
  if (tags == null || tags.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          'Your Vibe',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tags.length,
          itemBuilder: (context, index) {
            final tag = tags[index];
            return buildCategoryChip(tag, index);
          },
        ),
      ),
    ],
  );
}

Widget buildCategoryChip(String category, int index) {
  final List<Color> chipColors = [
    const Color(0xFF5AC8FA),
    const Color(0xFF4CD964),
    const Color(0xFFFF2D55),
    const Color(0xFF007AFF),
    const Color(0xFF5856D6),
    const Color(0xFFFF9500),
    const Color(0xFFFFCC00),
    const Color(0xFFAF52DE),
  ];

  final color = chipColors[index % chipColors.length];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );
}
