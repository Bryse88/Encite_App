import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/background_painter.dart';
import 'package:encite/components/ProfileComponents/Widgets/favorite_categories.dart';
import 'package:encite/components/ProfileComponents/Widgets/impaler_bar.dart';
import 'package:encite/components/ProfileComponents/Widgets/logout_button.dart';
import 'package:encite/components/ProfileComponents/Widgets/nav_bar_item.dart';
import 'package:encite/components/ProfileComponents/Widgets/profile_header.dart';
import 'package:encite/components/ProfileComponents/recent_activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, dynamic>? userData; // nullable to allow loading

  final Map<String, dynamic> userData1 = {
    'name': 'Alex Morgan',
    'username': '@alexmorgan',
    'email': 'alex.morgan@example.com',
    'profileImage': 'https://i.pravatar.cc/300',
    'favoriteCategories': [
      'AI & Tech',
      'Productivity',
      'Health',
      'Design',
      'Travel',
      'Photography',
      'Music',
      'Reading'
    ],
    'recentActivity': [
      {'type': 'Event', 'title': 'Team Brainstorming', 'time': '2 hours ago'},
      {
        'type': 'Schedule',
        'title': 'Updated work calendar',
        'time': 'Yesterday'
      },
      {'type': 'Chat', 'title': 'Design Team Discussion', 'time': '2 days ago'},
      {'type': 'Event', 'title': 'Product Meeting', 'time': '3 days ago'},
      {
        'type': 'Schedule',
        'title': 'AI-optimized week plan',
        'time': '5 days ago'
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      // Example: fetch user with ID 'alex_morgan'
      if (user != null) {
        // Fetch user document from Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
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
      body: userData == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Stack(
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BackgroundPainter(_animationController.value),
                      size: MediaQuery.of(context).size,
                    );
                  },
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.settings,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildProfileHeader(userData!),
                      const SizedBox(height: 20),
                      buildImpalerBar(),
                      const SizedBox(height: 20),
                      buildFavoriteCategories(userData1),
                      const SizedBox(height: 24),
                      Expanded(child: buildRecentActivity(userData1)),
                      buildLogoutButton(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
