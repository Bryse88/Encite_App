import 'package:flutter/material.dart';
import 'package:encite/components/Colors/uber_colors.dart';
import 'package:encite/components/ChatComponents/chat_service.dart';

class CreateGroupPage extends StatefulWidget {
  final Function(String groupName, List<String> memberIds) onCreateGroup;

  const CreateGroupPage({Key? key, required this.onCreateGroup})
      : super(key: key);

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 2;

  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedUserIds = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      // Use the ChatService to get users
      final users = await ChatService().searchUsers('');

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final displayName = (user['displayName'] ?? '').toLowerCase();
          final userName = (user['userName'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return displayName.contains(searchLower) ||
              userName.contains(searchLower);
        }).toList();
      }
    });
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validate group name
      if (_groupNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a group name')),
        );
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      // Final page - create the group
      _createGroup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    } else {
      // First page - go back to groups list
      Navigator.pop(context);
    }
  }

  void _createGroup() async {
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onCreateGroup(
        _groupNameController.text.trim(),
        _selectedUserIds,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error creating group: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      }
    }
  }

  // Toggle user selection
  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Group',
          style: TextStyle(
            color: UberColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousPage,
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Creating your Group",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : PageView(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent user scrolling
              children: [
                // Page 1: Group Name
                _buildGroupNamePage(),

                // Page 2: Member Selection
                _buildMemberSelectionPage(),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      height: 56.0,
                      width: 56.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF007AFF),
                          width: 2.0,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _previousPage,
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Next/Create button
                  Expanded(
                    child: Container(
                      height: 56.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _nextPage,
                          child: Center(
                            child: Text(
                              _currentPage == _totalPages - 1
                                  ? 'Create Group'
                                  : 'Next',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildGroupNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name your group',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a name that represents your group',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
              hintText: 'Enter a name for your group',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: const Icon(Icons.group),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          // Example group names for inspiration
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Examples: College Friends, Book Club, Family',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelectionPage() {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: 'Search people',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // Selected users count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected: ${_selectedUserIds.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedUserIds.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedUserIds.clear()),
                  child: const Text('Clear All'),
                )
            ],
          ),
        ),

        // User list
        Expanded(
          child: _filteredUsers.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'No users found'
                        : 'No users found matching "$_searchQuery"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    final userId = user['id'];
                    final isSelected = _selectedUserIds.contains(userId);

                    return Card(
                      elevation: isSelected ? 2 : 0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['photoURL'] != null
                              ? NetworkImage(user['photoURL'])
                              : null,
                          backgroundColor:
                              isSelected ? Colors.blue[100] : Colors.grey[200],
                          child: user['photoURL'] == null
                              ? Text((user['displayName'] as String).isNotEmpty
                                  ? (user['displayName'] as String)[0]
                                  : '?')
                              : null,
                        ),
                        title: Text(
                          user['displayName'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: user['userName'] != null &&
                                user['userName'].toString().isNotEmpty
                            ? Text('@${user['userName']}')
                            : null,
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        onTap: () => _toggleUserSelection(userId),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }
}
