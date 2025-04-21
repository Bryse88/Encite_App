// services/chat_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/ChatComponents/chat_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String get currentUserId => currentUser?.uid ?? '';

  // Get all conversations for current user
  Stream<List<Conversation>> getConversations() async* {
    try {
      yield* _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        List<Conversation> conversations = [];

        for (var doc in snapshot.docs) {
          // Fetch participants for each conversation
          Map<String, ParticipantInfo> participants = {};
          final participantsSnapshot = await _firestore
              .collection('conversations')
              .doc(doc.id)
              .collection('participants')
              .get();

          for (var participantDoc in participantsSnapshot.docs) {
            participants[participantDoc.id] =
                ParticipantInfo.fromMap(participantDoc);
          }

          conversations.add(Conversation.fromFirestore(doc, participants));
        }

        return conversations;
      });
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // Print the URL for creating the index
        print('Error loading conversations: ${e.message}');
      } else {
        rethrow;
      }
    }
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
    batch.set(messageRef, message.toMap());
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
      participants: {},
    );

    // Get current user info
    final currentUserDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final currentUserData = currentUserDoc.data() ?? {};

    // Get other user info
    final otherUserDoc =
        await _firestore.collection('users').doc(otherUserId).get();
    final otherUserData = otherUserDoc.data() ?? {};

    // Use a batch write for atomic operation
    final batch = _firestore.batch();

    // Create conversation document
    batch.set(conversationRef, conversation.toFirestore());

    // Create participant documents
    final currentUserParticipant = ParticipantInfo(
      displayName:
          currentUserData['name'] ?? '', // Changed from 'displayName' to 'name'
      photoURL: currentUserData['photoURL'] ?? '',
      lastSeen: timestamp,
      typing: false,
      role: 'member',
      joinedAt: timestamp,
    );

    final otherUserParticipant = ParticipantInfo(
      displayName:
          otherUserData['name'] ?? '', // Changed from 'displayName' to 'name'
      photoURL: otherUserData['photoURL'] ?? '',
      lastSeen: timestamp,
      typing: false,
      role: 'member',
      joinedAt: timestamp,
    );

    batch.set(
      conversationRef.collection('participants').doc(currentUserId),
      currentUserParticipant.toMap(),
    );

    batch.set(
      conversationRef.collection('participants').doc(otherUserId),
      otherUserParticipant.toMap(),
    );

    await batch.commit();
    return conversationRef.id;
  }

  // Create a new group conversation
  Future<String> createGroupConversation({
    required String groupName,
    String? groupPhoto,
    required List<String> memberIds,
  }) async {
    final timestamp = DateTime.now();
    final conversationRef = _firestore.collection('conversations').doc();

    // Ensure current user is in the members list
    if (!memberIds.contains(currentUserId)) {
      memberIds.add(currentUserId);
    }

    final conversation = Conversation(
      id: conversationRef.id,
      type: ConversationType.group,
      createdAt: timestamp,
      updatedAt: timestamp,
      lastMessage: '',
      lastMessageTimestamp: timestamp,
      participantIds: memberIds,
      participants: {},
      groupName: groupName,
      groupPhoto: groupPhoto,
    );

    // Use a batch for atomic operation
    final batch = _firestore.batch();
    batch.set(conversationRef, conversation.toFirestore());

    // Add all participants to the group
    for (String userId in memberIds) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      final role = userId == currentUserId ? 'admin' : 'member';

      final participant = ParticipantInfo(
        displayName: userData['displayName'] ?? '',
        photoURL: userData['photoURL'] ?? '',
        lastSeen: timestamp,
        typing: false,
        role: role,
        joinedAt: timestamp,
      );

      batch.set(
        conversationRef.collection('participants').doc(userId),
        participant.toMap(),
      );
    }

    await batch.commit();
    return conversationRef.id;
  }

  // Add a participant to a group conversation
  Future<void> addParticipantToGroup({
    required String conversationId,
    required String userId,
  }) async {
    final timestamp = DateTime.now();
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      throw Exception('Conversation does not exist');
    }

    final data = conversationDoc.data() as Map<String, dynamic>;

    // Check if it's a group conversation
    if (data['type'] != 'group') {
      throw Exception('This is not a group conversation');
    }

    // Check if user is already a participant
    final participants = List<String>.from(data['participants'] ?? []);
    if (participants.contains(userId)) {
      return; // User is already a participant
    }

    // Get user info
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};

    // Add user to the conversation
    final batch = _firestore.batch();

    // Update participants array
    participants.add(userId);
    batch.update(conversationRef, {
      'participants': participants,
      'updatedAt': Timestamp.fromDate(timestamp),
    });

    // Create participant document
    final participant = ParticipantInfo(
      displayName: userData['displayName'] ?? '',
      photoURL: userData['photoURL'] ?? '',
      lastSeen: timestamp,
      typing: false,
      role: 'member',
      joinedAt: timestamp,
    );

    batch.set(
      conversationRef.collection('participants').doc(userId),
      participant.toMap(),
    );

    await batch.commit();
  }

  // Remove a participant from a group conversation
  Future<void> removeParticipantFromGroup({
    required String conversationId,
    required String userId,
  }) async {
    final timestamp = DateTime.now();
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      throw Exception('Conversation does not exist');
    }

    final data = conversationDoc.data() as Map<String, dynamic>;

    // Check if it's a group conversation
    if (data['type'] != 'group') {
      throw Exception('This is not a group conversation');
    }

    // Check if user is a participant
    final participants = List<String>.from(data['participants'] ?? []);
    if (!participants.contains(userId)) {
      return; // User is not a participant
    }

    // Check permissions - only admin can remove members
    if (userId != currentUserId) {
      final currentUserParticipantDoc = await conversationRef
          .collection('participants')
          .doc(currentUserId)
          .get();

      if (!currentUserParticipantDoc.exists) {
        throw Exception('Current user is not a participant');
      }

      final currentUserData =
          currentUserParticipantDoc.data() as Map<String, dynamic>;
      if (currentUserData['role'] != 'admin') {
        throw Exception('Only admins can remove participants');
      }
    }

    // Remove user from the conversation
    final batch = _firestore.batch();

    // Update participants array
    participants.remove(userId);
    batch.update(conversationRef, {
      'participants': participants,
      'updatedAt': Timestamp.fromDate(timestamp),
    });

    // Delete participant document
    batch.delete(conversationRef.collection('participants').doc(userId));

    await batch.commit();

    // If this was the last participant, delete the conversation
    if (participants.isEmpty) {
      await deleteConversation(conversationId);
    }
  }

  // Leave a group conversation
  Future<void> leaveGroup(String conversationId) async {
    await removeParticipantFromGroup(
      conversationId: conversationId,
      userId: currentUserId,
    );
  }

  // Update group info
  Future<void> updateGroupInfo({
    required String conversationId,
    String? groupName,
    String? groupPhoto,
  }) async {
    final timestamp = DateTime.now();
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);

    // Check if current user is admin
    final currentUserParticipantDoc = await conversationRef
        .collection('participants')
        .doc(currentUserId)
        .get();

    if (!currentUserParticipantDoc.exists) {
      throw Exception('Current user is not a participant');
    }

    final currentUserData =
        currentUserParticipantDoc.data() as Map<String, dynamic>;
    if (currentUserData['role'] != 'admin') {
      throw Exception('Only admins can update group info');
    }

    Map<String, dynamic> updates = {
      'updatedAt': Timestamp.fromDate(timestamp),
    };

    if (groupName != null) {
      updates['groupName'] = groupName;
    }

    if (groupPhoto != null) {
      updates['groupPhoto'] = groupPhoto;
    }

    await conversationRef.update(updates);
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);

    // Delete all messages
    final messagesQuerySnapshot =
        await conversationRef.collection('messages').get();

    // Delete in batches (Firestore limits batch operations to 500)
    List<List<DocumentSnapshot>> batches = [];
    List<DocumentSnapshot> currentBatch = [];

    for (final doc in messagesQuerySnapshot.docs) {
      currentBatch.add(doc);
      if (currentBatch.length >= 400) {
        // Using 400 to be safe
        batches.add(currentBatch);
        currentBatch = [];
      }
    }

    if (currentBatch.isNotEmpty) {
      batches.add(currentBatch);
    }

    // Delete each batch
    for (final batchDocs in batches) {
      final writeBatch = _firestore.batch();
      for (final doc in batchDocs) {
        writeBatch.delete(doc.reference);
      }
      await writeBatch.commit();
    }

    // Delete all participants
    final participantsQuerySnapshot =
        await conversationRef.collection('participants').get();

    final participantsBatch = _firestore.batch();
    for (final doc in participantsQuerySnapshot.docs) {
      participantsBatch.delete(doc.reference);
    }

    // Finally delete the conversation document itself
    participantsBatch.delete(conversationRef);
    await participantsBatch.commit();
  }

  // Search for users to start a conversation with
  // Search for users to start a conversation with
  // Modified searchUsers method for ChatService class
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    // When query is empty, fetch recent users instead of returning empty list
    if (query.trim().isEmpty) {
      // Fetch all users, or limit to a reasonable number (e.g., 20)
      final usersQuery = await _firestore.collection('users').limit(20).get();

      return usersQuery.docs
          .where((doc) => doc.id != currentUserId) // Exclude current user
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'displayName':
              data['name'] ?? '', // This maps 'name' to 'displayName'
          'photoURL': data['photoURL'] ?? '',
          'userName': data['userName'] ?? '',
        };
      }).toList();
    }

    final queryLower = query.toLowerCase();

    // Query for username matches
    final usernameQuery = await _firestore
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: queryLower)
        .where('userName', isLessThanOrEqualTo: queryLower + '\uf8ff')
        .limit(10)
        .get();

    final results = usernameQuery.docs
        .where((doc) => doc.id != currentUserId) // Exclude current user
        .map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'displayName': data['name'] ?? '', // This maps 'name' to 'displayName'
        'photoURL': data['photoURL'] ?? '',
        'userName': data['userName'] ?? '',
      };
    }).toList();

    return results;
  }

  // Change user role in a group (admin/member)
  Future<void> changeUserRole({
    required String conversationId,
    required String userId,
    required String newRole,
  }) async {
    if (newRole != 'admin' && newRole != 'member') {
      throw Exception('Invalid role. Must be either "admin" or "member"');
    }

    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      throw Exception('Conversation does not exist');
    }

    final data = conversationDoc.data() as Map<String, dynamic>;
    if (data['type'] != 'group') {
      throw Exception('This is not a group conversation');
    }

    // Check if current user is admin
    final currentUserParticipantDoc = await conversationRef
        .collection('participants')
        .doc(currentUserId)
        .get();

    if (!currentUserParticipantDoc.exists) {
      throw Exception('Current user is not a participant');
    }

    final currentUserData =
        currentUserParticipantDoc.data() as Map<String, dynamic>;
    if (currentUserData['role'] != 'admin') {
      throw Exception('Only admins can change user roles');
    }

    // Update the user's role
    await conversationRef.collection('participants').doc(userId).update({
      'role': newRole,
    });
  }

  // Get typing users in a conversation
  Future<List<String>> getTypingUsers(String conversationId) async {
    final participantsSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('participants')
        .where('typing', isEqualTo: true)
        .get();

    return participantsSnapshot.docs
        .where((doc) => doc.id != currentUserId) // Exclude current user
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['name'] as String? ?? 'Unknown User';
    }).toList();
  }

  // Set typing status
  Future<void> setTypingStatus({
    required String conversationId,
    required bool isTyping,
  }) async {
    await updateParticipantStatus(
      conversationId: conversationId,
      userId: currentUserId,
      isTyping: isTyping,
    );
  }

  // Get message read status
  Future<Map<String, DateTime>> getMessageReadStatus(
    String conversationId,
    String messageId,
  ) async {
    final messageDoc = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .get();

    if (!messageDoc.exists) {
      return {};
    }

    final data = messageDoc.data() as Map<String, dynamic>;
    final Map<String, DateTime> readByMap = {};
    final Map<String, dynamic> rawReadBy = data['readBy'] ?? {};

    rawReadBy.forEach((userId, timestamp) {
      readByMap[userId] = (timestamp as Timestamp).toDate();
    });

    return readByMap;
  }

  // Get conversation metadata
  Future<Conversation?> getConversation(String conversationId) async {
    final conversationDoc =
        await _firestore.collection('conversations').doc(conversationId).get();

    if (!conversationDoc.exists) {
      return null;
    }

    // Fetch participants
    Map<String, ParticipantInfo> participants = {};
    final participantsSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('participants')
        .get();

    for (var participantDoc in participantsSnapshot.docs) {
      participants[participantDoc.id] = ParticipantInfo.fromMap(participantDoc);
    }

    return Conversation.fromFirestore(conversationDoc, participants);
  }

  // Load more messages (pagination)
  Future<List<Message>> loadMoreMessages(
    String conversationId,
    DateTime beforeTimestamp,
    int limit,
  ) async {
    final messagesSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfter([Timestamp.fromDate(beforeTimestamp)])
        .limit(limit)
        .get();

    return messagesSnapshot.docs
        .map((doc) => Message.fromFirestore(doc, conversationId))
        .toList();
  }

  // Search messages in a conversation
  Future<List<Message>> searchMessages(
    String conversationId,
    String searchTerm,
  ) async {
    // Firestore doesn't support full-text search, so we're doing a simple contains query
    // For production, consider using Algolia or Elasticsearch
    final messagesSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('type', isEqualTo: 'text')
        .get();

    final searchTermLower = searchTerm.toLowerCase();

    return messagesSnapshot.docs
        .map((doc) => Message.fromFirestore(doc, conversationId))
        .where((message) =>
            message.content.toLowerCase().contains(searchTermLower))
        .toList();
  }

  // Get unread messages count
  Future<int> getUnreadMessagesCount(String conversationId) async {
    final messagesSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    int unreadCount = 0;

    for (var doc in messagesSnapshot.docs) {
      final data = doc.data();
      final Map<String, dynamic> readBy = data['readBy'] ?? {};

      if (!readBy.containsKey(currentUserId)) {
        unreadCount++;
      }
    }

    return unreadCount;
  }
}
