import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BirthdayPage extends StatelessWidget {
  final DateTime? birthday;
  final ValueChanged<DateTime> onBirthdaySelected;
  final VoidCallback onNext;

  const BirthdayPage({
    required this.birthday,
    required this.onBirthdaySelected,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          "When's your birthday?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF484848),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "This helps us customize your experience.",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF767676),
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () async {
            final picked = await showCupertinoModalPopup<DateTime>(
              context: context,
              builder: (_) => CupertinoActionSheet(
                message: SizedBox(
                  height: 250,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: birthday ??
                        DateTime.now().subtract(const Duration(days: 365 * 25)),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: onBirthdaySelected,
                  ),
                ),
              ),
            );
            if (picked != null) onBirthdaySelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  birthday != null
                      ? '${birthday!.month}/${birthday!.day}/${birthday!.year}'
                      : 'Select your birthday',
                  style: TextStyle(
                    fontSize: 16,
                    color: birthday != null
                        ? const Color(0xFF484848)
                        : const Color(0xFF767676),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 20, color: Color(0xFF767676)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
