// This is a revised version of the HomePage that features an impaler bar at the center
// and scroll interaction that rotates the menu items around that bar.

import 'dart:math' as math;
import 'package:encite/components/HomeComponents/HomeImpaler.dart';
import 'package:flutter/material.dart';

class MenuItemData {
  final IconData icon;
  final String title;
  final Color color;

  MenuItemData({required this.icon, required this.title, required this.color});
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double rotationOffset = 0.0;

  final List<MenuItemData> menuItems = [
    MenuItemData(icon: Icons.today, title: 'My Day', color: Colors.indigo),
    MenuItemData(icon: Icons.explore, title: 'Explore', color: Colors.teal),
    MenuItemData(icon: Icons.message, title: 'Messages', color: Colors.cyan),
    MenuItemData(
        icon: Icons.notifications,
        title: 'Notifications',
        color: Colors.orange),
    MenuItemData(
        icon: Icons.calendar_month, title: 'Calendar', color: Colors.blueGrey),
    MenuItemData(
        icon: Icons.settings, title: 'Settings', color: Colors.deepPurple),
    MenuItemData(
        icon: Icons.person, title: 'Profile', color: Colors.pinkAccent),
  ];

  void _onScroll(DragUpdateDetails details) {
    setState(() {
      rotationOffset += details.delta.dy * 0.01;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double orbitHeight = size.height * 0.6;
    final double orbitWidth = size.width * 0.75;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: _onScroll,
        child: Stack(
          children: [
            // Center(
            //   child: Container(
            //     width: 30,
            //     height: orbitHeight,
            //     decoration: BoxDecoration(
            //       color: Colors.white.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(15),
            //     ),
            //   ),
            // ),
            ...List.generate(menuItems.length, (index) {
              final angle =
                  (index * (2 * math.pi / menuItems.length)) + rotationOffset;
              final x = math.cos(angle) * (orbitWidth / 2);
              final y = math.sin(angle) * (orbitHeight / 2);

              final scale = ((math.cos(angle) + 1) / 2) * 0.6 + 0.4;
              final sizeFactor = 80.0 * scale;

              return Positioned(
                left: (size.width / 2) + x - sizeFactor / 2,
                top: (size.height / 2) + y - sizeFactor / 2,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: sizeFactor,
                    height: sizeFactor,
                    decoration: BoxDecoration(
                      color: menuItems[index].color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      menuItems[index].icon,
                      color: Colors.white,
                      size: 32 * scale,
                    ),
                  ),
                ),
              );
            }),
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Encite',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Scroll to Explore',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                    SizedBox(height: 35),
                    HomeImpalerBar()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
