import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Sample user data
  final Map<String, dynamic> userData = {
    'name': 'Alex Morgan',
    'username': '@alexmorgan',
    'email': 'alex.morgan@example.com',
    'profileImage': 'https://i.pravatar.cc/300',
    'favoriteCategories': [
      'AI & Tech',
      'Productivity',
      'Health',
      'Design',
      'Travel',
      'Photography',
      'Music',
      'Reading'
    ],
    'recentActivity': [
      {'type': 'Event', 'title': 'Team Brainstorming', 'time': '2 hours ago'},
      {
        'type': 'Schedule',
        'title': 'Updated work calendar',
        'time': 'Yesterday'
      },
      {'type': 'Chat', 'title': 'Design Team Discussion', 'time': '2 days ago'},
      {'type': 'Event', 'title': 'Product Meeting', 'time': '3 days ago'},
      {
        'type': 'Schedule',
        'title': 'AI-optimized week plan',
        'time': '5 days ago'
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_animationController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar
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
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile header with image and name
                _buildProfileHeader(),

                const SizedBox(height: 20),

                // "Impaler" - horizontal bar as visual anchor
                _buildImpalerBar(),

                const SizedBox(height: 20),

                // Favorite categories
                _buildFavoriteCategories(),

                const SizedBox(height: 24),

                // Recent activity
                Expanded(
                  child: _buildRecentActivity(),
                ),

                // Logout button
                _buildLogoutButton(),
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
                      _buildNavBarItem(Icons.schedule, 'Schedule'),
                      _buildNavBarItem(Icons.chat_bubble_outline, 'Chats'),
                      _buildNavBarItem(Icons.person, 'Profile', isActive: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Profile image with glass effect
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(43),
                        child: Image.network(
                          userData['profileImage'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 20),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData['email'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userData['username'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpalerBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 4,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF007AFF),
            Color(0xFF5AC8FA),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Favorite Categories',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: userData['favoriteCategories'].length,
            itemBuilder: (context, index) {
              final category = userData['favoriteCategories'][index];
              return _buildCategoryChip(category, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, int index) {
    // Generate a color based on the index
    final List<Color> chipColors = [
      const Color(0xFF5AC8FA),
      const Color(0xFF4CD964),
      const Color(0xFFFF2D55),
      const Color(0xFF007AFF),
      const Color(0xFF5856D6),
      const Color(0xFFFF9500),
      const Color(0xFFFFCC00),
      const Color(0xFFAF52DE),
    ];

    final color = chipColors[index % chipColors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Recent Activity',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: userData['recentActivity'].length,
            itemBuilder: (context, index) {
              final activity = userData['recentActivity'][index];
              return _buildActivityItem(activity, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, String> activity, int index) {
    // Icon based on activity type
    IconData activityIcon;
    Color activityColor;

    switch (activity['type']) {
      case 'Event':
        activityIcon = Icons.event;
        activityColor = const Color(0xFF5AC8FA);
        break;
      case 'Schedule':
        activityIcon = Icons.schedule;
        activityColor = const Color(0xFF4CD964);
        break;
      case 'Chat':
        activityIcon = Icons.chat_bubble;
        activityColor = const Color(0xFFFF9500);
        break;
      default:
        activityIcon = Icons.star;
        activityColor = const Color(0xFF007AFF);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activityColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activityIcon,
                    color: activityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity['time']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GestureDetector(
        onTap: () {
          // Logout logic
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: 1.0,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFFF2D55).withOpacity(0.8),
                  const Color(0xFFFF9500).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF2D55).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
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

class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Create a gradient background
    Paint paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.5 + 0.3 * math.sin(animationValue * 2 * math.pi),
          0.5 + 0.3 * math.cos(animationValue * 2 * math.pi),
        ),
        radius: 1.2,
        colors: const [
          Color(0xFF1A1A1A),
          Color(0xFF0C0C0C),
          Colors.black,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Add some subtle floating particles
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final offset = i / 20;
      final x = size.width *
          (0.2 + 0.6 * math.sin(2 * math.pi * (offset + animationValue)));
      final y = size.height *
          (0.2 + 0.6 * math.cos(2 * math.pi * (offset + animationValue * 1.2)));
      final radius = 5 + 5 * math.sin(animationValue * 2 * math.pi + i);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
