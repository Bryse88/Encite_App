import 'package:flutter/material.dart';
import 'package:encite/components/Colors/uber_colors.dart';

/// Enhanced user availability model that supports Outlook-style availability states
class UserAvailability {
  final String userId;
  final String name;
  final String? avatar;
  final AvailabilityStatus status;
  final String? statusMessage;
  final DateTime? lastActive;

  UserAvailability({
    required this.userId,
    required this.name,
    this.avatar,
    required this.status,
    this.statusMessage,
    this.lastActive,
  });
}

/// Enum representing different availability statuses
enum AvailabilityStatus {
  available,
  busy,
  away,
  doNotDisturb,
  offline,
  inMeeting,
  outOfOffice,
}

/// Extension to get color and icon for each availability status
extension AvailabilityStatusExtension on AvailabilityStatus {
  Color get color {
    switch (this) {
      case AvailabilityStatus.available:
        return UberColors.accent; // Green
      case AvailabilityStatus.busy:
        return Colors.red;
      case AvailabilityStatus.away:
        return Colors.amber;
      case AvailabilityStatus.doNotDisturb:
        return Colors.red.shade800;
      case AvailabilityStatus.offline:
        return UberColors.textSecondary;
      case AvailabilityStatus.inMeeting:
        return Colors.purple;
      case AvailabilityStatus.outOfOffice:
        return Colors.deepOrange;
    }
  }

  IconData get icon {
    switch (this) {
      case AvailabilityStatus.available:
        return Icons.check_circle_outline;
      case AvailabilityStatus.busy:
        return Icons.schedule;
      case AvailabilityStatus.away:
        return Icons.access_time;
      case AvailabilityStatus.doNotDisturb:
        return Icons.do_not_disturb_on;
      case AvailabilityStatus.offline:
        return Icons.offline_bolt;
      case AvailabilityStatus.inMeeting:
        return Icons.groups;
      case AvailabilityStatus.outOfOffice:
        return Icons.beach_access;
    }
  }

  String get label {
    switch (this) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.busy:
        return 'Busy';
      case AvailabilityStatus.away:
        return 'Away';
      case AvailabilityStatus.doNotDisturb:
        return 'Do not disturb';
      case AvailabilityStatus.offline:
        return 'Offline';
      case AvailabilityStatus.inMeeting:
        return 'In a meeting';
      case AvailabilityStatus.outOfOffice:
        return 'Out of office';
    }
  }
}

/// Widget for displaying a user's availability avatar with status indicator
class AvailabilityAvatarWidget extends StatelessWidget {
  final UserAvailability user;
  final double radius;
  final VoidCallback? onTap;
  final bool showStatusLabel;

  const AvailabilityAvatarWidget({
    super.key,
    required this.user,
    this.radius = 18,
    this.onTap,
    this.showStatusLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: UberColors.background,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Avatar
            CircleAvatar(
              radius: radius,
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              backgroundColor: UberColors.surface,
              child: user.avatar == null
                  ? Icon(
                      Icons.person,
                      color: UberColors.textSecondary,
                      size: radius * 0.8,
                    )
                  : null,
            ),

            // Status indicator
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: radius * 0.6,
                height: radius * 0.6,
                decoration: BoxDecoration(
                  color: user.status.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: UberColors.background, width: 1.5),
                ),
              ),
            ),

            // Optional status label
            if (showStatusLabel)
              Positioned(
                bottom: -22,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    user.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: user.status.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a list of friends with their availability
class AvailableFriendsWidget extends StatelessWidget {
  final List<UserAvailability> friends;
  final VoidCallback? onViewAllTap;
  final Function(UserAvailability)? onFriendTap;

  const AvailableFriendsWidget({
    super.key,
    required this.friends,
    this.onViewAllTap,
    this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    // Count available friends
    final availableFriends = friends
        .where(
          (f) => f.status == AvailabilityStatus.available,
        )
        .length;

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
                'Friends',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: UberColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: UberColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stack of avatars (shows overlap effect)
          SizedBox(
            height: 48,
            child: Stack(
              children: List.generate(friends.length > 5 ? 5 : friends.length,
                  (index) {
                final friend = friends[index];
                return Positioned(
                  left: index * 36.0,
                  child: AvailabilityAvatarWidget(
                    user: friend,
                    onTap: () {
                      if (onFriendTap != null) {
                        onFriendTap!(friend);
                      }
                    },
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Status summary text
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: UberColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$availableFriends Available',
                style: const TextStyle(
                  color: UberColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${friends.length - availableFriends} Busy',
                style: const TextStyle(
                  color: UberColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Enhanced friend list widget with detailed availability view
class FriendDetailListWidget extends StatelessWidget {
  final List<UserAvailability> friends;
  final Function(UserAvailability)? onFriendTap;

  const FriendDetailListWidget({
    super.key,
    required this.friends,
    this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Friends',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: UberColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Categorized friend lists
          _buildAvailabilitySection(
            'Available',
            friends
                .where((f) => f.status == AvailabilityStatus.available)
                .toList(),
          ),

          const SizedBox(height: 16),

          _buildAvailabilitySection(
            'Busy',
            friends
                .where((f) =>
                    f.status == AvailabilityStatus.busy ||
                    f.status == AvailabilityStatus.inMeeting ||
                    f.status == AvailabilityStatus.doNotDisturb)
                .toList(),
          ),

          const SizedBox(height: 16),

          _buildAvailabilitySection(
            'Away',
            friends
                .where((f) =>
                    f.status == AvailabilityStatus.away ||
                    f.status == AvailabilityStatus.outOfOffice)
                .toList(),
          ),

          const SizedBox(height: 16),

          _buildAvailabilitySection(
            'Offline',
            friends
                .where((f) => f.status == AvailabilityStatus.offline)
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(
      String title, List<UserAvailability> sectionFriends) {
    if (sectionFriends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: title == 'Available'
                ? UberColors.accent
                : title == 'Busy'
                    ? Colors.red
                    : title == 'Away'
                        ? Colors.amber
                        : UberColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...sectionFriends.map((friend) => _buildFriendTile(friend)).toList(),
      ],
    );
  }

  Widget _buildFriendTile(UserAvailability friend) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          AvailabilityAvatarWidget(
            user: friend,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: UberColors.textPrimary,
                  ),
                ),
                if (friend.statusMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    friend.statusMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: UberColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Status icon
          Icon(
            friend.status.icon,
            size: 16,
            color: friend.status.color,
          ),
        ],
      ),
    );
  }
}
