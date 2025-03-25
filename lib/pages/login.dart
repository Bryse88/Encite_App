import 'dart:ui';
import 'package:encite/components/LoginComponents/auth/SocialAuthButtons.dart';
import 'package:encite/components/LoginComponents/auth_form.dart';
import 'package:encite/components/LoginComponents/impaler_bar.dart';
import 'package:encite/components/LoginComponents/logo_with_name.dart';
import 'package:encite/components/LoginComponents/social_login_options.dart';
import 'package:encite/pages/proflie.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => CustomPaint(
              painter: BackgroundPainter(_animationController.value),
              size: MediaQuery.of(context).size,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoWithName(animationValue: _animationController.value),
                    const SizedBox(height: 20),
                    Text(
                      "Smarter schedules. Stronger socials.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 60),
                    AuthForm(isLogin: _isLogin),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Don't have an account?"
                              : "Already have an account?",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14),
                        ),
                        TextButton(
                          onPressed: _toggleAuthMode,
                          child: Text(
                            _isLogin ? "Create one" : "Sign in",
                            style: const TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SocialAuthButtons(),
                    const SizedBox(height: 20),
                    const SocialLoginOptions(),
                  ],
                ),
              ),
            ),
          ),
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
