import 'package:encite/components/Colors/uber_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Import UberColors from your app
import 'package:encite/pages/home_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      // Fetch friend requests
      final friendRequestsSnapshot = await FirebaseFirestore.instance
          .collection('friendRequests')
          .where('receiverId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      // Fetch group invites
      final groupInvitesSnapshot = await FirebaseFirestore.instance
          .collection('groupInvites')
          .where('receiverId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      // Sample notifications structure
      List<Map<String, dynamic>> notificationsList = [];

      // Process friend requests
      for (var doc in friendRequestsSnapshot.docs) {
        final data = doc.data();
        final senderDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['senderId'])
            .get();

        if (senderDoc.exists && senderDoc.data() != null) {
          final senderData = senderDoc.data()!;
          notificationsList.add({
            'id': doc.id,
            'type': 'friend_request',
            'status': data['status'] ?? 'pending',
            'sender': senderData['name'] ?? 'Unknown User',
            'senderId': data['senderId'],
            'timestamp': data['timestamp'] as Timestamp?,
            'time': data['timestamp'] != null
                ? _formatTimestamp(data['timestamp'] as Timestamp)
                : 'Recently',
            'read': data['read'] ?? false,
            'profilePic': senderData['profilePicUrl'],
          });
        }
      }

      // Process group invites
      for (var doc in groupInvitesSnapshot.docs) {
        final data = doc.data();
        final groupDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(data['groupId'])
            .get();

        if (groupDoc.exists && groupDoc.data() != null) {
          final groupData = groupDoc.data()!;
          notificationsList.add({
            'id': doc.id,
            'type': 'group_invite',
            'status': data['status'] ?? 'pending',
            'sender': groupData['name'] ?? 'Unknown Group',
            'groupId': data['groupId'],
            'timestamp': data['timestamp'] as Timestamp?,
            'time': data['timestamp'] != null
                ? _formatTimestamp(data['timestamp'] as Timestamp)
                : 'Recently',
            'read': data['read'] ?? false,
            'groupImage': groupData['imageUrl'],
          });
        }
      }

      // Add some sample schedule notifications (these would come from your real data)
      // You would implement this based on your actual data model
      notificationsList.add({
        'id': 'sample-schedule-1',
        'type': 'schedule_update',
        'status': 'info',
        'sender': 'Soccer Team',
        'timestamp': Timestamp.now(),
        'time': 'Just now',
        'read': false,
        'message': 'Practice time changed to 5:30 PM tomorrow',
      });

      // Sort by timestamp (most recent first)
      notificationsList.sort((a, b) {
        final aTimestamp = a['timestamp'] as Timestamp?;
        final bTimestamp = b['timestamp'] as Timestamp?;

        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;

        return bTimestamp.compareTo(aTimestamp);
      });

      if (mounted) {
        setState(() {
          _notifications = notificationsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
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
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  Future<void> _markAsRead(String notificationId, String type) async {
    try {
      // Determine which collection to update based on notification type
      String collection;
      if (type == 'friend_request') {
        collection = 'friendRequests';
      } else if (type == 'group_invite') {
        collection = 'groupInvites';
      } else {
        // For other notification types, you might have a different collection
        collection = 'notifications';
      }

      await FirebaseFirestore.instance
          .collection(collection)
          .doc(notificationId)
          .update({
        'read': true,
      });

      // Update local state
      setState(() {
        final index =
            _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['read'] = true;
        }
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String senderId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Update request status
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'read': true,
      });

      // Add to friends collection (both directions)
      final batch = FirebaseFirestore.instance.batch();

      // Current user -> Friend
      final userFriendRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(senderId);

      // Friend -> Current user
      final friendUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('friends')
          .doc(user.uid);

      batch.set(userFriendRef, {
        'userId': senderId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.set(friendUserRef, {
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == requestId);
        if (index != -1) {
          _notifications[index]['status'] = 'accepted';
          _notifications[index]['read'] = true;
        }
      });

      // Show success toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request accepted'),
          backgroundColor: UberColors.accent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error accepting friend request: $e');
      // Show error toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accepting friend request'),
          backgroundColor: UberColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _declineFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(requestId)
          .update({
        'status': 'declined',
        'read': true,
      });

      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == requestId);
        if (index != -1) {
          _notifications[index]['status'] = 'declined';
          _notifications[index]['read'] = true;
        }
      });

      // Show success toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request declined'),
          backgroundColor: UberColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error declining friend request: $e');
      // Show error toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error declining friend request'),
          backgroundColor: UberColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _acceptGroupInvite(String inviteId, String groupId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Update invite status
      await FirebaseFirestore.instance
          .collection('groupInvites')
          .doc(inviteId)
          .update({
        'status': 'accepted',
        'read': true,
      });

      // Add user to group members
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == inviteId);
        if (index != -1) {
          _notifications[index]['status'] = 'accepted';
          _notifications[index]['read'] = true;
        }
      });

      // Show success toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group invite accepted'),
          backgroundColor: UberColors.accent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error accepting group invite: $e');
      // Show error toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accepting group invite'),
          backgroundColor: UberColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _declineGroupInvite(String inviteId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groupInvites')
          .doc(inviteId)
          .update({
        'status': 'declined',
        'read': true,
      });

      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == inviteId);
        if (index != -1) {
          _notifications[index]['status'] = 'declined';
          _notifications[index]['read'] = true;
        }
      });

      // Show success toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group invite declined'),
          backgroundColor: UberColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error declining group invite: $e');
      // Show error toast or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error declining group invite'),
          backgroundColor: UberColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    // Determine icon based on notification type
    IconData getIconForType(String type) {
      switch (type) {
        case 'friend_request':
          return Icons.person_add_alt_1_rounded;
        case 'group_invite':
          return Icons.group_add_rounded;
        case 'schedule_update':
          return Icons.event_note_rounded;
        default:
          return Icons.notifications_rounded;
      }
    }

    // Determine message based on notification type and status
    String getMessageForType(Map<String, dynamic> notification) {
      final type = notification['type'] as String;
      final sender = notification['sender'] as String;
      final status = notification['status'] as String?;

      switch (type) {
        case 'friend_request':
          if (status == 'accepted') {
            return 'You accepted $sender\'s friend request';
          } else if (status == 'declined') {
            return 'You declined $sender\'s friend request';
          } else {
            return '$sender sent you a friend request';
          }
        case 'group_invite':
          if (status == 'accepted') {
            return 'You joined $sender';
          } else if (status == 'declined') {
            return 'You declined the invitation to join $sender';
          } else {
            return 'You were invited to join $sender';
          }
        case 'schedule_update':
          return notification['message'] ?? '$sender schedule has been updated';
        default:
          return 'New notification from $sender';
      }
    }

    // Determine if actions should be shown
    bool shouldShowActions(Map<String, dynamic> notification) {
      final type = notification['type'] as String;
      final status = notification['status'] as String?;

      return (type == 'friend_request' || type == 'group_invite') &&
          status == 'pending' &&
          !(notification['read'] as bool);
    }

    return InkWell(
      onTap: () {
        // Mark as read when tapped
        if (!(notification['read'] as bool)) {
          _markAsRead(notification['id'], notification['type']);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification['read'] as bool
              ? UberColors.surface
              : UberColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification['read'] as bool
                ? UberColors.divider
                : UberColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon or avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: UberColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: notification['profilePic'] != null ||
                          notification['groupImage'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            notification['profilePic'] ??
                                notification['groupImage'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              getIconForType(notification['type']),
                              color: UberColors.primary,
                              size: 20,
                            ),
                          ),
                        )
                      : Icon(
                          getIconForType(notification['type']),
                          color: UberColors.primary,
                          size: 20,
                        ),
                ),

                const SizedBox(width: 16),

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getMessageForType(notification),
                        style: TextStyle(
                          color: UberColors.textPrimary,
                          fontWeight: notification['read'] as bool
                              ? FontWeight.normal
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'],
                        style: const TextStyle(
                          color: UberColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons for friend requests and group invites
            if (shouldShowActions(notification)) ...[
              const SizedBox(height: 12),
              const Divider(color: UberColors.divider, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Decline button
                  OutlinedButton(
                    onPressed: () {
                      if (notification['type'] == 'friend_request') {
                        _declineFriendRequest(notification['id']);
                      } else if (notification['type'] == 'group_invite') {
                        _declineGroupInvite(notification['id']);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: UberColors.textPrimary,
                      side: const BorderSide(color: UberColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 12),
                  // Accept button
                  ElevatedButton(
                    onPressed: () {
                      if (notification['type'] == 'friend_request') {
                        _acceptFriendRequest(
                            notification['id'], notification['senderId']);
                      } else if (notification['type'] == 'group_invite') {
                        _acceptGroupInvite(
                            notification['id'], notification['groupId']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: notification['type'] == 'friend_request'
                          ? UberColors.accent
                          : UberColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      notification['type'] == 'friend_request'
                          ? 'Accept'
                          : 'Join',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UberColors.background,
      appBar: AppBar(
        backgroundColor: UberColors.surface,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: UberColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: UberColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Mark all as read button
          if (_notifications.any((n) => !(n['read'] as bool)))
            IconButton(
              icon: const Icon(Icons.done_all, color: UberColors.primary),
              onPressed: () async {
                try {
                  // Get all unread notifications
                  final unreadNotifications = _notifications
                      .where((n) => !(n['read'] as bool))
                      .toList();

                  // Update Firestore for each notification
                  for (var notification in unreadNotifications) {
                    await _markAsRead(notification['id'], notification['type']);
                  }

                  // Refresh notifications
                  await _fetchNotifications();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications marked as read'),
                      backgroundColor: UberColors.accent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error marking all as read: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error marking notifications as read'),
                      backgroundColor: UberColors.error,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: UberColors.primary,
        backgroundColor: UberColors.surface,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: UberColors.primary,
                ),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: UberColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading notifications',
                          style: TextStyle(
                            color: UberColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UberColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: UberColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: UberColors.divider,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_off_outlined,
                                color: UberColors.textSecondary,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No notifications',
                              style: TextStyle(
                                color: UberColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'You\'re all caught up! We\'ll notify you when there\'s something new.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: UberColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          // Filter options
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: UberColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: UberColors.divider),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.filter_list,
                                  color: UberColors.textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Filter by:',
                                  style: TextStyle(
                                    color: UberColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildFilterChip('All', true),
                                const SizedBox(width: 8),
                                _buildFilterChip('Unread', false),
                                const SizedBox(width: 8),
                                _buildFilterChip('Friend Requests', false),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Notification count
                          Text(
                            '${_notifications.length} Notification${_notifications.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: UberColors.textSecondary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Notification list
                          for (var notification in _notifications)
                            _buildNotificationItem(notification),
                        ],
                      ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? UberColors.primary : UberColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? UberColors.primary : UberColors.divider,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : UberColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
