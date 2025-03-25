// services/chat_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/Convo/convo_type.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String get currentUserId => currentUser?.uid ?? '';

  // Get all conversations for current user
  Stream<List<Conversation>> getConversations() {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Conversation> conversations = [];

      for (var doc in snapshot.docs) {
        // Fetch participants for each conversation
        Map<String, Participant> participants = {};
        final participantsSnapshot = await _firestore
            .collection('conversations')
            .doc(doc.id)
            .collection('participants')
            .get();

        for (var participantDoc in participantsSnapshot.docs) {
          participants[participantDoc.id] =
              Participant.fromFirestore(participantDoc);
        }

        conversations.add(Conversation.fromFirestore(doc, participants));
      }

      return conversations;
    });
  }

  // Get messages for a specific conversation
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit for performance
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromFirestore(doc, conversationId))
          .toList();
    });
  }

  // Send a new message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    final timestamp = DateTime.now();

    // Create message document
    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final message = Message(
      id: messageRef.id,
      conversationId: conversationId,
      content: content,
      senderId: currentUserId,
      timestamp: timestamp,
      type: type,
      status: MessageStatus.sent,
      mediaUrl: mediaUrl,
      readBy: {currentUserId: timestamp},
    );

    // Update conversation with last message info
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);

    // Use a batch to update both documents atomically
    final batch = _firestore.batch();
    batch.set(messageRef, message.toFirestore());
    batch.update(conversationRef, {
      'lastMessage': content,
      'lastMessageTimestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(timestamp),
    });

    await batch.commit();

    // Update your own participant status
    await updateParticipantStatus(
      conversationId: conversationId,
      userId: currentUserId,
      lastSeen: timestamp,
      isTyping: false,
    );
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    final timestamp = DateTime.now();

    // Get unread messages
    final querySnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    // Use a batch for efficiency
    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(doc.id);

      batch.update(messageRef, {
        'readBy.$currentUserId': Timestamp.fromDate(timestamp),
        'status': 'read',
      });
    }

    await batch.commit();

    // Update participant lastSeen
    await updateParticipantStatus(
      conversationId: conversationId,
      userId: currentUserId,
      lastSeen: timestamp,
    );
  }

  // Update participant status (typing, last seen)
  Future<void> updateParticipantStatus({
    required String conversationId,
    required String userId,
    DateTime? lastSeen,
    bool? isTyping,
  }) async {
    final participantRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('participants')
        .doc(userId);

    Map<String, dynamic> updates = {};

    if (lastSeen != null) {
      updates['lastSeen'] = Timestamp.fromDate(lastSeen);
    }

    if (isTyping != null) {
      updates['typing'] = isTyping;
    }

    if (updates.isNotEmpty) {
      await participantRef.update(updates);
    }
  }

  // Create a new one-on-one conversation
  Future<String> createOneOnOneConversation(String otherUserId) async {
    // Check if conversation already exists
    final querySnapshot = await _firestore
        .collection('conversations')
        .where('type', isEqualTo: 'one_on_one')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants']);

      if (participants.contains(otherUserId) && participants.length == 2) {
        return doc.id; // Conversation already exists
      }
    }

    // Create new conversation
    final timestamp = DateTime.now();
    final conversationRef = _firestore.collection('conversations').doc();

    final conversation = Conversation(
      id: conversationRef.id,
      type: ConversationType.oneOnOne,
      createdAt: timestamp,
      updatedAt: timestamp,
      lastMessage: '',
      lastMessageTimestamp: timestamp,
      participantIds: [currentUserId, otherUserId],
      participants: {}, // We'll add participants separately
    );

    // Setup participants
    final currentParticipantRef =
        conversationRef.collection('participants').doc(currentUserId);
    final otherParticipantRef =
        conversationRef.collection('participants').doc(otherUserId);

    final batch = _firestore.batch();

    // Add conversation
    batch.set(conversationRef, conversation.toFirestore());

    // Add current user as participant
    batch.set(currentParticipantRef, {
      'role': 'member',
      'joinedAt': Timestamp.fromDate(timestamp),
      'lastSeen': Timestamp.fromDate(timestamp),
      'typing': false,
    });

    // Add other user as participant
    batch.set(otherParticipantRef, {
      'role': 'member',
      'joinedAt': Timestamp.fromDate(timestamp),
      'lastSeen': Timestamp.fromDate(timestamp),
      'typing': false,
    });

    await batch.commit();

    return conversationRef.id;
  }

  // Create a new group conversation
  Future<String> createGroupConversation(
      List<String> memberIds, String groupName) async {
    final timestamp = DateTime.now();

    // Ensure current user is included
    if (!memberIds.contains(currentUserId)) {
      memberIds.add(currentUserId);
    }

    final conversationRef = _firestore.collection('conversations').doc();

    final conversation = Conversation(
      id: conversationRef.id,
      type: ConversationType.group,
      createdAt: timestamp,
      updatedAt: timestamp,
      lastMessage: '$groupName created',
      lastMessageTimestamp: timestamp,
      participantIds: memberIds,
      participants: {}, // We'll add participants separately
    );

    final batch = _firestore.batch();

    // Add conversation
    batch.set(conversationRef, conversation.toFirestore());

    // Add all members as participants
    for (var userId in memberIds) {
      final participantRef =
          conversationRef.collection('participants').doc(userId);
      batch.set(participantRef, {
        'role': userId == currentUserId ? 'admin' : 'member',
        'joinedAt': Timestamp.fromDate(timestamp),
        'lastSeen': Timestamp.fromDate(timestamp),
        'typing': false,
      });
    }

    await batch.commit();

    return conversationRef.id;
  }

  // Set typing status
  Future<void> setTypingStatus(String conversationId, bool isTyping) async {
    await updateParticipantStatus(
      conversationId: conversationId,
      userId: currentUserId,
      isTyping: isTyping,
    );
  }
}
