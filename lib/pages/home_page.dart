import 'dart:ui';
import 'package:encite/components/HomeComponents/app_icon_button.dart';
import 'package:encite/components/HomeComponents/background_painter.dart';
import 'package:encite/components/HomeComponents/home_menu_item.dart';
import 'package:encite/pages/login.dart';
import 'package:flutter/material.dart';

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
        color: Color(0xFF5AC8FA)),
    HomeMenuItem(title: 'My Day', icon: Icons.today, color: Color(0xFF4CD964)),
    HomeMenuItem(
        title: 'AI Schedule', icon: Icons.schedule, color: Color(0xFFFF2D55)),
    HomeMenuItem(
        title: 'Explore', icon: Icons.explore, color: Color(0xFF007AFF)),
    HomeMenuItem(
        title: 'Create Event',
        icon: Icons.add_circle_outline,
        color: Color(0xFF5856D6)),
    HomeMenuItem(
        title: 'My Groups', icon: Icons.people, color: Color(0xFFFF9500)),
    HomeMenuItem(
        title: 'Calendar View',
        icon: Icons.calendar_month,
        color: Color(0xFFFFCC00)),
    HomeMenuItem(
        title: 'Social Hub', icon: Icons.public, color: Color(0xFFAF52DE)),
    HomeMenuItem(
        title: 'Discover',
        icon: Icons.travel_explore,
        color: Color(0xFF34C759)),
    HomeMenuItem(
        title: 'Settings', icon: Icons.settings, color: Color(0xFF8E8E93)),
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
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_animationController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
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
        ],
      ),
    );
  }
}
