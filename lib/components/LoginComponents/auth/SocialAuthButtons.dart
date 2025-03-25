import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class SocialAuthButtons extends StatefulWidget {
  const SocialAuthButtons({Key? key}) : super(key: key);

  @override
  State<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends State<SocialAuthButtons> {
  bool _isLoading = false;

  // Reference to Firestore collection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store user data in Firestore
  Future<void> _storeUserData(User user, {String? displayName}) async {
    try {
      // Use provided name if user name is null or empty
      final name =
          user.displayName?.isNotEmpty == true ? user.displayName : displayName;

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': name,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'provider': user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : 'unknown',
      }, SetOptions(merge: true)); // Use merge to update existing data
    } catch (e) {
      print('Error storing user data: $e');
      // Continue flow even if data storage fails
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      setState(() => _isLoading = true);

      // Begin Google sign in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User canceled
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Store user data
      if (userCredential.user != null) {
        await _storeUserData(userCredential.user!);
        _navigateToHome();
      }
    } catch (e) {
      _showError(context, 'Google sign-in failed: ${_getReadableError(e)}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      setState(() => _isLoading = true);

      // Begin Apple sign in flow
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      // Create full name from Apple credential if available
      String? fullName;
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        fullName = [
          appleCredential.givenName ?? '',
          appleCredential.familyName ?? ''
        ].where((name) => name.isNotEmpty).join(' ');
      }

      // Get Apple OAuth provider credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Store user data (including name from Apple)
      if (userCredential.user != null) {
        await _storeUserData(userCredential.user!,
            displayName: fullName?.isNotEmpty == true ? fullName : null);
        _navigateToHome();
      }
    } catch (e) {
      _showError(context, 'Apple sign-in failed: ${_getReadableError(e)}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Get a more user-friendly error message
  String _getReadableError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'invalid-credential':
          return 'The provided credentials are invalid.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled for this project.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'user-not-found':
          return 'No user found with this email address.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    return error.toString();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _navigateToHome() {
    // Navigate to your home page or dashboard after login
    Navigator.of(context)
        .pushReplacementNamed('/home'); // Update with your route
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E6CDF)),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          "or sign in with",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        if (Platform.isIOS)
          _buildButton(
            context,
            icon: Icons.apple,
            text: 'Continue with Apple',
            onPressed: () => _signInWithApple(context),
          ),
        _buildButton(
          context,
          icon: Icons.g_mobiledata,
          text: 'Continue with Google',
          onPressed: () => _signInWithGoogle(context),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(text,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
