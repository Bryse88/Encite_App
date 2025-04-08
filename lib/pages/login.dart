import 'package:encite/components/LoginComponents/SocialAuthButtons.dart';
import 'package:encite/components/LoginComponents/impaler_bar.dart';
import 'package:encite/components/LoginComponents/logo_with_name.dart';
import 'package:encite/components/LoginComponents/social_login_options.dart';
import 'package:encite/components/MainComponents/background_painter.dart';
import 'package:flutter/material.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({Key? key}) : super(key: key);

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  late AnimationController _animationController;

  void _toggleAuthMode() => setState(() => _isLogin = !_isLogin);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => CustomPaint(
              painter: BackgroundPainter(_animationController.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          // main UI content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.1),
                    Center(
                      child: Text(
                        'encite',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Mediating your social planning",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: height * 0.3),
                    const SocialAuthButtons(),
                    const SizedBox(height: 16),
                    const SocialLoginOptions(),
                    const SizedBox(height: 120), // so it's above the bar
                  ],
                ),
              ),
            ),
          ),

          // floating impaler bar
          const Positioned(
            bottom: 70,
            left: 24,
            right: 24,
            child: ImpalerBar(),
          ),
        ],
      ),
    );
  }
}
