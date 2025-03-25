import 'package:flutter/material.dart';

class NameInputField extends StatelessWidget {
  const NameInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F111A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1E2235),
              width: 1,
            ),
          ),
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "First Name",
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF3E6CDF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
