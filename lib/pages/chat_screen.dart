import 'dart:async';
import 'package:encite/components/ChatComponents/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:encite/components/ChatComponents/chat_models.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Conversation? _conversation;
  Timer? _typingTimer;
  bool _isTyping = false;
  List<String> _typingUsers = [];
  Timer? _typingUsersTimer;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _markMessagesAsRead();
    _startTypingUsersTimer();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _typingUsersTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final conversation =
        await _chatService.getConversation(widget.conversationId);
    if (mounted) {
      setState(() {
        _conversation = conversation;
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    await _chatService.markMessagesAsRead(widget.conversationId);
  }

  void _startTypingUsersTimer() {
    _typingUsersTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final typingUsers =
          await _chatService.getTypingUsers(widget.conversationId);
      if (mounted) {
        setState(() {
          _typingUsers = typingUsers;
        });
      }
    });
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();

    // Set typing to false
    if (_isTyping) {
      _isTyping = false;
      _typingTimer?.cancel();
      await _chatService.setTypingStatus(
        conversationId: widget.conversationId,
        isTyping: false,
      );
    }

    // Send the message
    await _chatService.sendMessage(
      conversationId: widget.conversationId,
      content: messageText,
    );
  }

  void _onTyping() {
    if (!_isTyping) {
      _isTyping = true;
      _chatService.setTypingStatus(
        conversationId: widget.conversationId,
        isTyping: true,
      );
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () async {
      if (_isTyping) {
        _isTyping = false;
        await _chatService.setTypingStatus(
          conversationId: widget.conversationId,
          isTyping: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: _conversation != null
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: _conversation!
                            .getPhotoURL(_chatService.currentUserId)
                            .isNotEmpty
                        ? NetworkImage(_conversation!
                            .getPhotoURL(_chatService.currentUserId))
                        : null,
                    backgroundColor: Colors.blue,
                    child: _conversation!
                            .getPhotoURL(_chatService.currentUserId)
                            .isEmpty
                        ? _conversation!.isGroup
                            ? const Icon(Icons.group,
                                color: Colors.white, size: 16)
                            : Text(
                                _conversation!
                                    .getDisplayName(
                                        _chatService.currentUserId)[0]
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _conversation!
                              .getDisplayName(_chatService.currentUserId),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_typingUsers.isNotEmpty)
                          Text(
                            _typingUsers.length == 1
                                ? '${_typingUsers[0]} is typing...'
                                : '${_typingUsers.length} people are typing...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            : const Text('Loading...'),
        actions: [
          if (_conversation?.isGroup == true)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // TODO: Show group info
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading messages: ${snapshot.error}',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white.withOpacity(0.3),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Display messages from bottom to top
                  itemCount: messages.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMyMessage =
                        message.senderId == _chatService.currentUserId;
                    final showAvatar =
                        !isMyMessage && (_conversation?.isGroup ?? false);

                    // Format timestamp
                    final timestamp = message.timestamp;
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final yesterday = today.subtract(const Duration(days: 1));
                    final messageDate = DateTime(
                        timestamp.year, timestamp.month, timestamp.day);

                    String formattedTime;
                    if (messageDate == today) {
                      formattedTime = DateFormat('h:mm a').format(timestamp);
                    } else if (messageDate == yesterday) {
                      formattedTime =
                          'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
                    } else {
                      formattedTime =
                          DateFormat('MMM d, h:mm a').format(timestamp);
                    }

                    final sender = showAvatar
                        ? _conversation
                                ?.participants[message.senderId]?.displayName ??
                            'Unknown'
                        : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: isMyMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Show avatar for group chats (only for others' messages)
                          if (showAvatar) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: _conversation
                                          ?.participants[message.senderId]
                                          ?.photoURL
                                          .isNotEmpty ??
                                      false
                                  ? NetworkImage(_conversation!
                                      .participants[message.senderId]!.photoURL)
                                  : null,
                              backgroundColor: Colors.purple,
                              child: (_conversation
                                          ?.participants[message.senderId]
                                          ?.photoURL
                                          .isEmpty ??
                                      true)
                                  ? Text(
                                      (sender?.isNotEmpty ?? false)
                                          ? sender![0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Message bubble
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMyMessage
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                // Sender name for group chats
                                if (showAvatar && sender != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, bottom: 4),
                                    child: Text(
                                      sender,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                // Message content
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMyMessage
                                        ? const Color(0xFF0A84FF)
                                        : const Color(0xFF2C2C2E),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMyMessage
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (message.isTextMessage)
                                        Text(
                                          message.content,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      if (message.isImageMessage)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            message.mediaUrl!,
                                            width: 200,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return SizedBox(
                                                width: 200,
                                                height: 150,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      if (message.isFileMessage)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.insert_drive_file,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                message.content,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          color: isMyMessage
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.white.withOpacity(0.5),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Read status (only for my messages)
                                if (isMyMessage)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 4, right: 4),
                                    child: Text(
                                      message.status == MessageStatus.sent
                                          ? 'Sent'
                                          : message.status ==
                                                  MessageStatus.delivered
                                              ? 'Delivered'
                                              : 'Read',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Space to balance the avatar
                          if (isMyMessage && showAvatar)
                            const SizedBox(width: 40),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Typing indicator
          if (_typingUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                _typingUsers.length == 1
                    ? '${_typingUsers[0]} is typing...'
                    : '${_typingUsers.length} people are typing...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement file attachment
                    },
                  ),

                  // Message input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (_) => _onTyping(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),

                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
