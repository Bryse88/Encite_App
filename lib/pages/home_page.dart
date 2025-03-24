import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Watch Style App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF007AFF),
          secondary: Color(0xFF5AC8FA),
          background: Colors.black,
        ),
        fontFamily: 'SF Pro Display',
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<HomeMenuItem> menuItems = [
    HomeMenuItem(
      title: 'Group Chats',
      icon: Icons.chat_bubble_outline,
      color: const Color(0xFF5AC8FA),
    ),
    HomeMenuItem(
      title: 'My Day',
      icon: Icons.today,
      color: const Color(0xFF4CD964),
    ),
    HomeMenuItem(
      title: 'AI Schedule',
      icon: Icons.schedule,
      color: const Color(0xFFFF2D55),
    ),
    HomeMenuItem(
      title: 'Explore',
      icon: Icons.explore,
      color: const Color(0xFF007AFF),
    ),
    HomeMenuItem(
      title: 'Create Event',
      icon: Icons.add_circle_outline,
      color: const Color(0xFF5856D6),
    ),
    HomeMenuItem(
      title: 'My Groups',
      icon: Icons.people,
      color: const Color(0xFFFF9500),
    ),
    HomeMenuItem(
      title: 'Calendar View',
      icon: Icons.calendar_month,
      color: const Color(0xFFFFCC00),
    ),
    HomeMenuItem(
      title: 'Social Hub',
      icon: Icons.public,
      color: const Color(0xFFAF52DE),
    ),
    HomeMenuItem(
      title: 'Discover',
      icon: Icons.travel_explore,
      color: const Color(0xFF34C759),
    ),
    HomeMenuItem(
      title: 'Settings',
      icon: Icons.settings,
      color: const Color(0xFF8E8E93),
    ),
  ];

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hey, User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

                // Grid of menu items
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return AppIconButton(
                        item: menuItems[index],
                        index: index,
                      );
                    },
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
                      _buildNavBarItem(Icons.person_outline, 'Profile'),
                      _buildNavBarItem(Icons.schedule, 'Schedule'),
                      _buildNavBarItem(Icons.chat_bubble_outline, 'Chats'),
                      _buildNavBarItem(Icons.add_circle, 'Create'),
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

  Widget _buildNavBarItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class HomeMenuItem {
  final String title;
  final IconData icon;
  final Color color;

  HomeMenuItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class AppIconButton extends StatefulWidget {
  final HomeMenuItem item;
  final int index;

  const AppIconButton({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Add slight delay to stagger the animations
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) {
                _controller.reverse();
              },
              onTapUp: (_) {
                _controller.forward();
              },
              onTapCancel: () {
                _controller.forward();
              },
              onTap: () {
                // Handle tap action
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.item.color.withOpacity(0.3),
                          widget.item.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: widget.item.color.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.item.color.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.item.icon,
                          size: 40,
                          color: widget.item.color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
          0.5 + 0.3 * sin(animationValue * 2 * 3.14),
          0.5 + 0.3 * cos(animationValue * 2 * 3.14),
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
      final x =
          size.width * (0.2 + 0.6 * sin(2 * 3.14 * (offset + animationValue)));
      final y = size.height *
          (0.2 + 0.6 * cos(2 * 3.14 * (offset + animationValue * 1.2)));
      final radius = 5 + 5 * sin(animationValue * 2 * 3.14 + i);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
