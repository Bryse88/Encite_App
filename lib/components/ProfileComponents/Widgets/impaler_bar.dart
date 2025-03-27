import 'package:flutter/material.dart';

Widget buildImpalerBar() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    height: 4,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF007AFF),
          Color(0xFF5AC8FA),
        ],
      ),
      borderRadius: BorderRadius.circular(2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF007AFF).withOpacity(0.5),
          blurRadius: 10,
        ),
      ],
    ),
  );
}
