import 'package:flutter/material.dart';

class GatheringSizePage extends StatelessWidget {
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;

  const GatheringSizePage({
    required this.selectedSize,
    required this.onSizeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      'Just me and one other person',
      'Small group (3–5 people)',
      'Medium group (6–15 people)',
      'Large events (15+ people)',
      'Depends on the activity',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          "What's your ideal gathering size?",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF484848)),
        ),
        const SizedBox(height: 12),
        const Text(
          "We'll find social events that match your comfort level.",
          style: TextStyle(fontSize: 16, color: Color(0xFF767676)),
        ),
        const SizedBox(height: 40),
        ...options.map((option) {
          final isSelected = selectedSize == option;
          return GestureDetector(
            onTap: () => onSizeSelected(option),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF8F9) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF5A5F)
                      : const Color(0xFFDDDDDD),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    option,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF5A5F)
                          : const Color(0xFF484848),
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        color: Color(0xFFFF5A5F), size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
