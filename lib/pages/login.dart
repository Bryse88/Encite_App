import 'package:flutter/material.dart';
import '../components/primary_bar.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; ← remove if not used

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                const Text(
                  'Encite',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // Signature UI bar
                const PrimaryBar(),

                const SizedBox(height: 60),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to sign-in screen
                      },
                      child: const Text('Sign In'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to sign-up screen
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
