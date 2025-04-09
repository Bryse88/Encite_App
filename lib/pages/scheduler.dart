import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({Key? key}) : super(key: key);

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage>
    with SingleTickerProviderStateMixin {
  int _selectedViewIndex = 0;
  late TabController _tabController;

  // Sample event data
  final List<ScheduleEvent> _events = [
    ScheduleEvent(
      title: '🍔 Lunch with Team',
      time: '12:30 PM',
      duration: 60,
      color: const Color(0xFFFF9500),
    ),
    ScheduleEvent(
      title: '📚 Study Session',
      time: '2:00 PM',
      duration: 90,
      color: const Color(0xFF5AC8FA),
    ),
    ScheduleEvent(
      title: '🧘 Mindfulness Break',
      time: '3:30 PM',
      duration: 15,
      color: const Color(0xFF4CD964),
    ),
    ScheduleEvent(
      title: '🏃 Gym Workout',
      time: '5:00 PM',
      duration: 60,
      color: const Color(0xFFFF2D55),
    ),
    ScheduleEvent(
      title: '💼 Weekly Planning',
      time: '6:30 PM',
      duration: 45,
      color: const Color(0xFF5856D6),
    ),
    ScheduleEvent(
      title: '🎮 Gaming Time',
      time: '8:00 PM',
      duration: 120,
      color: const Color(0xFFAF52DE),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedViewIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A1A),
                  Colors.black,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          child: Row(
                            children: [
                              Icon(Icons.auto_fix_high,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'AI Optimize',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // View selection tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color(0xFF007AFF),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withOpacity(0.5),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Prize Wheel'),
                            Tab(text: 'Orbit View'),
                            Tab(text: 'Standard'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Different schedule views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Prize Wheel View
                      PrizeWheelView(events: _events),

                      // Orbit View
                      OrbitView(events: _events),

                      // Standard View
                      StandardView(events: _events),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation bar with blur effect
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavBarItem(Icons.home_outlined, 'Home'),
                      _buildNavBarItem(Icons.schedule, 'Schedule',
                          isActive: true),
                      _buildNavBarItem(Icons.chat_bubble_outline, 'Chats'),
                      _buildNavBarItem(Icons.person_outline, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF007AFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Add new event
        },
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label,
      {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF007AFF) : Colors.white,
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? const Color(0xFF007AFF)
                : Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// Prize Wheel View
class PrizeWheelView extends StatelessWidget {
  final List<ScheduleEvent> events;

  const PrizeWheelView({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Today's date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Today, Mar 23',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Prize wheel visualization
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Central bar
              Container(
                height: 4,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),

              // Rotating wheel of events
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 120,
                  perspective: 0.005,
                  diameterRatio: 2.0,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: events.length,
                    builder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 32.0),
                        child: _buildPrizeWheelItem(events[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrizeWheelItem(ScheduleEvent event) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                event.color.withOpacity(0.4),
                event.color.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: event.color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: event.color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const SizedBox(width: 8),
                // Time column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${event.duration}min',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Vertical divider
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(width: 20),
                // Event details
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Orbit View
class OrbitView extends StatefulWidget {
  final List<ScheduleEvent> events;

  const OrbitView({Key? key, required this.events}) : super(key: key);

  @override
  State<OrbitView> createState() => _OrbitViewState();
}

class _OrbitViewState extends State<OrbitView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Today's date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Today, Mar 23',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Orbit visualization
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Central bar
              Container(
                height: 4,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),

              // Orbiting events
              ...List.generate(widget.events.length, (index) {
                // Distribute events along the timeline
                final timePosition =
                    (index / (widget.events.length - 1)) * 0.8 + 0.1;

                // Alternate above and below the axis
                final isAbove = index % 2 == 0;
                final verticalOffset = isAbove ? -0.15 : 0.15;

                // Create animation for orbit effect
                final animation = Tween(
                  begin: verticalOffset - 0.05,
                  end: verticalOffset + 0.05,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index / widget.events.length),
                      (index / widget.events.length) + 0.1,
                      curve: Curves.easeInOut,
                    ),
                  ),
                );

                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      left: MediaQuery.of(context).size.width * timePosition,
                      top: MediaQuery.of(context).size.height *
                          (0.5 + animation.value),
                      child: _buildOrbitItem(widget.events[index], isAbove),
                    );
                  },
                );
              }),

              // Time indicators on the axis
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45,
                left: MediaQuery.of(context).size.width * 0.1,
                child: _buildTimeIndicator('9 AM'),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45,
                left: MediaQuery.of(context).size.width * 0.35,
                child: _buildTimeIndicator('12 PM'),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45,
                left: MediaQuery.of(context).size.width * 0.6,
                child: _buildTimeIndicator('3 PM'),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45,
                right: MediaQuery.of(context).size.width * 0.1,
                child: _buildTimeIndicator('6 PM'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeIndicator(String time) {
    return Column(
      children: [
        Container(
          height: 12,
          width: 1,
          color: Colors.white.withOpacity(0.5),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOrbitItem(ScheduleEvent event, bool isAbove) {
    return Transform.rotate(
      angle: isAbove ? -0.1 : 0.1,
      child: Container(
        width: 130,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              event.color.withOpacity(0.4),
              event.color.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: event.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: event.color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: event.color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${event.duration}min',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Standard View
class StandardView extends StatelessWidget {
  final List<ScheduleEvent> events;

  const StandardView({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date selection
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final day = DateTime.now().add(Duration(days: index));
              final isToday = index == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildDateItem(day, isSelected: isToday),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Timeline
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final isLast = index == events.length - 1;

              return _buildTimelineItem(
                event: events[index],
                isFirst: isFirst,
                isLast: isLast,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(DateTime date, {bool isSelected = false}) {
    final dayName = _getDayName(date.weekday);

    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF007AFF)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSelected ? 18 : 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildTimelineItem({
    required ScheduleEvent event,
    required bool isFirst,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time and timeline
        Column(
          children: [
            Text(
              event.time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: event.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: event.color.withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: 90,
              color:
                  isLast ? Colors.transparent : Colors.white.withOpacity(0.2),
            ),
          ],
        ),

        const SizedBox(width: 16),

        // Event card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        event.color.withOpacity(0.3),
                        event.color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: event.color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: event.color.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${event.duration} min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_horiz,
                                  color: Colors.white),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScheduleEvent {
  final String title;
  final String time;
  final int duration;
  final Color color;

  ScheduleEvent({
    required this.title,
    required this.time,
    required this.duration,
    required this.color,
  });
}
