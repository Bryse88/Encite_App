import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/ProfileComponents/ExtraPages/AddFriendScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encite/components/Colors/uber_colors.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Add this to implement AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;
  Map<String, dynamic>? userData; // nullable to allow loading
  bool _isDataInitialized = false;
  bool _showRequests = false; // Toggle between friends and requests

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

      // Fetch friends list
      final friendsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('friendsList')
          .get();

      final List<Map<String, dynamic>> friendsList = [];
      final List<dynamic> friendsIds = friendsDoc.exists
          ? List<dynamic>.from(friendsDoc.data()?['friends'] ?? [])
          : <dynamic>[];

      // Fetch friend requests
      final requestsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('requests')
          .get();

      final List<Map<String, dynamic>> requestsList = [];
      final List<dynamic> requestsIds = requestsDoc.exists
          ? List<dynamic>.from(requestsDoc.data()?['pending'] ?? [])
          : <dynamic>[];

      // Fetch friend details
      for (final friendId in friendsIds) {
        final friendData = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (friendData.exists) {
          friendsList.add({
            'uid': friendId,
            'name': friendData.data()?['name'] ?? 'Unknown User',
            'photoURL':
                friendData.data()?['photoURL'] ?? 'https://i.pravatar.cc/300',
            'lastActive': friendData.data()?['lastActive'] ?? 'Recently',
          });
        }
      }

      // Fetch request details
      for (final requestId in requestsIds) {
        final requestData = await FirebaseFirestore.instance
            .collection('users')
            .doc(requestId)
            .get();

        if (requestData.exists) {
          requestsList.add({
            'uid': requestId,
            'name': requestData.data()?['name'] ?? 'Unknown User',
            'photoURL':
                requestData.data()?['photoURL'] ?? 'https://i.pravatar.cc/300',
            'requestTime':
                'Today', // You might want to fetch the actual request time
          });
        }
      }

      if (mounted) {
        setState(() {
          userData = {
            'uid': uid,
            ...?userDoc.data() as Map<String, dynamic>?,
            'friendsList': friendsList,
            'requestsList': requestsList,
          };
          _isDataInitialized = true;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      // Get current friend requests
      final requestsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('requests')
          .get();

      final List<dynamic> currentRequests = requestsDoc.exists
          ? List<dynamic>.from(requestsDoc.data()?['pending'] ?? [])
          : <dynamic>[];

      // Remove from requests
      currentRequests.remove(requestId);

      // Update requests document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('requests')
          .set({
        'pending': currentRequests,
      });

      // Get current friends list
      final friendsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('friendsList')
          .get();

      final List<dynamic> currentFriends = friendsDoc.exists
          ? List<dynamic>.from(friendsDoc.data()?['friends'] ?? [])
          : <dynamic>[];

      // Add to friends list
      currentFriends.add(requestId);

      // Update friends document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('friendsList')
          .set({
        'friends': currentFriends,
      });

      // Also add the current user to the requester's friends list
      final requesterFriendsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(requestId)
          .collection('friends')
          .doc('friendsList')
          .get();

      final List<dynamic> requesterFriends = requesterFriendsDoc.exists
          ? List<dynamic>.from(requesterFriendsDoc.data()?['friends'] ?? [])
          : <dynamic>[];

      requesterFriends.add(uid);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(requestId)
          .collection('friends')
          .doc('friendsList')
          .set({
        'friends': requesterFriends,
      });

      // Refresh the UI
      fetchUserData();
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      // Get current friend requests
      final requestsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('requests')
          .get();

      final List<dynamic> currentRequests = requestsDoc.exists
          ? List<dynamic>.from(requestsDoc.data()?['pending'] ?? [])
          : <dynamic>[];

      // Remove from requests
      currentRequests.remove(requestId);

      // Update requests document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc('requests')
          .set({
        'pending': currentRequests,
      });

      // Refresh the UI
      fetchUserData();
    } catch (e) {
      print('Error declining friend request: $e');
    }
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
      appBar: AppBar(
        backgroundColor: UberColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: UberColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Friends',
          style: TextStyle(
            color: UberColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
                    // Content
                    child: SingleChildScrollView(
                  // Wrap the entire content here
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 32.0), // optional bottom padding
                    child: Column(
                      children: [
                        // Header with title and back button

                        // Toggle buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: UberColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showRequests = false;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !_showRequests
                                            ? UberColors.primary
                                                .withOpacity(0.1)
                                            : UberColors.cardBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Friends',
                                          style: TextStyle(
                                            color: !_showRequests
                                                ? UberColors.primary
                                                : UberColors.textSecondary,
                                            fontWeight: !_showRequests
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showRequests = true;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _showRequests
                                            ? UberColors.primary
                                                .withOpacity(0.1)
                                            : UberColors.cardBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              'Requests',
                                              style: TextStyle(
                                                color: _showRequests
                                                    ? UberColors.primary
                                                    : UberColors.textSecondary,
                                                fontWeight: _showRequests
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if ((userData?['requestsList'] ?? [])
                                              .isNotEmpty)
                                            Positioned(
                                              right: 20,
                                              top: 15,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: UberColors.error,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Friends list or Requests list
                        _showRequests
                            ? buildFriendRequests(userData!)
                            : buildFriendsList(userData!),
                      ],
                    ),
                  ),
                ))
              ],
            ),
    );
  }

  Widget buildFriendsList(Map<String, dynamic> userData) {
    final List<Map<String, dynamic>> friendsList =
        List<Map<String, dynamic>>.from(userData['friendsList'] ?? []);

    if (friendsList.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_outline_rounded,
                color: UberColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'No friends yet',
                style: TextStyle(
                  color: UberColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add some friends to connect',
                style: TextStyle(
                  color: UberColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  print('Navigate to friends page');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFriendPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: UberColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Find Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${friendsList.length} Friends',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: UberColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: UberColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      color: UberColors.primary,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Add Friend',
                      style: TextStyle(
                        color: UberColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: friendsList.length,
            itemBuilder: (context, index) {
              final friend = friendsList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: UberColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: UberColors.divider,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: UberColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(friend['photoURL']),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: UberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                friend['lastActive'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: UberColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: UberColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.message_outlined,
                        color: UberColors.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildFriendRequests(Map<String, dynamic> userData) {
    final List<Map<String, dynamic>> requestsList =
        List<Map<String, dynamic>>.from(userData['requestsList'] ?? []);

    if (requestsList.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: UberColors.textSecondary,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'No pending requests',
                style: TextStyle(
                  color: UberColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You\'re all caught up!',
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${requestsList.length} Friend Requests',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: UberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requestsList.length,
            itemBuilder: (context, index) {
              final request = requestsList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: UberColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: UberColors.divider,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: UberColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(request['photoURL']),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: UberColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sent request ${request['requestTime']}',
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => declineFriendRequest(request['uid']),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: UberColors.divider,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Decline',
                                  style: TextStyle(
                                    color: UberColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => acceptFriendRequest(request['uid']),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: UberColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Accept',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
