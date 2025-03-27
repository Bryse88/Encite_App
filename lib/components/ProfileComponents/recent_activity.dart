import 'dart:ui';
import 'package:flutter/material.dart';

Widget buildRecentActivity(Map<String, dynamic> userData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          'Recent Activity',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: userData['recentActivity'].length,
          itemBuilder: (context, index) {
            final activity = userData['recentActivity'][index];
            return buildActivityItem(activity, index);
          },
        ),
      ),
    ],
  );
}

Widget buildActivityItem(Map<String, String> activity, int index) {
  IconData activityIcon;
  Color activityColor;

  switch (activity['type']) {
    case 'Event':
      activityIcon = Icons.event;
      activityColor = const Color(0xFF5AC8FA);
      break;
    case 'Schedule':
      activityIcon = Icons.schedule;
      activityColor = const Color(0xFF4CD964);
      break;
    case 'Chat':
      activityIcon = Icons.chat_bubble;
      activityColor = const Color(0xFFFF9500);
      break;
    default:
      activityIcon = Icons.star;
      activityColor = const Color(0xFF007AFF);
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activityColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activityIcon,
                  color: activityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['time']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
