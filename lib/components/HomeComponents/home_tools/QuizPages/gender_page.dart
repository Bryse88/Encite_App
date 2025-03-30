import 'package:flutter/material.dart';

class GenderPage extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderPage({
    required this.selectedGender,
    required this.onGenderSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final genderOptions = [
      'Male',
      'Female',
      'Non-binary',
      'Other',
      'Prefer not to say',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          "Which best describes your gender?",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF484848)),
        ),
        const SizedBox(height: 12),
        const Text(
          "Help us personalize your recommendations.",
          style: TextStyle(fontSize: 16, color: Color(0xFF767676)),
        ),
        const SizedBox(height: 40),
        ...genderOptions.map((option) {
          final isSelected = selectedGender == option;
          return GestureDetector(
            onTap: () => onGenderSelected(option),
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
