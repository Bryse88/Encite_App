import 'package:encite/components/group_components/schedule_input.dart';
import 'package:flutter/material.dart';

// Model classes
class GroupMember {
  final int id;
  final String name;
  final String avatarUrl;

  GroupMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });
}

class Group {
  final int id;
  String name;
  List<GroupMember> members;

  Group({
    required this.id,
    required this.name,
    required this.members,
  });
}

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  // Mock data for groups
  List<Group> groups = [
    Group(
      id: 1,
      name: 'Brunch Club',
      members: [
        GroupMember(
            id: 1,
            name: 'Alex Johnson',
            avatarUrl: 'https://i.pravatar.cc/150?img=1'),
        GroupMember(
            id: 2,
            name: 'Sarah Williams',
            avatarUrl: 'https://i.pravatar.cc/150?img=2'),
        GroupMember(
            id: 3,
            name: 'Miguel Rodriguez',
            avatarUrl: 'https://i.pravatar.cc/150?img=3'),
        GroupMember(
            id: 4,
            name: 'Priya Patel',
            avatarUrl: 'https://i.pravatar.cc/150?img=4'),
        GroupMember(
            id: 5,
            name: 'David Chen',
            avatarUrl: 'https://i.pravatar.cc/150?img=5'),
      ],
    ),
    Group(
      id: 2,
      name: 'Hometown Friends',
      members: [
        GroupMember(
            id: 1,
            name: 'Alex Johnson',
            avatarUrl: 'https://i.pravatar.cc/150?img=1'),
        GroupMember(
            id: 6,
            name: 'Emma Wilson',
            avatarUrl: 'https://i.pravatar.cc/150?img=6'),
        GroupMember(
            id: 7,
            name: 'James Taylor',
            avatarUrl: 'https://i.pravatar.cc/150?img=7'),
      ],
    ),
    Group(
      id: 3,
      name: 'Work Friends',
      members: [
        GroupMember(
            id: 8,
            name: 'Lisa Brown',
            avatarUrl: 'https://i.pravatar.cc/150?img=8'),
        GroupMember(
            id: 9,
            name: 'Tom Garcia',
            avatarUrl: 'https://i.pravatar.cc/150?img=9'),
        GroupMember(
            id: 10,
            name: 'Nina Patel',
            avatarUrl: 'https://i.pravatar.cc/150?img=10'),
        GroupMember(
            id: 11,
            name: 'Omar Hassan',
            avatarUrl: 'https://i.pravatar.cc/150?img=11'),
      ],
    ),
    Group(
      id: 4,
      name: 'Date Night',
      members: [
        GroupMember(
            id: 12,
            name: 'Mei Lin',
            avatarUrl: 'https://i.pravatar.cc/150?img=12'),
      ],
    ),
  ];

  Group? selectedGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        elevation: 0,
      ),
      body:
          selectedGroup == null ? _buildGroupsGrid() : _buildGroupDetailPage(),
    );
  }

  Widget _buildGroupsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildGroupWidget(Group group) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedGroup = group;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
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
                    group.name,
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
                    '${group.members.length} members',
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
            // Member Avatars (wrapped)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: group.members.take(9).map((member) {
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(member.avatarUrl),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberGrid(List<GroupMember> members) {
    // Display up to 9 members in a grid
    final displayMembers = members.length > 9 ? members.sublist(0, 9) : members;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      physics: NeverScrollableScrollPhysics(),
      itemCount: displayMembers.length + (members.length > 9 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < displayMembers.length) {
          return CircleAvatar(
            backgroundImage: NetworkImage(displayMembers[index].avatarUrl),
          );
        } else {
          // Show a "+X more" indicator if not all members are displayed
          return CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text(
              "+${members.length - 9}",
              style: TextStyle(color: Colors.black),
            ),
          );
        }
      },
    );
  }

  Widget _buildGroupDetailPage() {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          selectedGroup = null;
        });
        return false;
      },
      child: Column(
        children: [
          // Header with back button and group name
          Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
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
                          selectedGroup!.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          _showEditGroupNameDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Group members list
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: selectedGroup!.members.length +
                      1, // +1 for the "Add Person" button
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add Person button at the top
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.person_add),
                          label: Text('Add Person'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            _showAddPersonDialog();
                          },
                        ),
                      );
                    }

                    final member = selectedGroup!.members[index - 1];
                    return _buildMemberListItem(member);
                  },
                ),

                // Create Schedule button at the bottom
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text('Create Schedule'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchedulerForm(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberListItem(GroupMember member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(member.avatarUrl),
        ),
        title: Text(member.name),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.red[400]),
          onPressed: () {
            _showRemoveMemberDialog(member);
          },
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  void _showEditGroupNameDialog() {
    final TextEditingController controller =
        TextEditingController(text: selectedGroup!.name);

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
            onPressed: () {
              setState(() {
                selectedGroup!.name = controller.text.trim();
                // Update the group in the main list
                final index =
                    groups.indexWhere((g) => g.id == selectedGroup!.id);
                if (index != -1) {
                  groups[index].name = controller.text.trim();
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog() {
    // Mock new people that could be added
    final List<GroupMember> potentialMembers = [
      GroupMember(
          id: 20,
          name: 'Jamie Lee',
          avatarUrl: 'https://i.pravatar.cc/150?img=20'),
      GroupMember(
          id: 21,
          name: 'Sanjay Gupta',
          avatarUrl: 'https://i.pravatar.cc/150?img=21'),
      GroupMember(
          id: 22,
          name: 'Olivia Parker',
          avatarUrl: 'https://i.pravatar.cc/150?img=22'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Person to Group'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: potentialMembers.length,
                  itemBuilder: (context, index) {
                    final member = potentialMembers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(member.avatarUrl),
                      ),
                      title: Text(member.name),
                      onTap: () {
                        setState(() {
                          // Add the new member to the group
                          selectedGroup!.members.add(member);
                          // Update the group in the main list
                          final groupIndex = groups
                              .indexWhere((g) => g.id == selectedGroup!.id);
                          if (groupIndex != -1) {
                            groups[groupIndex].members.add(member);
                          }
                        });
                        Navigator.of(context).pop();
                      },
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

  void _showRemoveMemberDialog(GroupMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Member'),
        content: Text(
            'Are you sure you want to remove ${member.name} from this group?'),
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
            onPressed: () {
              setState(() {
                // Remove the member from the group
                selectedGroup!.members.removeWhere((m) => m.id == member.id);
                // Update the group in the main list
                final groupIndex =
                    groups.indexWhere((g) => g.id == selectedGroup!.id);
                if (groupIndex != -1) {
                  groups[groupIndex]
                      .members
                      .removeWhere((m) => m.id == member.id);
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
