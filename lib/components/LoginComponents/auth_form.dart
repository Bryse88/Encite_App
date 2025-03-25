import 'dart:ui';
import 'package:flutter/material.dart';
import 'primary_button.dart';
import 'auth/name_input_field.dart';
import 'auth/phone_input_field.dart';
import 'auth/auth_title.dart';

class AuthForm extends StatelessWidget {
  final bool isLogin;

  const AuthForm({Key? key, required this.isLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      clipBehavior: Clip.none,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: _containerDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthTitle(isLogin: isLogin),
                const SizedBox(height: 24),
                const PhoneInputField(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                  ),
                  child: !isLogin
                      ? const NameInputField(key: ValueKey('signup'))
                      : const SizedBox(key: ValueKey('login')),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: isLogin ? "Continue" : "Create Account",
                  onPressed: () {
                    // TODO: Add Firebase auth logic
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0A0A),
          Color(0xFF121726),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 15,
        ),
      ],
    );
  }
}
