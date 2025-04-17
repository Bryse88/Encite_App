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
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThanOrEqualTo: searchTerm + '\uf8ff')
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
        final data = doc.data();
        final userId = doc.id;

        if (userId != currentUserUid && !processedIds.contains(userId)) {
          processedIds.add(userId);
          results.add(AppUser.fromFirestore(doc));
        }
      }

      // Get current user's friends to check if already friends
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('friends')
          .get();

      final existingFriendIds = friendsSnapshot.docs
          .map((doc) => doc.data()['uid'] as String)
          .toSet();

      // Filter out existing friends
      final filteredResults = results
          .where((user) => !existingFriendIds.contains(user.uid))
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

      // Create friend request entry in current user's friends subcollection
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'username': user.username,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'status': 'pending_sent',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create friend request received entry in target user's collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friendRequests')
          .doc(currentUser.uid)
          .set({
        'uid': currentUser.uid,
        'username': currentUserData['username'],
        'email': currentUserData['email'],
        'photoUrl': currentUserData['photoUrl'] ?? '',
        'status': 'pending_received',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove from search results
      setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UberColors.background,
      appBar: AppBar(
        backgroundColor: UberColors.background,
        title: Text(
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
            Padding(
              padding: const EdgeInsets.all(16.0),
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
