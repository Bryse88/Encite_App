import 'package:flutter/material.dart';

class ActivitiesPage extends StatelessWidget {
  final List<String> selectedActivities;
  final ValueChanged<List<String>> onActivitiesChanged;

  const ActivitiesPage({
    required this.selectedActivities,
    required this.onActivitiesChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      'Outdoor adventures',
      'Food & dining',
      'Arts & culture',
      'Sports & fitness',
      'Tech & gaming',
      'Learning & workshops',
      'Music & nightlife',
      'Community service',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          "What activities do you enjoy most?",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF484848)),
        ),
        const SizedBox(height: 12),
        const Text(
          "Select up to 3 activities to help us find the perfect experiences for you.",
          style: TextStyle(fontSize: 16, color: Color(0xFF767676)),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 12,
          runSpacing: 16,
          children: options.map((activity) {
            final isSelected = selectedActivities.contains(activity);
            return GestureDetector(
              onTap: () {
                final updated = [...selectedActivities];
                if (isSelected) {
                  updated.remove(activity);
                } else if (updated.length < 3) {
                  updated.add(activity);
                }
                onActivitiesChanged(updated);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF5A5F) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFF5A5F)
                        : const Color(0xFFDDDDDD),
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  activity,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF484848),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
