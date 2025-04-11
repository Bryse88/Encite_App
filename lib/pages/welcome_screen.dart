import 'package:encite/components/LoginComponents/gradient_background.dart';
import 'package:encite/components/MainComponents/background_painter.dart';
import 'package:encite/pages/login.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Animated background
            // AnimatedBuilder(
            //   animation: const AlwaysStoppedAnimation(0.5),
            //   builder: (context, child) => CustomPaint(
            //     painter: BackgroundPainter(0.5),
            //     size: MediaQuery.of(context).size,
            //   ),
            // ),
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: height * 0.2,
                    ),
                    Center(
                      child: Text(
                        'encite',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.48,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginSignupPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
