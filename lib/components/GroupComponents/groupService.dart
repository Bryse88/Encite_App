// services/group_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String get currentUserId => currentUser?.uid ?? '';

  /// Creates a new group with a linked conversation
  Future<String> createGroupWithChat({
    required String groupName,
    String? description,
    String? groupPhoto,
    required List<String> memberIds,
  }) async {
    // Validation
    if (groupName.trim().isEmpty) {
      throw Exception('Group name cannot be empty');
    }

    // Ensure current user is in the members list
    if (!memberIds.contains(currentUserId)) {
      memberIds.add(currentUserId);
    }

    final timestamp = DateTime.now();
    final batch = _firestore.batch();

    // 1. Create the group document
    final groupRef = _firestore.collection('groups').doc();
    final groupId = groupRef.id;

    Map<String, dynamic> groupData = {
      'name': groupName,
      'description': description ?? '',
      'createdAt': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(timestamp),
      'creatorId': currentUserId,
      'participantIds': memberIds,
      'photoURL': groupPhoto,
      // Will update this after creating the conversation
      'linkedConversationId': '',
    };

    batch.set(groupRef, groupData);

    // 2. Fetch user data for participants
    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberIds)
        .get();

    Map<String, Map<String, dynamic>> userDataMap = {};

    for (var doc in usersSnapshot.docs) {
      userDataMap[doc.id] = doc.data();
    }

    // 3. Add participants to the group
    for (var userId in memberIds) {
      final userData = userDataMap[userId] ?? {};
      final isCreator = userId == currentUserId;

      final participantData = {
        'displayName': userData['name'] ?? userData['displayName'] ?? 'Unknown',
        'photoURL': userData['photoURL'] ?? '',
        'role': isCreator ? 'admin' : 'member',
        'joinedAt': Timestamp.fromDate(timestamp),
        'status': 'active',
      };

      batch.set(
        groupRef.collection('participants').doc(userId),
        participantData,
      );
    }

    // 4. Create a conversation for the group
    final conversationRef = _firestore.collection('conversations').doc();
    final conversationId = conversationRef.id;

    batch.set(conversationRef, {
      'type': 'group',
      'groupId': groupId, // Link to group
      'participants': memberIds, // Match your existing schema
      'createdAt': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(timestamp),
      'lastMessage': '',
      'lastMessageTimestamp': Timestamp.fromDate(timestamp),
      'groupName': groupName, // Denormalized from group
      'groupPhoto': groupPhoto, // Denormalized from group
    });

    // 5. Add participants to the conversation
    for (var userId in memberIds) {
      final userData = userDataMap[userId] ?? {};
      final isCreator = userId == currentUserId;

      batch.set(
        conversationRef.collection('participants').doc(userId),
        {
          'displayName':
              userData['name'] ?? userData['displayName'] ?? 'Unknown',
          'photoURL': userData['photoURL'] ?? '',
          'lastSeen': Timestamp.fromDate(timestamp),
          'typing': false,
          'role': isCreator ? 'admin' : 'member', // Match group role
          'joinedAt': Timestamp.fromDate(timestamp),
        },
      );
    }

    // 6. Update the group with the conversation ID
    groupData['linkedConversationId'] = conversationId;
    batch.update(groupRef, {'linkedConversationId': conversationId});

    // 7. Add a system message to the conversation
    final creatorName = userDataMap[currentUserId]?['name'] ??
        userDataMap[currentUserId]?['displayName'] ??
        'Unknown';

    batch.set(
      conversationRef.collection('messages').doc(),
      {
        'senderId': 'system',
        'content': 'Group created by $creatorName',
        'timestamp': Timestamp.fromDate(timestamp),
        'type': 'system',
        'status': 'sent',
        'readBy': {currentUserId: Timestamp.fromDate(timestamp)},
      },
    );

    // Execute all operations atomically
    await batch.commit();

    return groupId;
  }

  /// Add user to a group and its linked conversation
  Future<void> addUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    final timestamp = DateTime.now();

    // Get group data
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final groupData = groupDoc.data()!;
    final conversationId = groupData['linkedConversationId'];

    // Check if user is already in the group
    final participantIds = List<String>.from(groupData['participantIds']);
    if (participantIds.contains(userId)) {
      return; // User already in group
    }

    // Check permissions - only admins can add users
    final currentUserParticipantDoc = await groupDoc.reference
        .collection('participants')
        .doc(currentUserId)
        .get();

    if (!currentUserParticipantDoc.exists ||
        currentUserParticipantDoc.data()?['role'] != 'admin') {
      throw Exception('Only admins can add users to the group');
    }

    // Get user data
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    final userData = userDoc.data()!;
    final batch = _firestore.batch();

    // 1. Update group participant list
    participantIds.add(userId);
    batch.update(groupDoc.reference, {
      'participantIds': participantIds,
      'updatedAt': Timestamp.fromDate(timestamp),
    });

    // 2. Add user to group participants
    batch.set(
      groupDoc.reference.collection('participants').doc(userId),
      {
        'displayName': userData['name'] ?? userData['displayName'] ?? 'Unknown',
        'photoURL': userData['photoURL'] ?? '',
        'role': 'member',
        'joinedAt': Timestamp.fromDate(timestamp),
        'status': 'active',
      },
    );

    // 3. Update conversation participants
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    batch.update(conversationRef, {
      'participants':
          participantIds, // Using 'participants' to match your schema
      'updatedAt': Timestamp.fromDate(timestamp),
    });

    // 4. Add user to conversation participants
    batch.set(
      conversationRef.collection('participants').doc(userId),
      {
        'displayName': userData['name'] ?? userData['displayName'] ?? 'Unknown',
        'photoURL': userData['photoURL'] ?? '',
        'lastSeen': Timestamp.fromDate(timestamp),
        'typing': false,
        'role': 'member',
        'joinedAt': Timestamp.fromDate(timestamp),
      },
    );

    // 5. Add system message
    batch.set(
      conversationRef.collection('messages').doc(),
      {
        'senderId': 'system',
        'content':
            '${userData['name'] ?? userData['displayName'] ?? 'Unknown'} added to group',
        'timestamp': Timestamp.fromDate(timestamp),
        'type': 'system',
        'status': 'sent',
        'readBy': {currentUserId: Timestamp.fromDate(timestamp)},
      },
    );

    // Execute all operations atomically
    await batch.commit();
  }

  /// Get all groups for the current user
  Stream<List<Map<String, dynamic>>> getGroups() {
    return _firestore
        .collection('groups')
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> groups = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Fetch participants
        final participantsSnapshot =
            await doc.reference.collection('participants').get();

        Map<String, dynamic> participants = {};
        for (var participantDoc in participantsSnapshot.docs) {
          participants[participantDoc.id] = participantDoc.data();
        }

        data['participants'] = participants;
        groups.add(data);
      }

      return groups;
    });
  }

  /// Remove user from a group and its linked conversation
  Future<void> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    final timestamp = DateTime.now();

    // Get group data
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final groupData = groupDoc.data()!;
    final conversationId = groupData['linkedConversationId'];

    // Check permissions - self-removal or admin removing others
    final isSelfRemoval = userId == currentUserId;

    if (!isSelfRemoval) {
      // Check if current user is admin
      final currentUserParticipantDoc = await groupDoc.reference
          .collection('participants')
          .doc(currentUserId)
          .get();

      if (!currentUserParticipantDoc.exists ||
          currentUserParticipantDoc.data()?['role'] != 'admin') {
        throw Exception('Only admins can remove other users');
      }
    }

    // Get user data for system message
    final batch = _firestore.batch();

    // Get user name before removing
    final userParticipantDoc =
        await groupDoc.reference.collection('participants').doc(userId).get();

    final userName = userParticipantDoc.exists
        ? (userParticipantDoc.data() != null
            ? userParticipantDoc.data()!['displayName']
            : 'Unknown')
        : 'Unknown';

    // 1. Update group participant list
    final participantIds = List<String>.from(groupData['participantIds']);
    participantIds.remove(userId);

    batch.update(groupDoc.reference, {
      'participantIds': participantIds,
      'updatedAt': Timestamp.fromDate(timestamp),
    });

    // 2. Remove user from group participants
    batch.delete(groupDoc.reference.collection('participants').doc(userId));

    // 3. Update conversation participants
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    batch.update(conversationRef, {
      'participants':
          participantIds, // Using 'participants' to match your schema
      'updatedAt': Timestamp.fromDate(timestamp),
    });

    // 4. Remove user from conversation participants
    batch.delete(conversationRef.collection('participants').doc(userId));

    // 5. Add system message
    final messageContent = isSelfRemoval
        ? '$userName left the group'
        : '$userName was removed from the group';

    batch.set(
      conversationRef.collection('messages').doc(),
      {
        'senderId': 'system',
        'content': messageContent,
        'timestamp': Timestamp.fromDate(timestamp),
        'type': 'system',
        'status': 'sent',
        'readBy': {currentUserId: Timestamp.fromDate(timestamp)},
      },
    );

    // Execute all operations atomically
    await batch.commit();

    // If group is now empty, delete it
    if (participantIds.isEmpty) {
      await deleteGroup(groupId);
    }
  }

  /// Delete a group and its linked conversation
  Future<void> deleteGroup(String groupId) async {
    // Get group data
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      return; // Already deleted
    }

    final groupData = groupDoc.data()!;
    final conversationId = groupData['linkedConversationId'];

    // Check permissions - only admins can delete
    final currentUserParticipantDoc = await groupDoc.reference
        .collection('participants')
        .doc(currentUserId)
        .get();

    if (!currentUserParticipantDoc.exists ||
        currentUserParticipantDoc.data()?['role'] != 'admin') {
      throw Exception('Only admins can delete the group');
    }

    // Delete all group participants
    final participantsSnapshot =
        await groupDoc.reference.collection('participants').get();

    final batch = _firestore.batch();
    for (var doc in participantsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the group
    batch.delete(groupDoc.reference);

    await batch.commit();

    // Delete the linked conversation using your existing ChatService
    // You would typically call ChatService.deleteConversation(conversationId) here
  }
}
