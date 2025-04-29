import 'package:encite/components/LoginComponents/AuthenticationServices/auth_services.dart';
import 'package:encite/pages/app_navigator.dart';
import 'package:encite/pages/group_page.dart';
import 'package:encite/pages/home_page.dart';
import 'package:encite/pages/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            print('🔑 User not logged in');

            return const WelcomeScreen();
          } else {
            // User is logged in, go to Navigation page
            print('✅ User is logged in: ${user.email}');

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
