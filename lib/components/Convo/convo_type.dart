// models/conversation.dart
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
  final Map<String, Participant> participants;

  Conversation({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.participantIds,
    required this.participants,
  });

  factory Conversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    Map<String, Participant> participants,
  ) {
    final data = snapshot.data()!;
    return Conversation(
      id: snapshot.id,
      type: data['type'] == 'one_on_one'
          ? ConversationType.oneOnOne
          : ConversationType.group,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] != null
          ? (data['lastMessageTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      participantIds: List<String>.from(data['participants'] ?? []),
      participants: participants,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type == ConversationType.oneOnOne ? 'one_on_one' : 'group',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'participants': participantIds,
    };
  }
}

class Participant {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final DateTime lastSeen;
  final bool isTyping;

  Participant({
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.lastSeen,
    required this.isTyping,
  });

  factory Participant.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Participant(
      userId: snapshot.id,
      role: data['role'] ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isTyping: data['typing'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastSeen': Timestamp.fromDate(lastSeen),
      'typing': isTyping,
    };
  }
}

// models/message.dart
class Message {
  final String id;
  final String conversationId;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? mediaUrl;
  final Map<String, DateTime> readBy;

  Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.type,
    required this.status,
    this.mediaUrl,
    required this.readBy,
  });

  factory Message.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, String conversationId) {
    final data = snapshot.data()!;

    // Parse readBy map
    Map<String, DateTime> readByMap = {};
    if (data['readBy'] != null && data['readBy'] is Map) {
      final Map<String, dynamic> readByData =
          Map<String, dynamic>.from(data['readBy']);
      readByData.forEach((key, value) {
        if (value is Timestamp) {
          readByMap[key] = value.toDate();
        }
      });
    }

    return Message(
      id: snapshot.id,
      conversationId: conversationId,
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: _getMessageType(data['type']),
      status: _getMessageStatus(data['status']),
      mediaUrl: data['mediaUrl'],
      readBy: readByMap,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> readByFirestore = {};
    readBy.forEach((key, value) {
      readByFirestore[key] = Timestamp.fromDate(value);
    });

    return {
      'content': content,
      'senderId': senderId,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': _getMessageTypeString(type),
      'status': _getMessageStatusString(status),
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'readBy': readByFirestore,
    };
  }

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

  static String _getMessageTypeString(MessageType type) {
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

  static String _getMessageStatusString(MessageStatus status) {
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
