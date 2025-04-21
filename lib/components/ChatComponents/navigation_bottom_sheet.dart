import 'dart:ui';

import 'package:encite/components/ChatComponents/chat_service.dart';
import 'package:flutter/material.dart';

class NewChatBottomSheet extends StatefulWidget {
  final ChatService chatService;
  final VoidCallback onChatStarted;

  const NewChatBottomSheet({
    required this.chatService,
    required this.onChatStarted,
  });

  @override
  State<NewChatBottomSheet> createState() => NewChatBottomSheetState();
}

class NewChatBottomSheetState extends State<NewChatBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isCreatingGroup = false;
  final TextEditingController _groupNameController = TextEditingController();
  List<String> _selectedUsers = [];
  Map<String, Map<String, dynamic>> _selectedUserDetails = {};

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Add @ symbol if not already present
    String searchQuery = query;
    if (!query.startsWith('@')) {
      searchQuery = '@' + query;
    }

    final results = await widget.chatService.searchUsers(searchQuery);
    setState(() {
      _searchResults = results;
    });
  }

  void _toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      final userId = user['id'];
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
        _selectedUserDetails.remove(userId);
      } else {
        _selectedUsers.add(userId);
        _selectedUserDetails[userId] = user;
      }
    });
  }

  void _createGroupChat() async {
    if (_groupNameController.text.trim().isEmpty || _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter a group name and select at least one user')),
      );
      return;
    }

    try {
      final conversationId = await widget.chatService.createGroupConversation(
        groupName: _groupNameController.text.trim(),
        memberIds: _selectedUsers,
      );

      widget.onChatStarted();
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {'conversationId': conversationId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isCreatingGroup ? 'New Group Chat' : 'New Chat',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isCreatingGroup ? Icons.person : Icons.group,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCreatingGroup = !_isCreatingGroup;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Group name input (only shown when creating a group)
            if (_isCreatingGroup)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _groupNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Group Name',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.group, color: Colors.white),
                  ),
                ),
              ),

            // Selected users (only shown when creating a group)
            if (_isCreatingGroup && _selectedUsers.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedUsers.length,
                  itemBuilder: (context, index) {
                    final userId = _selectedUsers[index];
                    final user = _selectedUserDetails[userId]!;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: user['photoURL'] != null &&
                                        user['photoURL'].isNotEmpty
                                    ? NetworkImage(user['photoURL'])
                                    : null,
                                backgroundColor: Colors.blue,
                                child: user['photoURL'] == null ||
                                        user['photoURL'].isEmpty
                                    ? Text(
                                        user['displayName'][0].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: GestureDetector(
                                  onTap: () => _toggleUserSelection(user),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['displayName'].length > 10
                                ? '${user['displayName'].substring(0, 8)}...'
                                : user['displayName'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user['userName'].length > 10
                                ? '${user['userName'].substring(0, 8)}...'
                                : user['userName'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Search input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),

            // Search results
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Search for users to chat with'
                            : 'No users found',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isSelected = _selectedUsers.contains(user['id']);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['photoURL'] != null &&
                                    user['photoURL'].isNotEmpty
                                ? NetworkImage(user['photoURL'])
                                : null,
                            backgroundColor: Colors.blue,
                            child: user['photoURL'] == null ||
                                    user['photoURL'].isEmpty
                                ? Text(
                                    user['displayName'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                          title: Text(
                            user['displayName'] ?? 'Unknown User',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            user['email'] ?? '',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.6)),
                          ),
                          trailing: _isCreatingGroup
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleUserSelection(user),
                                  fillColor:
                                      MaterialStateProperty.all(Colors.blue),
                                )
                              : null,
                          onTap: _isCreatingGroup
                              ? () => _toggleUserSelection(user)
                              : () async {
                                  try {
                                    final conversationId = await widget
                                        .chatService
                                        .createOneOnOneConversation(user['id']);
                                    widget.onChatStarted();
                                    if (mounted) {
                                      Navigator.pushNamed(
                                        context,
                                        '/chat',
                                        arguments: {
                                          'conversationId': conversationId
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error starting chat: $e')),
                                      );
                                    }
                                  }
                                },
                        );
                      },
                    ),
            ),

            // Create Group Button (only shown when creating a group)
            if (_isCreatingGroup)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: _createGroupChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Create Group Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
