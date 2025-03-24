import 'dart:ui';

import 'package:encite/pages/home_page.dart';
import 'package:encite/pages/messaging_page.dart';
import 'package:encite/pages/proflie.dart';
import 'package:encite/pages/scheduler.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  final int initialPageIndex;

  const Navigation({Key? key, this.initialPageIndex = 0}) : super(key: key);

  @override
  State<Navigation> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<Navigation> {
  late int _currentIndex;
  late final PageController _pageController;

  final List<Widget> _pages = [
    const HomePage(),
    const SchedulingPage(),
    const ChatsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final bool isActive = index == _currentIndex;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
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
                    : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          // Blurred Bottom Nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.1), width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavBarItem(0, Icons.home_outlined, 'Home'),
                      _buildNavBarItem(1, Icons.schedule, 'Schedule'),
                      _buildNavBarItem(2, Icons.chat_bubble_outline, 'Chats'),
                      _buildNavBarItem(3, Icons.person_outline, 'Profile'),
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
}
