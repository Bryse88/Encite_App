import 'package:flutter/material.dart';

class AuthTitle extends StatelessWidget {
  final bool isLogin;

  const AuthTitle({Key? key, required this.isLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      isLogin ? "Sign in with phone" : "Create account",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
