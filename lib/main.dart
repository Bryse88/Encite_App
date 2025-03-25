import 'package:encite/components/LoginComponents/Authentication/auth_wrapper.dart';
import 'package:encite/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encite',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF007AFF),
          secondary: Color(0xFF5AC8FA),
          background: Colors.black,
        ),
        fontFamily: 'SF Pro Display',
      ),
      home: const AuthWrapper(), // ← instead of just HomePage
      debugShowCheckedModeBanner: false,
    );
  }
}
