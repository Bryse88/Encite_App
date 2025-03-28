import 'dart:ui';
import 'package:encite/components/ConvoComponents/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:encite/components/ConvoComponents/chat_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatService _chatService = ChatService();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewChatBottomSheet(
        chatService: _chatService,
        onChatStarted: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults = [];
      }
    });
  }

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = await _chatService.searchUsers(query);
    setState(() {
      _searchResults = results;
    });
  }

  void _openConversation(BuildContext context, Conversation conversation) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'conversationId': conversation.id},
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE').format(timestamp); // Day of week
    } else {
      return DateFormat('MM/dd/yy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C1C1E), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // Header with search functionality
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _searchUsers,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.6)),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _toggleSearch,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chats',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _toggleSearch,
                          ),
                        ],
                      ),
              ),

              // Search results or chat list
              Expanded(
                child: _isSearching
                    ? _buildSearchResults()
                    : _buildConversationsList(),
              ),

              // Start chat button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: _startNewChat,
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
                        'Start New Chat',
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

              const SizedBox(height: 70), // Space for blurred nav bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversationsList() {
    return StreamBuilder<List<Conversation>>(
      stream: _chatService.getConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
            ),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text(
              'Error loading conversations: ${snapshot.error}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          );
        }

        final conversations = snapshot.data ?? [];

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    color: Colors.white.withOpacity(0.3), size: 64),
                const SizedBox(height: 16),
                Text(
                  'No Conversations Yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Start a new conversation or group chat',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final currentUserId = _chatService.currentUserId;
            return _ConversationTile(
              conversation: conversation,
              currentUserId: currentUserId,
              onTap: () => _openConversation(context, conversation),
              formatTimestamp: _formatTimestamp,
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Text(
          'Type to search users',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                user['photoURL'] != null && user['photoURL'].isNotEmpty
                    ? NetworkImage(user['photoURL'])
                    : null,
            backgroundColor: Colors.blue,
            child: user['photoURL'] == null || user['photoURL'].isEmpty
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
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          onTap: () async {
            final conversationId =
                await _chatService.createOneOnOneConversation(user['id']);
            if (mounted) {
              Navigator.pushNamed(
                context,
                '/chat',
                arguments: {'conversationId': conversationId},
              );
              _toggleSearch();
            }
          },
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final String Function(DateTime) formatTimestamp;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = conversation.getDisplayName(currentUserId);
    final photoURL = conversation.getPhotoURL(currentUserId);

    // Get the timestamp for the last message
    final timestamp = conversation.lastMessageTimestamp;
    final formattedTime = formatTimestamp(timestamp);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
        backgroundColor: Colors.blue,
        child: photoURL.isEmpty
            ? conversation.isGroup
                ? const Icon(Icons.group, color: Colors.white)
                : Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formattedTime,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _NewChatBottomSheet extends StatefulWidget {
  final ChatService chatService;
  final VoidCallback onChatStarted;

  const _NewChatBottomSheet({
    required this.chatService,
    required this.onChatStarted,
  });

  @override
  State<_NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends State<_NewChatBottomSheet> {
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

    final results = await widget.chatService.searchUsers(query);
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
