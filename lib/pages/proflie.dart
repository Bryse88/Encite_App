import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/MainComponents/background_painter.dart';
import 'package:encite/components/ProfileComponents/Widgets/favorite_categories.dart';
import 'package:encite/components/ProfileComponents/Widgets/impaler_bar.dart';
import 'package:encite/components/ProfileComponents/Widgets/logout_button.dart';
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
      if (user == null) return;

      final uid = user.uid; // ✅ Keep this for reuse

      // Fetch base user doc
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Fetch onboarding subcollection
      final onboardingDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('onboarding')
          .doc('identityTags')
          .get();

      final identityTags = onboardingDoc.exists
          ? List<String>.from(onboardingDoc.data()?['tags'] ?? [])
          : <String>[];

      setState(() {
        userData = {
          'uid': uid,
          ...?userDoc.data() as Map<String, dynamic>?,
          'identityTags': identityTags,
        };
      });
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
                // Animated background
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BackgroundPainter(_animationController.value),
                      size: MediaQuery.of(context).size,
                    );
                  },
                ),
                // Content
                SafeArea(
                  child: Column(
                    children: [
                      // Header with title and settings button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
                                onPressed: () {
                                  Navigator.pushNamed(context, '/settings');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Profile header (avatar, name, stats)
                              buildProfileHeader(userData!),
                              const SizedBox(height: 20),
                              // Impaler bar (visual element)
                              buildImpalerBar(),
                              const SizedBox(height: 20),
                              // Identity tags section
                              buildIdentityTags(userData!),
                              const SizedBox(height: 24),
                              // Recent activity section with proper padding
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display recent activity list without Expanded
                                    Container(
                                      // Use fixed height instead of Expanded
                                      constraints: const BoxConstraints(
                                        minHeight:
                                            200, // Minimum height for content
                                        maxHeight:
                                            400, // Maximum height before scrolling
                                      ),
                                      child:
                                          buildRecentActivityFixed(userData1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Logout button
                              buildLogoutButton(context),
                              // Add some padding at the bottom
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Modified version of recent activity that doesn't use Expanded
  Widget buildRecentActivityFixed(Map<String, dynamic> userData) {
    final recentActivity = userData['recentActivity'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Important: don't try to take all space
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        // Use ListView.builder directly
        ListView.builder(
          shrinkWrap: true, // Important: wrap content, don't expand
          physics:
              const NeverScrollableScrollPhysics(), // Don't allow this ListView to scroll
          itemCount: recentActivity.length,
          itemBuilder: (context, index) {
            final activity = recentActivity[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActivityIcon(activity['type']),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['time'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'Event':
        iconData = Icons.event;
        iconColor = Colors.blue;
        break;
      case 'Chat':
        iconData = Icons.chat_bubble;
        iconColor = Colors.green;
        break;
      case 'Schedule':
        iconData = Icons.calendar_today;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.circle;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 18,
      ),
    );
  }
}
