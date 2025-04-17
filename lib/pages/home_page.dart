import 'dart:ui';
import 'package:encite/components/LoginComponents/gradient_background.dart';
import 'package:encite/pages/messaging_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encite/components/Navigation/location_widget.dart';
import 'package:encite/pages/group_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _firstName = '';
  bool _isLoading = true;
  bool isAvailable = true;

  // MyDay related state properties
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _datesWithEvents = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().add(const Duration(days: 8)),
    DateTime.now().add(const Duration(days: 15)),
  ];

  final List<Map<String, dynamic>> _availableFriends = [
    {
      'name': 'Alex Johnson',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'status': 'Online',
    },
    {
      'name': 'Sarah Williams',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'status': 'Away',
    },
    {
      'name': 'Miguel Rodriguez',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'status': 'Online',
    },
    {
      'name': 'Priya Patel',
      'avatar': 'https://i.pravatar.cc/150?img=4',
      'status': 'Busy',
    },
    {
      'name': 'David Chen',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'status': 'Online',
    },
  ];

  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'isGroup': true,
      'groupName': 'Study Group',
      'title': 'Final Exam Prep',
      'time': '3:30 PM - 5:00 PM',
      'location': 'Library, Room 204',
      'participants': 5,
    },
    {
      'isGroup': false,
      'title': 'Dentist Appointment',
      'time': 'Tomorrow, 10:00 AM',
      'location': 'Smile Dental Clinic',
      'participants': 0,
    },
    {
      'isGroup': true,
      'groupName': 'Soccer Team',
      'title': 'Weekly Practice',
      'time': 'Saturday, 9:00 AM',
      'location': 'Central Park Field',
      'participants': 12,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    SharedPreferences.getInstance().then((prefs) {
      final cached = prefs.getString('cachedName');
      if (cached != null && mounted) {
        setState(() {
          _firstName = cached;
          _isLoading = false;
        });
      }
    });

    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString('cachedName');

      if (cachedName != null && cachedName.isNotEmpty) {
        setState(() {
          _firstName = cachedName;
          _isLoading = false;
        });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _firstName = 'there';
          _isLoading = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final fullName = data['name'] as String? ?? 'there';
        final firstName = fullName.split(' ')[0];

        await prefs.setString('cachedName', firstName);

        setState(() {
          _firstName = firstName;
          _isLoading = false;
        });
      } else {
        setState(() {
          _firstName = 'there';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching name: \$e');
      setState(() {
        _firstName = 'there';
        _isLoading = false;
      });
    }
  }

  Future<void> logAvailabilityStatus(bool status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('statusLogs')
          .add({
        'status': status ? 'Free' : 'Busy',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Widget buildAvailabilityToggle() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: isAvailable
                  ? [Color(0xFF007AFF), Color(0xFF5AC8FA)]
                  : [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              setState(() => isAvailable = !isAvailable);
              logAvailabilityStatus(isAvailable);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle : Icons.do_not_disturb,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? 'Available' : 'Busy',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatsPage()),
            );
          },
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.message_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasEvent(DateTime date) {
    return _datesWithEvents.any((eventDate) =>
        eventDate.year == date.year &&
        eventDate.month == date.month &&
        eventDate.day == date.day);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header from HomePage (greeting and availability toggle)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 120,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white10,
                              color: Colors.white38,
                            ),
                          )
                        : Text(
                            'Hey, $_firstName!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    buildAvailabilityToggle(),
                  ],
                ),
              ),

              // Content from MyDayScreen
              Expanded(
                child: _buildMyDayContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyDayContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 800;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LocationWidget(),
                          const SizedBox(height: 20),
                          _buildCalendarWidget(),
                          const SizedBox(height: 20),
                          _buildAddGroupWidget(),
                          const SizedBox(height: 16),
                          _buildAddFriendWidget(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Right Column
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvailableFriendsWidget(),
                          const SizedBox(height: 20),
                          _buildUpcomingEventsWidget(),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const LocationWidget(),
                    const SizedBox(height: 20),
                    _buildAddGroupWidget(),
                    const SizedBox(height: 20),
                    _buildAddSingleWidget(),
                    const SizedBox(height: 20),
                    _buildAvailableFriendsWidget(),
                    const SizedBox(height: 20),

                    _buildCalendarWidget(),
                    const SizedBox(height: 16),
                    // _buildAddFriendWidget(),
                    const SizedBox(height: 20),
                    _buildUpcomingEventsWidget(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCalendarWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year, _selectedDate.month - 1, 1);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year, _selectedDate.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Day labels (Mon, Tue, etc.)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),

          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Get the first day of the selected month
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);

    // Calculate days from previous month to display
    // (e.g., if first day is Wednesday, we need to show Mon & Tue from previous month)
    final daysFromPreviousMonth = (firstDay.weekday - 1) % 7;

    // Calculate the total number of days in the selected month
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    // Calculate the total days to display (including some from previous and next months)
    // We always show 6 weeks (42 days)
    const totalDaysToDisplay = 42;

    // Generate all the dates to display
    final displayDates = <DateTime>[];

    // Add dates from previous month
    if (daysFromPreviousMonth > 0) {
      final lastMonthLastDay =
          DateTime(_selectedDate.year, _selectedDate.month, 0).day;
      for (int i = 0; i < daysFromPreviousMonth; i++) {
        displayDates.add(
          DateTime(_selectedDate.year, _selectedDate.month - 1,
              lastMonthLastDay - daysFromPreviousMonth + i + 1),
        );
      }
    }

    // Add dates from current month
    for (int i = 1; i <= daysInMonth; i++) {
      displayDates.add(DateTime(_selectedDate.year, _selectedDate.month, i));
    }

    // Add dates from next month to fill the grid
    final remainingDays = totalDaysToDisplay - displayDates.length;
    for (int i = 1; i <= remainingDays; i++) {
      displayDates
          .add(DateTime(_selectedDate.year, _selectedDate.month + 1, i));
    }

    // Build the grid with 6 rows
    return Column(
      children: List.generate(6, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final index = rowIndex * 7 + colIndex;
              final date = displayDates[index];
              final isCurrentMonth = date.month == _selectedDate.month;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              final hasEvent = _hasEvent(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: isToday
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color:
                              isCurrentMonth ? Colors.black : Colors.grey[400],
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildAddGroupWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Open group creation dialog/page
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Solo Schedule',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Create a schedule for yourself',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSingleWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Open group creation dialog/page
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Group Schedule',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Create a schedule with a group',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFriendWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Open friend search dialog/page
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Expand your network',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableFriendsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Friends',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: Stack(
              children: List.generate(_availableFriends.length, (index) {
                final friend = _availableFriends[index];
                return Positioned(
                  left: index * 40.0, // Adjust spacing here
                  child: _buildAvailableFriendAvatar(friend),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_availableFriends.length} Online',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GroupsPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View All Friends'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableFriendAvatar(Map<String, dynamic> friend) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(friend['avatar']),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: friend['status'] == 'Online'
                  ? Colors.green
                  : friend['status'] == 'Away'
                      ? Colors.amber
                      : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          for (var event in _upcomingEvents) ...[
            _buildEventCard(event),
            if (event != _upcomingEvents.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event['isGroup'] ? event['groupName'] : 'Personal',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event['time'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event['title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                event['location'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (event['participants'] > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < min(3, event['participants']); i++)
                      Container(
                        margin: EdgeInsets.only(right: 4),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (event['participants'] > 3)
                      Text(
                        '+${event['participants'] - 3}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'RSVP',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
