import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String username;
  final String email;
  final String? photoUrl;
  final Map<String, dynamic>? additionalData;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    this.photoUrl,
    this.additionalData,
  });

  // Create user from Firebase Auth data
  factory AppUser.fromFirebaseAuth(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      username: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoURL'],
    );
  }

  // Create user from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AppUser(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      additionalData: data,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      ...?additionalData,
    };
  }

  // Create copy with updated fields
  AppUser copyWith({
    String? uid,
    String? username,
    String? email,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
