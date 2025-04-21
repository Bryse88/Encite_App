// Add this widget to your home_page.dart file
// This can be placed just after the LocationWidget or wherever you want it to appear in your layout

import 'package:encite/components/Colors/uber_colors.dart';
import 'package:flutter/material.dart';

Widget _buildNotificationsWidget() {
  // Sample notification data - in real app, fetch from Firestore
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'friend_request',
      'sender': 'Jamie Lee',
      'time': '2 hours ago',
      'read': false,
    },
    {
      'type': 'group_invite',
      'sender': 'Study Group',
      'time': 'Yesterday',
      'read': true,
    },
    {
      'type': 'schedule_update',
      'sender': 'Soccer Team',
      'time': '3 days ago',
      'read': true,
    },
  ];

  return Container(
    padding: const EdgeInsets.all(20),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: UberColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: UberColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_notifications.where((n) => !n['read']).length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notifications list
        _notifications.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No notifications',
                    style: TextStyle(
                      color: UberColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            : Column(
                children: _notifications.map((notification) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildNotificationItem(notification),
                  );
                }).toList(),
              ),

        // View all button
        if (_notifications.isNotEmpty)
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to notifications page
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: UberColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildNotificationItem(Map<String, dynamic> notification) {
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

  String getMessageForType(String type, String sender) {
    switch (type) {
      case 'friend_request':
        return '$sender sent you a friend request';
      case 'group_invite':
        return 'You were invited to join $sender';
      case 'schedule_update':
        return '$sender schedule has been updated';
      default:
        return 'New notification from $sender';
    }
  }

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: notification['read']
          ? UberColors.surface
          : UberColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: notification['read']
            ? UberColors.divider
            : UberColors.primary.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notification icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: UberColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            getIconForType(notification['type']),
            color: UberColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),

        // Notification content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getMessageForType(notification['type'], notification['sender']),
                style: TextStyle(
                  color: UberColors.textPrimary,
                  fontWeight: notification['read']
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

        // Action button
        if (notification['type'] == 'friend_request' && !notification['read'])
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: UberColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.check,
                    color: UberColors.accent,
                    size: 16,
                  ),
                  onPressed: () {
                    // Accept friend request logic
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: UberColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.close,
                    color: UberColors.error,
                    size: 16,
                  ),
                  onPressed: () {
                    // Decline friend request logic
                  },
                ),
              ),
            ],
          ),
      ],
    ),
  );
}
