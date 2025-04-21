import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/LoginComponents/AuthenticationServices/auth_wrapper.dart';
import 'package:encite/components/ProfileComponents/ExtraPages/EditProfilePage.dart';
import 'package:encite/pages/friends/friend_request.dart';
import 'package:encite/pages/group_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encite/components/Colors/uber_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;
  Map<String, dynamic>? userData; // nullable to allow loading
  bool _isDataInitialized = false;

  // Counters for statistics
  int _friendsCount = 0;
  int _groupsCount = 0;
  int _schedulesCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Only fetch data if it hasn't been initialized yet
    if (!_isDataInitialized) {
      fetchUserData();
    }
  }

  Future<void> signUserOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sessionLogs')
          .add({
        'type': 'logout',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<void> fetchUserData() async {
    // Don't fetch if data is already loaded
    if (_isDataInitialized) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

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

      // Fetch user stats for friend count and other metrics
      final statsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('stats')
          .doc('counters')
          .get();

      // Get friend count from stats
      int friendsCount = 0;
      int groupsCount = 0;
      int schedulesCount = 0;

      if (statsDoc.exists) {
        // Use stored counters directly
        friendsCount = statsDoc.data()?['friendCount'] ?? 0;
        groupsCount = statsDoc.data()?['groupCount'] ?? 0;
        schedulesCount = statsDoc.data()?['scheduleCount'] ?? 0;
      } else {
        // Initialize counters document if it doesn't exist yet
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('stats')
            .doc('counters')
            .set({
          'friendCount': 0,
          'groupCount': 0,
          'scheduleCount': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Counters are all 0 since we just initialized them
      }

      // Fetch recent activity (optional)
      final activityQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('activity')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> recentActivity = [];

      for (var doc in activityQuery.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;

        recentActivity.add({
          'id': doc.id,
          'type': data['type'] ?? 'Event',
          'title': data['title'] ?? 'Unknown activity',
          'time': timestamp != null ? _formatTimestamp(timestamp) : 'Recently',
        });
      }

      if (mounted) {
        setState(() {
          userData = {
            'uid': uid,
            ...?userDoc.data() as Map<String, dynamic>?,
            'identityTags': identityTags,
            'recentActivity': recentActivity,
          };
          _friendsCount = friendsCount;
          _groupsCount = groupsCount;
          _schedulesCount = schedulesCount;
          _isDataInitialized = true;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Helper function to format timestamps
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
  }

  void navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  Future<void> navigateToFriendsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FriendsPage()),
    );

    // Refresh friend count when returning from FriendsPage
    refreshFriendsCount();
  }

  // Method to refresh just the friend count
  Future<void> refreshFriendsCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      // Get the stats document with the counter
      final statsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('stats')
          .doc('counters')
          .get();

      if (statsDoc.exists) {
        final friendsCount = statsDoc.data()?['friendCount'] ?? 0;

        if (mounted) {
          setState(() {
            _friendsCount = friendsCount;
          });
        }
      }
    } catch (e) {
      print('Error refreshing friends count: $e');
    }
  }

  void navigateToGroupsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupsPage()),
    );
  }

  void navigateToSchedulesPage() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const SchedulesPage()),
    // );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: UberColors.background,
      body: userData == null
          ? const Center(
              child: CircularProgressIndicator(
                color: UberColors.primary,
                strokeWidth: 2.5,
              ),
            )
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [UberColors.background, Color(0xFF0A0A0A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                SafeArea(
                    child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      children: [
                        // Header with title and settings button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  color: UberColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: UberColors.cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.settings_outlined,
                                    color: UberColors.textPrimary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/settings');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Scrollable content
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Profile header (avatar, name, stats)
                              buildProfileHeader(userData!),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              // Impaler bar (visual element)
                              buildImpalerBar(),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              // Identity tags section
                              buildIdentityTags(userData!),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              // Recent activity section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 200,
                                        maxHeight: 400,
                                      ),
                                      child:
                                          buildRecentActivityFixed(userData!),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              // Logout button
                              buildLogoutButton(context),
                              // Bottom padding
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
    );
  }

  Widget buildProfileHeader(Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'User';
    final username = userData['userName'] ?? '@username';
    final profileImage = userData['photoURL'] ?? 'https://i.pravatar.cc/300';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image with elegant border
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: UberColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profileImage),
                ),
              ),
              const SizedBox(width: 20),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: UberColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 14,
                        color: UberColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Uber-inspired profile button
                    GestureDetector(
                      onTap: navigateToEditProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: UberColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: UberColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildImpalerBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: navigateToGroupsPage,
            child: _buildStat(_groupsCount.toString(), 'Groups'),
          ),
          _buildVerticalDivider(),
          GestureDetector(
            onTap: navigateToFriendsPage,
            child: _buildStat(_friendsCount.toString(), 'Friends'),
          ),
          _buildVerticalDivider(),
          GestureDetector(
            onTap: navigateToSchedulesPage,
            child: _buildStat(_schedulesCount.toString(), 'Schedules'),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: UberColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: UberColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: UberColors.divider,
    );
  }

  Widget buildIdentityTags(Map<String, dynamic> userData) {
    final List<String> tags = userData['identityTags'] ?? [];

    if (tags.isEmpty) {
      tags.addAll(['Design', 'Technology', 'Product', 'UX/UI', 'Innovation']);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: UberColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: tags.map((tag) => _buildIdentityTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: UberColors.divider,
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: UberColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildRecentActivityFixed(Map<String, dynamic> userData) {
    // Check if we have any recent activity data
    final recentActivity = userData['recentActivity'] as List<dynamic>?;

    if (recentActivity == null || recentActivity.isEmpty) {
      // If no data, return empty state
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty_outlined,
                color: UberColors.textSecondary,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'No recent activity',
                style: TextStyle(
                  color: UberColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your recent interactions will appear here',
                style: TextStyle(
                  color: UberColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: UberColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentActivity.length,
          itemBuilder: (context, index) {
            final activity = recentActivity[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: UberColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: UberColors.divider,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActivityIcon(activity['type']),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: UberColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity['time'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: UberColors.textSecondary,
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
        iconData = Icons.event_outlined;
        iconColor = UberColors.primary;
        break;
      case 'Chat':
        iconData = Icons.chat_bubble_outline_rounded;
        iconColor = UberColors.accent;
        break;
      case 'Schedule':
        iconData = Icons.calendar_today_outlined;
        iconColor = const Color(0xFFFFC043); // Amber
        break;
      default:
        iconData = Icons.circle_outlined;
        iconColor = UberColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: UberColors.error.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await signUserOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
              );
            },
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: UberColors.error,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: UberColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
