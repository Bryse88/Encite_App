import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/ChatComponents/chat_service.dart';
import 'package:encite/components/GroupComponents/createGroupPage.dart';
import 'package:encite/components/GroupComponents/groupService.dart';
import 'package:encite/pages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:encite/components/Colors/uber_colors.dart';
import 'package:encite/components/group_components/schedule_input.dart';
import 'package:encite/components/ChatComponents/chat_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  // Initialize services
  final GroupService _groupService = GroupService();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Add this line

  // State variables
  List<Map<String, dynamic>> groups = [];
  Map<String, dynamic>? selectedGroup;
  bool isLoading = true;
  StreamSubscription? _groupsSubscription;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    super.dispose();
  }

  void _loadGroups() {
    setState(() {
      isLoading = true;
    });

    _groupsSubscription = _groupService.getGroups().listen((fetchedGroups) {
      setState(() {
        groups = fetchedGroups;
        isLoading = false;
      });
    }, onError: (error, stackTrace) {
      print('🔥 Firestore Error: $error');
      print('📍 StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading groups. See console log.')),
      );

      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading groups: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Groups',
          style: TextStyle(
            color: UberColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          if (selectedGroup == null)
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: _showCreateGroupDialog,
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : selectedGroup == null
              ? _buildGroupsGrid()
              : _buildGroupDetailPage(),
    );
  }

  Widget _buildGroupsGrid() {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No groups yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showCreateGroupDialog,
              child: Text('Create a Group'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildGroupWidget(group);
        },
      ),
    );
  }

  Widget _buildGroupWidget(Map<String, dynamic> group) {
    final participants = group['participants'] as Map<String, dynamic>;

    return InkWell(
      onTap: () {
        setState(() {
          selectedGroup = group;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name and Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    group['name'] ?? 'Unnamed Group',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(group['participantIds'] as List).length} members',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Member Avatars
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (group['participantIds'] as List)
                  .take(9)
                  .map<Widget>((userId) {
                final participant = participants[userId];
                if (participant == null) {
                  return SizedBox.shrink();
                }

                return CircleAvatar(
                  radius: 20,
                  backgroundImage: participant['photoURL'] != null &&
                          participant['photoURL'].toString().isNotEmpty
                      ? NetworkImage(participant['photoURL'])
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: participant['photoURL'] == null ||
                          participant['photoURL'].toString().isEmpty
                      ? Text(participant['displayName'] != null &&
                              participant['displayName'].toString().isNotEmpty
                          ? participant['displayName'][0]
                          : '?')
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupDetailPage() {
    if (selectedGroup == null) return SizedBox.shrink();

    final participants = selectedGroup!['participants'] as Map<String, dynamic>;
    final participantIds =
        List<String>.from(selectedGroup!['participantIds'] ?? []);
    final currentUserId = _auth.currentUser?.uid ?? '';

    // Check if current user is admin
    final currentUserParticipant = participants[currentUserId];
    final isAdmin = currentUserParticipant != null &&
        currentUserParticipant['role'] == 'admin';

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          selectedGroup = null;
        });
        return false;
      },
      child: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 80,
        ),
        children: [
          // Header with back button and group name
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      selectedGroup = null;
                    });
                  },
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedGroup!['name'] ?? 'Unnamed Group',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _showEditGroupNameDialog,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Buttons: Chat + Create Schedule
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('Group Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: _openGroupChat,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Create Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupSchedulerForm(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Add Person (admin only)
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Add Person'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _showAddPersonDialog,
              ),
            ),

          const SizedBox(height: 16),

          // Member List
          ...participantIds.map((userId) {
            final participant = participants[userId];
            if (participant == null) return SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMemberListItem(userId, participant),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMemberListItem(String userId, Map<String, dynamic> participant) {
    final currentUserId = _auth.currentUser?.uid ?? '';
    final isCurrentUser = userId == currentUserId;
    final isAdmin = participant['role'] == 'admin';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant['photoURL'] != null &&
                  participant['photoURL'].toString().isNotEmpty
              ? NetworkImage(participant['photoURL'])
              : null,
          child: participant['photoURL'] == null ||
                  participant['photoURL'].toString().isEmpty
              ? Text(participant['displayName'][0])
              : null,
        ),
        title: Text(
          participant['displayName'] ?? 'Unknown',
          style: TextStyle(
            fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: isAdmin
            ? Text('Admin', style: TextStyle(color: Colors.blue))
            : null,
        trailing: selectedGroup != null &&
                selectedGroup!['participants'] != null &&
                selectedGroup!['participants'][currentUserId] != null &&
                selectedGroup!['participants'][currentUserId]['role'] ==
                    'admin' &&
                !isCurrentUser
            ? IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red[400]),
                onPressed: () {
                  _showRemoveMemberDialog(userId, participant['displayName']);
                },
              )
            : isCurrentUser && !isAdmin
                ? TextButton(
                    child: Text('Leave', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      _showLeaveGroupDialog();
                    },
                  )
                : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  // void _showCreateGroupDialog() {
  //   final TextEditingController nameController = TextEditingController();
  //   List<String> selectedUserIds = [];

  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setDialogState) {
  //         return AlertDialog(
  //           title: Text('Create New Group'),
  //           content: Container(
  //             width: MediaQuery.of(context).size.width * 0.9,
  //             height: MediaQuery.of(context).size.height * 0.6,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: nameController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Group Name',
  //                     hintText: 'Enter a name for your group',
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 const Text(
  //                   'Select Members:',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Expanded(
  //                   child: FutureBuilder<List<Map<String, dynamic>>>(
  //                     future: _chatService.searchUsers(''),
  //                     builder: (context, snapshot) {
  //                       if (snapshot.connectionState ==
  //                           ConnectionState.waiting) {
  //                         return const Center(
  //                             child: CircularProgressIndicator());
  //                       }

  //                       if (snapshot.hasError) {
  //                         return const Text('Error loading users');
  //                       }

  //                       final users = snapshot.data ?? [];

  //                       // Use SingleChildScrollView with Column instead of ListView.builder
  //                       return SingleChildScrollView(
  //                         child: Column(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: users.map((user) {
  //                             final userId = user['id'];
  //                             final isSelected =
  //                                 selectedUserIds.contains(userId);

  //                             return CheckboxListTile(
  //                               value: isSelected,
  //                               onChanged: (value) {
  //                                 setDialogState(() {
  //                                   if (value == true) {
  //                                     selectedUserIds.add(userId);
  //                                   } else {
  //                                     selectedUserIds.remove(userId);
  //                                   }
  //                                 });
  //                               },
  //                               title: Text(user['displayName'] ?? 'Unknown'),
  //                               secondary: CircleAvatar(
  //                                 backgroundImage: user['photoURL'] != null
  //                                     ? NetworkImage(user['photoURL'])
  //                                     : null,
  //                                 child: user['photoURL'] == null
  //                                     ? Text((user['displayName'] as String)
  //                                             .isNotEmpty
  //                                         ? (user['displayName'] as String)[0]
  //                                         : '?')
  //                                     : null,
  //                               ),
  //                             );
  //                           }).toList(),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 if (nameController.text.trim().isEmpty) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Please enter a group name')),
  //                   );
  //                   return;
  //                 }

  //                 if (selectedUserIds.isEmpty) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                         content: Text('Please select at least one member')),
  //                   );
  //                   return;
  //                 }

  //                 Navigator.pop(context);

  //                 // Show loading dialog
  //                 showDialog(
  //                   context: context,
  //                   barrierDismissible: false,
  //                   builder: (context) =>
  //                       Center(child: CircularProgressIndicator()),
  //                 );

  //                 try {
  //                   final groupId = await _groupService.createGroupWithChat(
  //                     groupName: nameController.text.trim(),
  //                     memberIds: selectedUserIds,
  //                   );

  //                   _loadGroups(); // Refresh UI

  //                   Navigator.pop(context); // Close loading dialog

  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Group created successfully')),
  //                   );
  //                 } catch (e) {
  //                   Navigator.pop(context); // Close loading dialog

  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Error creating group: $e')),
  //                   );
  //                 }
  //               },
  //               child: Text('Create'),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  void _showCreateGroupDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupPage(
          onCreateGroup: _createGroup,
        ),
      ),
    );
  }

  Future<void> _createGroup(String groupName, List<String> memberIds) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final groupId = await _groupService.createGroupWithChat(
        groupName: groupName,
        memberIds: memberIds,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Refresh UI
      _loadGroups();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully')),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $e')),
      );
    }
  }

  void _showEditGroupNameDialog() {
    if (selectedGroup == null) return;

    final TextEditingController controller = TextEditingController(
      text: selectedGroup!['name'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Group Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new group name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group name cannot be empty')),
                );
                return;
              }

              Navigator.of(context).pop();

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );

              try {
                // Update group name in Firestore
                await _firestore
                    .collection('groups')
                    .doc(selectedGroup!['id'])
                    .update({'name': newName});

                // Update conversation name as well
                await _firestore
                    .collection('conversations')
                    .doc(selectedGroup!['linkedConversationId'])
                    .update({'groupName': newName});

                // Update local state
                setState(() {
                  selectedGroup!['name'] = newName;
                });

                // Close loading dialog
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group name updated')),
                );
              } catch (e) {
                // Close loading dialog
                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating group name: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog() {
    if (selectedGroup == null) return;

    // Get current participant IDs to exclude from search
    final currentParticipantIds =
        List<String>.from(selectedGroup!['participantIds'] ?? []);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Person to Group'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Select people to add to the group:'),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future:
                      _chatService.searchUsers(''), // Empty to get recent users
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading users: ${snapshot.error}'),
                      );
                    }

                    final users = snapshot.data ?? [];

                    // Filter out users already in the group
                    final filteredUsers = users
                        .where((user) =>
                            !currentParticipantIds.contains(user['id']))
                        .toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Text('No more users to add'),
                      );
                    }

                    // Use SingleChildScrollView with Column instead of ListView.builder
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: filteredUsers.map((user) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user['photoURL'] != null
                                  ? NetworkImage(user['photoURL'])
                                  : null,
                              child: user['photoURL'] == null
                                  ? Text(
                                      (user['displayName'] as String).isNotEmpty
                                          ? (user['displayName'] as String)[0]
                                          : '?')
                                  : null,
                            ),
                            title: Text(user['displayName'] ?? 'Unknown'),
                            subtitle: Text(user['userName'] ?? ''),
                            onTap: () async {
                              Navigator.pop(context);

                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              try {
                                await _groupService.addUserToGroup(
                                  groupId: selectedGroup!['id'],
                                  userId: user['id'],
                                );

                                // Refresh group data
                                _loadGroups();

                                // Close loading dialog
                                Navigator.pop(context);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${user['displayName']} added to the group'),
                                  ),
                                );
                              } catch (e) {
                                // Close loading dialog
                                Navigator.pop(context);

                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding user: $e'),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(String userId, String userName) {
    if (selectedGroup == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Member'),
        content:
            Text('Are you sure you want to remove $userName from this group?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Remove'),
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );

              try {
                await _groupService.removeUserFromGroup(
                  groupId: selectedGroup!['id'],
                  userId: userId,
                );

                // Refresh group data
                _loadGroups();

                // Close loading dialog
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$userName removed from the group')),
                );
              } catch (e) {
                // Close loading dialog
                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error removing user: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupDialog() {
    if (selectedGroup == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Group'),
        content: Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Leave'),
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );

              try {
                await _groupService.removeUserFromGroup(
                  groupId: selectedGroup!['id'],
                  userId: _auth.currentUser?.uid ?? '',
                );

                // Close loading dialog
                Navigator.pop(context);

                // Go back to groups list
                setState(() {
                  selectedGroup = null;
                });

                // Refresh groups list
                _loadGroups();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have left the group')),
                );
              } catch (e) {
                // Close loading dialog
                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error leaving group: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _openGroupChat() {
    if (selectedGroup == null) return;

    final conversationId = selectedGroup!['linkedConversationId'];
    if (conversationId == null || conversationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No linked conversation found')),
      );
      return;
    }

    // Navigate to chat screen
    // Replace this with your actual navigation logic to the chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(conversationId: conversationId), // Create this screen
      ),
    );
  }
}
