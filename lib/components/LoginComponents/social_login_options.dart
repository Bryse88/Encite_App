import 'package:encite/pages/Legal_page.dart';
import 'package:flutter/material.dart';

class SocialLoginOptions extends StatelessWidget {
  const SocialLoginOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          "By continuing, you agree to our",
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Navigate to Terms of Service (tab index 0)
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LegalPagesScreen(initialTab: 0),
                  ),
                );
              },
              child: const Text(
                "Terms of Service",
                style: TextStyle(
                  color: Color(0xFF3E6CDF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              "and",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Privacy Policy (tab index 1)
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LegalPagesScreen(initialTab: 1),
                  ),
                );
              },
              child: const Text(
                "Privacy Policy",
                style: TextStyle(
                  color: Color(0xFF3E6CDF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
