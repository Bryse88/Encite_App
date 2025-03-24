import 'package:encite/pages/app_navigator.dart';
import 'package:encite/pages/login.dart';
import 'package:encite/pages/proflie.dart';
import 'package:encite/pages/scheduler.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
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
      home: AppNavigator(), // ← instead of just HomePage
      debugShowCheckedModeBanner: false,
    );
  }
}
