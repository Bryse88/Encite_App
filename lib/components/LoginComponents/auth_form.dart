import 'dart:ui';
import 'package:flutter/material.dart';
import 'primary_button.dart';

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
            decoration: BoxDecoration(
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
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? "Sign in with phone" : "Create account",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  hintText: "Phone Number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1.0,
                        child: child,
                      ),
                    );
                  },
                  child: !isLogin
                      ? Column(
                          key: const ValueKey('signup'),
                          children: [
                            const SizedBox(height: 16),
                            _buildInputField(
                              hintText: "Full Name",
                              icon: Icons.person_outline,
                            ),
                          ],
                        )
                      : const SizedBox(key: ValueKey('login')),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: isLogin ? "Continue" : "Create Account",
                  onPressed: () {
                    // Handle login/signup
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F111A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E2235),
          width: 1,
        ),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: const Color(0xFF3E6CDF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
