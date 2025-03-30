import 'package:flutter/material.dart';

class DietaryPage extends StatelessWidget {
  final String? selectedOption;
  final ValueChanged<String> onSelected;

  const DietaryPage({
    required this.selectedOption,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      'No allergies or restrictions',
      'Vegetarian/Vegan',
      'Gluten-free',
      'Nut allergies',
      'Dairy-free',
      'Other (please specify)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          "Any dietary preferences?",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF484848)),
        ),
        const SizedBox(height: 12),
        const Text(
          "This helps us recommend suitable food experiences.",
          style: TextStyle(fontSize: 16, color: Color(0xFF767676)),
        ),
        const SizedBox(height: 40),
        ...options.map((option) {
          final isSelected = selectedOption == option;
          return GestureDetector(
            onTap: () => onSelected(option),
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
