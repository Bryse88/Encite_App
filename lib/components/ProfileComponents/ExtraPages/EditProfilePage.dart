import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encite/components/Colors/uber_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = true;
  File? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // For tags management with social preferences
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Sports',
    'Outdoors',
    'Music',
    'Arts',
    'Food & Dining',
    'Coffee',
    'Nightlife',
    'Movies',
    'Gaming',
    'Reading',
    'Fitness',
    'Yoga',
    'Travel',
    'Language Exchange',
    'Networking',
    'Study Groups',
    'Photography',
    'Cooking',
    'Volunteering',
    'Tech Meetups'
  ];

  // User data
  String _currentPhotoURL = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Fetch user tags
      final tagsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('onboarding')
          .doc('identityTags')
          .get();

      if (mounted) {
        setState(() {
          // Set name and photo URL
          _nameController.text = userDoc.data()?['name'] ?? '';
          _usernameController.text = userDoc.data()?['userName'] ?? '';
          _bioController.text = userDoc.data()?['bio'] ?? '';
          _currentPhotoURL = userDoc.data()?['photoURL'] ?? '';

          // Set selected tags
          if (tagsDoc.exists) {
            _selectedTags
                .addAll(List<String>.from(tagsDoc.data()?['tags'] ?? []));
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Update user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text.trim(),
        'userName': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update user tags
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('onboarding')
          .doc('identityTags')
          .set({
        'tags': _selectedTags,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UberColors.background,
      appBar: AppBar(
        backgroundColor: UberColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: UberColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: UberColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: UberColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image section
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                // Profile image
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          UberColors.primary.withOpacity(0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : _currentPhotoURL.isNotEmpty
                                            ? Image.network(
                                                _currentPhotoURL,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: UberColors.cardBg,
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color:
                                                      UberColors.textSecondary,
                                                ),
                                              ),
                                  ),
                                ),
                                // Edit button overlay kept for layout consistency
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Profile Picture',
                              style: TextStyle(
                                fontSize: 14,
                                color: UberColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Form fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          const Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: UberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: UberColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: UberColors.divider,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: UberColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: InputBorder.none,
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(
                                  color: UberColors.textSecondary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Username field with @ sign
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: UberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: UberColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: UberColors.divider,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // @ sign prefix
                                Container(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: const Text(
                                    '@',
                                    style: TextStyle(
                                      color: UberColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // Text field
                                Expanded(
                                  child: TextField(
                                    controller: _usernameController,
                                    style: const TextStyle(
                                      color: UberColors.textPrimary,
                                    ),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 14,
                                      ),
                                      border: InputBorder.none,
                                      hintText: 'username',
                                      hintStyle: TextStyle(
                                        color: UberColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Bio field
                          const Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: UberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: UberColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: UberColors.divider,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _bioController,
                              style: const TextStyle(
                                color: UberColors.textPrimary,
                              ),
                              maxLines: 5,
                              maxLength: 150,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: InputBorder.none,
                                hintText: 'Write a short bio about yourself',
                                hintStyle: TextStyle(
                                  color: UberColors.textSecondary,
                                ),
                                counter: SizedBox.shrink(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Social Interests section
                          const Text(
                            'Social Interests',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: UberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select your interests to help us connect you with like-minded people for group activities',
                            style: TextStyle(
                              fontSize: 13,
                              color: UberColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 12,
                            children: _availableTags.map((tag) {
                              final isSelected = _selectedTags.contains(tag);
                              return GestureDetector(
                                onTap: () => _toggleTag(tag),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? UberColors.primary.withOpacity(0.1)
                                        : UberColors.cardBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? UberColors.primary
                                          : UberColors.divider,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: isSelected
                                          ? UberColors.primary
                                          : UberColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Save button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GestureDetector(
                        onTap: _saveProfile,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: UberColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
