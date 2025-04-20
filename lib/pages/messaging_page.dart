import 'dart:ui';
import 'package:encite/components/ChatComponents/chat_service.dart';
import 'package:encite/components/ChatComponents/navigation_bottom_sheet.dart';
import 'package:encite/components/Colors/uber_colors.dart';
import 'package:flutter/material.dart';
import 'package:encite/components/ChatComponents/chat_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:encite/components/ChatComponents/conversation_tiles.dart';

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
      builder: (context) => NewChatBottomSheet(
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
    return Scaffold(
        // backgroundColor: Colors.transparent,
        body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [UberColors.background, Color(0xFF0A0A0A)],
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
                          Row(
                            children: [
                              // Add the back button here
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Colors.white),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Chats',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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
    ));
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
            return ConversationTile(
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
