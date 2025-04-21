// chat_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ConversationType { oneOnOne, group }

enum MessageType { text, image, file }

enum MessageStatus { sent, delivered, read }

class Conversation {
  final String id;
  final ConversationType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final List<String> participantIds;
  final Map<String, ParticipantInfo> participants;
  final String? groupName;
  final String? groupPhoto;

  Conversation({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.participantIds,
    required this.participants,
    this.groupName,
    this.groupPhoto,
  });

  bool get isGroup => type == ConversationType.group;

  factory Conversation.fromFirestore(
      DocumentSnapshot doc, Map<String, ParticipantInfo> participantsInfo) {
    final data = doc.data() as Map<String, dynamic>;

    return Conversation(
      id: doc.id,
      type: data['type'] == 'group'
          ? ConversationType.group
          : ConversationType.oneOnOne,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp:
          (data['lastMessageTimestamp'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      participantIds: List<String>.from(data['participants'] ?? []),
      participants: participantsInfo,
      groupName: data['groupName'],
      groupPhoto: data['groupPhoto'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type == ConversationType.group ? 'group' : 'one_on_one',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'participants': participantIds,
      if (groupName != null) 'groupName': groupName,
      if (groupPhoto != null) 'groupPhoto': groupPhoto,
    };
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  String getDisplayName(String currentUserId) {
    // For group conversations, show the group name
    if (isGroup) {
      return groupName ?? 'Group Chat';
    }

    // For one-on-one conversations, show the other person's name
    else {
      // Find the participant who is not the current user
      final otherParticipantId = participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherParticipantId.isEmpty) {
        return 'Unknown User';
      }

      // Get the participant info from the participants map
      final participantInfo = participants[otherParticipantId];
      if (participantInfo == null) {
        return 'Unknown User';
      }

      return participantInfo.displayName;
    }
  }

  String getPhotoURL(String currentUserId) {
    if (isGroup) {
      return groupPhoto ?? '';
    } else {
      final otherParticipantId = participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      return participants[otherParticipantId]?.photoURL ?? '';
    }
  }
}

class ParticipantInfo {
  final String displayName;
  final String photoURL;
  final DateTime lastSeen;
  final bool typing;
  final String role;
  final DateTime joinedAt;

  ParticipantInfo({
    this.displayName = '',
    this.photoURL = '',
    required this.lastSeen,
    required this.typing,
    this.role = 'member',
    required this.joinedAt,
  });

  factory ParticipantInfo.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print("DEBUG - Participant data: $data"); // Add this line
    return ParticipantInfo(
      displayName: data['name'] ?? '',
      photoURL: data['photoURL'] ?? '',
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      typing: data['typing'] ?? false,
      role: data['role'] ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': displayName,
      'photoURL': photoURL,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'typing': typing,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? mediaUrl;
  final Map<String, DateTime> readBy;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.status,
    this.mediaUrl,
    required this.readBy,
  });

  factory Message.fromFirestore(DocumentSnapshot doc, String conversationId) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert readBy map
    final Map<String, DateTime> readByMap = {};
    final Map<String, dynamic> rawReadBy = data['readBy'] ?? {};

    rawReadBy.forEach((userId, timestamp) {
      readByMap[userId] = (timestamp as Timestamp).toDate();
    });

    return Message(
      id: doc.id,
      conversationId: conversationId,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: _getMessageType(data['type']),
      status: _getMessageStatus(data['status']),
      mediaUrl: data['mediaUrl'],
      readBy: readByMap,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> readByMap = {};
    readBy.forEach((userId, timestamp) {
      readByMap[userId] = Timestamp.fromDate(timestamp);
    });

    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': _messageTypeToString(type),
      'status': _messageStatusToString(status),
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'readBy': readByMap,
    };
  }

  bool isReadBy(String userId) {
    return readBy.containsKey(userId);
  }

  bool get isTextMessage => type == MessageType.text;
  bool get isImageMessage => type == MessageType.image;
  bool get isFileMessage => type == MessageType.file;

  static MessageType _getMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.text:
      default:
        return 'text';
    }
  }

  static MessageStatus _getMessageStatus(String? status) {
    switch (status) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }

  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.sent:
      default:
        return 'sent';
    }
  }
}
