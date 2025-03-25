import 'package:encite/components/LoginComponents/Authentication/auth_services.dart';
import 'package:encite/pages/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encite/pages/login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // If the snapshot has user data, user is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            // User is not logged in, go to Login page
            return const LoginSignupPage();
          } else {
            // User is logged in, go to Navigation page
            return NavigationPage();
          }
        }

        // Show loading indicator while checking authentication state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
