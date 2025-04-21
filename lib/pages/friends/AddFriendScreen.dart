import 'package:encite/components/Colors/uber_colors.dart' show UberColors;
import 'package:encite/pages/friends/AppUser.dart';
import 'package:encite/pages/friends/LoadingIndictor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  State<AddFriendPage> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppUser> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Maps to track relationship status with each user
  Map<String, String> _relationshipStatus = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounce search to avoid excessive Firestore queries
  Future<void> _onSearchChanged() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.length < 3) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    _performSearch(searchTerm);
  }

  Future<void> _performSearch(String searchTerm) async {
    if (searchTerm.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUserUid = _auth.currentUser?.uid;
      if (currentUserUid == null) {
        throw Exception('User not authenticated');
      }

      // Query for username matches
      final usernameQuery = await _firestore
          .collection('users')
          .where('userName', isGreaterThanOrEqualTo: searchTerm)
          .where('userName', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .get();

      // Query for email matches
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: searchTerm)
          .where('email', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .get();

      // Combine results, remove duplicates, and filter out current user
      final Set<String> processedIds = {};
      final List<AppUser> results = [];

      for (final doc in [...usernameQuery.docs, ...emailQuery.docs]) {
        final userId = doc.id;

        if (userId != currentUserUid && !processedIds.contains(userId)) {
          processedIds.add(userId);
          results.add(AppUser.fromFirestore(doc));
        }
      }

      // Now check relationship status with each user
      _relationshipStatus = {};

      // Check friends collection
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('friends')
          .get();

      Set<String> friendIds = {};
      for (var doc in friendsSnapshot.docs) {
        friendIds.add(doc.id);
      }

      // Check outgoing requests
      final outgoingRequestsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('outgoingRequests')
          .get();

      Set<String> outgoingRequestIds = {};
      for (var doc in outgoingRequestsSnapshot.docs) {
        outgoingRequestIds.add(doc.id);
      }

      // Check incoming requests
      final incomingRequestsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('incomingRequests')
          .get();

      Set<String> incomingRequestIds = {};
      for (var doc in incomingRequestsSnapshot.docs) {
        incomingRequestIds.add(doc.id);
      }

      // Update relationship status for each user
      for (var user in results) {
        if (friendIds.contains(user.uid)) {
          _relationshipStatus[user.uid] = 'friend';
        } else if (outgoingRequestIds.contains(user.uid)) {
          _relationshipStatus[user.uid] = 'pending_sent';
        } else if (incomingRequestIds.contains(user.uid)) {
          _relationshipStatus[user.uid] = 'pending_received';
        } else {
          _relationshipStatus[user.uid] = 'none';
        }
      }

      // Filter out users who are already friends or have pending requests
      final filteredResults = results
          .where((user) => _relationshipStatus[user.uid] == 'none')
          .toList();

      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching for users: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(AppUser user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get current user data
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final currentUserData = currentUserDoc.data();

      if (currentUserData == null) {
        throw Exception('Current user data not found');
      }

      final batch = _firestore.batch();

      // Create outgoing request in current user's outgoingRequests collection
      batch.set(
          _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('outgoingRequests')
              .doc(user.uid),
          {
            'timestamp': FieldValue.serverTimestamp(),
            'userName': user.username,
            'email': user.email,
            'photoUrl': user.photoUrl ?? '',
          });

      // Create incoming request in target user's incomingRequests collection
      batch.set(
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('incomingRequests')
              .doc(currentUser.uid),
          {
            'timestamp': FieldValue.serverTimestamp(),
            'userName': currentUserData['userName'] ?? '',
            'email': currentUserData['email'] ?? '',
            'photoUrl': currentUserData['photoURL'] ?? '',
          });

      // Execute the batch operation
      await batch.commit();

      // Update relationship status and remove from search results
      setState(() {
        _relationshipStatus[user.uid] = 'pending_sent';
        _searchResults.removeWhere((result) => result.uid == user.uid);
        _isLoading = false;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request sent to ${user.username}'),
          backgroundColor: UberColors.accent,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending friend request: ${e.toString()}';
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send friend request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _acceptFriendRequest(AppUser user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();

      // 1. Add to current user's friends collection
      batch.set(
          _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('friends')
              .doc(user.uid),
          {
            'timestamp': FieldValue.serverTimestamp(),
            'userName': user.username,
            'email': user.email,
            'photoUrl': user.photoUrl ?? '',
          });

      // 2. Add to user's friends collection
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final currentUserData = currentUserDoc.data();

      if (currentUserData == null) {
        throw Exception('Current user data not found');
      }

      batch.set(
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('friends')
              .doc(currentUser.uid),
          {
            'timestamp': FieldValue.serverTimestamp(),
            'userName': currentUserData['userName'] ?? '',
            'email': currentUserData['email'] ?? '',
            'photoUrl': currentUserData['photoURL'] ?? '',
          });

      // 3. Update friend count in stats collection for both users
      batch.set(
          _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('stats')
              .doc('counters'),
          {
            'friendCount': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      batch.set(
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('stats')
              .doc('counters'),
          {
            'friendCount': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      // 4. Delete from incomingRequests and outgoingRequests
      batch.delete(_firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('incomingRequests')
          .doc(user.uid));

      batch.delete(_firestore
          .collection('users')
          .doc(user.uid)
          .collection('outgoingRequests')
          .doc(currentUser.uid));

      // Execute batch
      await batch.commit();

      // Update UI
      setState(() {
        _relationshipStatus[user.uid] = 'friend';
        _searchResults.removeWhere((result) => result.uid == user.uid);
        _isLoading = false;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now friends with ${user.username}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error accepting friend request: ${e.toString()}';
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept friend request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _declineFriendRequest(AppUser user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();

      // Delete from incomingRequests and outgoingRequests
      batch.delete(_firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('incomingRequests')
          .doc(user.uid));

      batch.delete(_firestore
          .collection('users')
          .doc(user.uid)
          .collection('outgoingRequests')
          .doc(currentUser.uid));

      // Execute batch
      await batch.commit();

      // Update UI
      setState(() {
        _relationshipStatus[user.uid] = 'none';
        _isLoading = false;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request declined'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error declining friend request: ${e.toString()}';
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline friend request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelFriendRequest(AppUser user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();

      // Delete from outgoingRequests and incomingRequests
      batch.delete(_firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('outgoingRequests')
          .doc(user.uid));

      batch.delete(_firestore
          .collection('users')
          .doc(user.uid)
          .collection('incomingRequests')
          .doc(currentUser.uid));

      // Execute batch
      await batch.commit();

      // Update UI
      setState(() {
        _relationshipStatus[user.uid] = 'none';
        _isLoading = false;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request canceled'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error canceling friend request: ${e.toString()}';
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel friend request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UberColors.background,
      appBar: AppBar(
        backgroundColor: UberColors.background,
        title: const Text(
          'Add Friends',
          style: TextStyle(color: UberColors.textPrimary),
        ),
        iconTheme: IconThemeData(color: UberColors.textPrimary),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username or email',
                hintStyle: TextStyle(color: UberColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: UberColors.textSecondary),
                filled: true,
                fillColor: UberColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              style: TextStyle(color: UberColors.textPrimary),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_isLoading)
            const LoadingIndicator()
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No users found',
                style: TextStyle(color: UberColors.textSecondary),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return UserSearchResultTile(
                    user: user,
                    onAddFriend: () => _sendFriendRequest(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class UserSearchResultTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onAddFriend;

  const UserSearchResultTile({
    Key? key,
    required this.user,
    required this.onAddFriend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: UberColors.accent,
        backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null || user.photoUrl!.isEmpty
            ? Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Text(
        user.username,
        style: TextStyle(color: UberColors.textPrimary),
      ),
      subtitle: Text(
        user.email,
        style: TextStyle(color: UberColors.textSecondary),
      ),
      trailing: ElevatedButton(
        onPressed: onAddFriend,
        style: ElevatedButton.styleFrom(
          backgroundColor: UberColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Add Friend'),
      ),
    );
  }
}
