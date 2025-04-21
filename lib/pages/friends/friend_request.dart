import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/pages/friends/AddFriendScreen.dart';
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
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;

  // Data structure to hold user information
  List<Map<String, dynamic>> _friendsList = [];
  List<Map<String, dynamic>> _requestsList = [];

  bool _isLoading = true;
  bool _showRequests = false; // Toggle between friends and requests

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Fetch data on init
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final uid = user.uid;

      // Fetch friends list using the new structure
      final friendsCollection = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .get();

      List<Map<String, dynamic>> friendsList = [];

      // Fetch details for each friend
      for (var friendDoc in friendsCollection.docs) {
        final friendId = friendDoc.id;
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (userData.exists && userData.data() != null) {
          final data = userData.data()!;
          friendsList.add({
            'uid': friendId,
            'name': data['name'] ?? data['userName'] ?? 'Unknown User',
            'photoURL': data['photoURL'] ?? 'https://i.pravatar.cc/300',
            'lastActive': data['lastActive'] ?? 'Recently',
          });
        }
      }

      // Fetch incoming friend requests
      final requestsCollection = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('incomingRequests')
          .get();

      List<Map<String, dynamic>> requestsList = [];

      // Fetch details for each request
      for (var requestDoc in requestsCollection.docs) {
        final requesterId = requestDoc.id;
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(requesterId)
            .get();

        if (userData.exists && userData.data() != null) {
          final data = userData.data()!;
          // Get timestamp from the request document
          final timestamp = requestDoc.data()['timestamp'] as Timestamp?;
          final requestTime =
              timestamp != null ? _formatTimestamp(timestamp) : 'Recently';

          requestsList.add({
            'uid': requesterId,
            'name': data['name'] ?? data['userName'] ?? 'Unknown User',
            'photoURL': data['photoURL'] ?? 'https://i.pravatar.cc/300',
            'requestTime': requestTime,
          });
        }
      }

      if (mounted) {
        setState(() {
          _friendsList = friendsList;
          _requestsList = requestsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  Future<void> acceptFriendRequest(String requesterId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final uid = user.uid;
      final batch = FirebaseFirestore.instance.batch();

      // First get requester data from incoming request
      final requestDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('incomingRequests')
          .doc(requesterId)
          .get();

      final requesterData = requestDoc.data() ?? {};

      // Get current user data
      final currentUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final currentUserData = currentUserDoc.data() ?? {};

      // 1. Add requester to current user's friends collection
      batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('friends')
              .doc(requesterId),
          {
            'timestamp': FieldValue.serverTimestamp(),
            'userName': requesterData['userName'] ?? 'Unknown',
            'email': requesterData['email'] ?? '',
            'photoUrl': requesterData['photoUrl'] ?? '',
          });

      // 2. Add current user to requester's friends collection
      batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(requesterId)
              .collection('friends')
              .doc(uid),
          {
            'timestamp': FieldValue.serverTimestamp(),
            'userName': currentUserData['userName'] ?? 'Unknown',
            'email': currentUserData['email'] ?? '',
            'photoUrl': currentUserData['photoURL'] ?? '',
          });

      // 3. Update friend count in stats collection for both users
      batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('stats')
              .doc('counters'),
          {
            'friendCount': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(requesterId)
              .collection('stats')
              .doc('counters'),
          {
            'friendCount': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      // 4. Delete from current user's incoming requests
      batch.delete(FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('incomingRequests')
          .doc(requesterId));

      // 5. Delete from requester's outgoing requests
      batch.delete(FirebaseFirestore.instance
          .collection('users')
          .doc(requesterId)
          .collection('outgoingRequests')
          .doc(uid));

      // Execute the batch
      await batch.commit();

      // Update local data
      final request = _requestsList.firstWhere(
        (req) => req['uid'] == requesterId,
        orElse: () => {'uid': requesterId, 'name': 'Unknown'},
      );

      setState(() {
        _requestsList.removeWhere((req) => req['uid'] == requesterId);
        _friendsList.add({
          'uid': requesterId,
          'name': request['name'],
          'photoURL': request['photoURL'] ?? 'https://i.pravatar.cc/300',
          'lastActive': 'Just now',
        });
        _isLoading = false;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request accepted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error accepting friend request: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> declineFriendRequest(String requesterId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final uid = user.uid;
      final batch = FirebaseFirestore.instance.batch();

      // 1. Delete from current user's incoming requests
      final incomingRequestRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('incomingRequests')
          .doc(requesterId);

      batch.delete(incomingRequestRef);

      // 2. Delete from requester's outgoing requests
      final outgoingRequestRef = FirebaseFirestore.instance
          .collection('users')
          .doc(requesterId)
          .collection('outgoingRequests')
          .doc(uid);

      batch.delete(outgoingRequestRef);

      // Execute the batch
      await batch.commit();

      // Remove from the requests list
      setState(() {
        _requestsList.removeWhere((request) => request['uid'] == requesterId);
        _isLoading = false;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request declined'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      print('Error declining friend request: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error declining request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> removeFriend(String friendId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final uid = user.uid;
      final batch = FirebaseFirestore.instance.batch();

      // 1. Remove from current user's friends collection
      batch.delete(FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .doc(friendId));

      // 2. Remove from friend's friends collection
      batch.delete(FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(uid));

      // 3. Update friend count in stats collection for both users
      batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('stats')
              .doc('counters'),
          {
            'friendCount': FieldValue.increment(-1),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('stats')
              .doc('counters'),
          {
            'friendCount': FieldValue.increment(-1),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      // Execute the batch
      await batch.commit();

      // Update local data
      setState(() {
        _friendsList.removeWhere((friend) => friend['uid'] == friendId);
        _isLoading = false;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend removed'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      print('Error removing friend: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing friend: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: UberColors.textPrimary,
            onPressed: fetchUserData,
          ),
        ],
      ),
      body: _isLoading
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
                                          if (_requestsList.isNotEmpty)
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
                            ? buildFriendRequests()
                            : buildFriendsList(),
                      ],
                    ),
                  ),
                ))
              ],
            ),
      // FAB to add friends
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFriendPage()),
          ).then((_) => fetchUserData());
        },
        backgroundColor: UberColors.primary,
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  Widget buildFriendsList() {
    if (_friendsList.isEmpty) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFriendPage()),
                  ).then((_) => fetchUserData());
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
                '${_friendsList.length} Friends',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: UberColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFriendPage()),
                  ).then((_) => fetchUserData());
                },
                child: Container(
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _friendsList.length,
            itemBuilder: (context, index) {
              final friend = _friendsList[index];
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
                    // Action buttons
                    Row(
                      children: [
                        // Message button
                        Container(
                          margin: const EdgeInsets.only(right: 8),
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
                        // Remove friend button
                        GestureDetector(
                          onTap: () => _showRemoveFriendDialog(friend),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_remove_outlined,
                              color: Colors.red,
                              size: 18,
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

  Future<void> _showRemoveFriendDialog(Map<String, dynamic> friend) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: UberColors.cardBg,
          title: Text(
            'Remove Friend',
            style: TextStyle(color: UberColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to remove ${friend['name']} from your friends list?',
                  style: TextStyle(color: UberColors.textSecondary),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: UberColors.textSecondary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                removeFriend(friend['uid']);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildFriendRequests() {
    if (_requestsList.isEmpty) {
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
            '${_requestsList.length} Friend ${_requestsList.length == 1 ? 'Request' : 'Requests'}',
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
            itemCount: _requestsList.length,
            itemBuilder: (context, index) {
              final request = _requestsList[index];
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
