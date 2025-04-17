import 'dart:ui';
import 'package:encite/pages/solo_scheduler_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encite/components/Navigation/location_widget.dart';
import 'package:encite/pages/group_page.dart';
import 'package:encite/pages/messaging_page.dart';
import 'package:intl/intl.dart';

// Uber-inspired color constants
class UberColors {
  static const Color primary = Color(0xFF276EF1); // Uber Blue
  static const Color background = Color(0xFF121212); // Very dark gray/black
  static const Color surface = Color(0xFF1C1C1E); // Slightly lighter dark
  static const Color cardBg = Color(0xFF222222); // Card background
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFAAAAAA); // Light gray
  static const Color accent = Color(0xFF15D071); // Success green
  static const Color divider = Color(0xFF2A2A2A); // Dark gray divider
  static const Color error = Color(0xFFE51919); // Error/alert red
}

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
        // Updated toggle with Uber-style colors and aesthetics
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isAvailable
                ? UberColors.primary.withOpacity(0.15)
                : UberColors.cardBg,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
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
                    isAvailable ? Icons.circle : Icons.do_not_disturb,
                    color: isAvailable
                        ? UberColors.primary
                        : UberColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? 'Available' : 'Busy',
                    style: TextStyle(
                      color: isAvailable
                          ? UberColors.primary
                          : UberColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Updated message button with Uber styling
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: UberColors.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: UberColors.textPrimary,
                  size: 18,
                ),
              ),
              // Notification dot
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: UberColors.error,
                    borderRadius: BorderRadius.circular(5),
                    border:
                        Border.all(color: UberColors.background, width: 1.5),
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
    return Scaffold(
      // Use Uber's dark color scheme
      backgroundColor: UberColors.background,
      body: Stack(
        children: [
          // Background with subtle gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [UberColors.background, Color(0xFF0A0A0A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Foreground UI
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: greeting + toggle with improved styling
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _isLoading
                          ? Container(
                              height: 24,
                              width: 120,
                              decoration: BoxDecoration(
                                color: UberColors.cardBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                          : Text(
                              'Hey, $_firstName!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: UberColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                      buildAvailabilityToggle(),
                    ],
                  ),
                ),
                // Main content scroll
                Expanded(
                  child: _buildMyDayContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDayContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 800;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                          const SizedBox(height: 24),
                          _buildCalendarWidget(),
                          const SizedBox(height: 24),
                          _buildAddGroupWidget(),
                          const SizedBox(height: 24),
                          _buildAddFriendWidget(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right Column
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvailableFriendsWidget(),
                          const SizedBox(height: 24),
                          _buildUpcomingEventsWidget(),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildAddGroupWidget(),
                    const SizedBox(height: 24),
                    _buildAddSingleWidget(),
                    const SizedBox(height: 24),
                    _buildAvailableFriendsWidget(),
                    const SizedBox(height: 24),
                    _buildCalendarWidget(),
                    const SizedBox(height: 24),
                    _buildUpcomingEventsWidget(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCalendarWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: UberColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: UberColors.textPrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year, _selectedDate.month - 1, 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: UberColors.textPrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year, _selectedDate.month + 1, 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day labels (Mon, Tue, etc.)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Text(
                      day,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: UberColors.textSecondary,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

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
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: isSelected
                      ? BoxDecoration(
                          color: UberColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        )
                      : isToday
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: UberColors.primary,
                                width: 1.5,
                              ),
                            )
                          : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isCurrentMonth
                              ? (isSelected
                                  ? UberColors.primary
                                  : UberColors.textPrimary)
                              : UberColors.textSecondary.withOpacity(0.5),
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: UberColors.primary,
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
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SoloSchedulerForm(),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: UberColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: UberColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Create Solo Schedule',
                    style: TextStyle(
                      color: UberColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Create a schedule for yourself',
                    style: TextStyle(
                      color: UberColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: UberColors.textSecondary,
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
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => GroupsPage()),
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: UberColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_outlined,
                color: UberColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Create Group Schedule',
                    style: TextStyle(
                      color: UberColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Create a schedule with a group',
                    style: TextStyle(
                      color: UberColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: UberColors.textSecondary,
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
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                color: UberColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_outlined,
                color: UberColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Add Friends',
                    style: TextStyle(
                      color: UberColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Expand your network',
                    style: TextStyle(
                      color: UberColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: UberColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableFriendsWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Friends',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: UberColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: UberColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: Stack(
              children: List.generate(_availableFriends.length, (index) {
                final friend = _availableFriends[index];
                return Positioned(
                  left: index * 36.0, // Increased spacing between avatars
                  child: _buildAvailableFriendAvatar(friend),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${_availableFriends.length} Online',
            style: const TextStyle(
              color: UberColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableFriendAvatar(Map<String, dynamic> friend) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: UberColors.background,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: friend['avatar'] != null
                ? NetworkImage(friend['avatar'])
                : null,
            backgroundColor: UberColors.surface,
            child: friend['avatar'] == null
                ? const Icon(
                    Icons.person,
                    color: UberColors.textSecondary,
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: friend['status'] == 'Online'
                    ? UberColors.accent // Green for online
                    : friend['status'] == 'Away'
                        ? Colors.amber // Amber for away
                        : UberColors.textSecondary, // Grey for busy
                shape: BoxShape.circle,
                border: Border.all(color: UberColors.background, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UberColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: UberColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          for (var event in _upcomingEvents) ...[
            _buildEventCard(event),
            if (event != _upcomingEvents.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UberColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UberColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event['isGroup']
                      ? UberColors.primary.withOpacity(0.1)
                      : UberColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event['isGroup'] ? event['groupName'] : 'Personal',
                  style: TextStyle(
                    color: event['isGroup']
                        ? UberColors.primary
                        : UberColors.accent,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: UberColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event['time'],
                    style: const TextStyle(
                      color: UberColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event['title'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: UberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: UberColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                event['location'],
                style: const TextStyle(
                  color: UberColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (event['participants'] > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < min(3, event['participants']); i++)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: UberColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: UberColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 14,
                            color: UberColors.textSecondary,
                          ),
                        ),
                      ),
                    if (event['participants'] > 3)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: UberColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '+${event['participants'] - 3}',
                            style: const TextStyle(
                              color: UberColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: UberColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'RSVP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
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
