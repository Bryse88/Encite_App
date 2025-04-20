import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> generateAndSaveUsername({
  required String fullName,
  required String uid,
}) async {
  final firestore = FirebaseFirestore.instance;

  // Step 1: Sanitize base username
  String base = fullName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), ''); // Keep alphanumeric only

  if (base.isEmpty) base = 'user';

  // Step 2: Try with base name first
  String candidate = base;
  bool isUnique = false;
  int uidCharsToUse = 0;

  while (!isUnique) {
    // Check if username exists
    final existing =
        await firestore.collection('usernames').doc(candidate).get();

    if (!existing.exists) {
      isUnique = true;
    } else {
      // Increment number of UID characters to use
      uidCharsToUse++;

      // Make sure we don't exceed UID length
      if (uidCharsToUse > uid.length) {
        uidCharsToUse = uid.length;
        // Add a random counter if we've used all UID chars
        candidate =
            '$base${uid.substring(0, uidCharsToUse)}${DateTime.now().millisecondsSinceEpoch % 1000}';
      } else {
        // Use incremental parts of UID to ensure uniqueness
        candidate = '$base${uid.substring(0, uidCharsToUse)}';
      }
    }
  }

  // Step 3: Save mapping in `usernames` collection for fast lookup
  await firestore.collection('usernames').doc(candidate).set({
    'uid': uid,
  });

  // Step 4: Save to user document with @ prefix
  await firestore.collection('users').doc(uid).update({
    'username': '@$candidate',
  });

  return '@$candidate';
}
