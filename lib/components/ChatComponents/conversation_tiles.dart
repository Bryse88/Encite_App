import 'dart:ui';

import 'package:encite/components/ChatComponents/chat_models.dart';
import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final String Function(DateTime) formatTimestamp;

  const ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = conversation.getDisplayName(currentUserId);
    final photoURL = conversation.getPhotoURL(currentUserId);

    // Get the timestamp for the last message
    final timestamp = conversation.lastMessageTimestamp;
    final formattedTime = formatTimestamp(timestamp);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
        backgroundColor: Colors.blue,
        child: photoURL.isEmpty
            ? conversation.isGroup
                ? const Icon(Icons.group, color: Colors.white)
                : Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formattedTime,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
