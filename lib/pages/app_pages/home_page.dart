import 'dart:ui';
import 'package:encite/components/HomeComponents/app_icon_button.dart';
import 'package:encite/components/MainComponents/background_painter.dart';
import 'package:encite/components/HomeComponents/home_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<HomeMenuItem> _menuItems = [];
  bool _loadingMenuItems = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Fetch user's display name when the page initializes
    _fetchUserName();

    // Fetch menu items from Firestore
    _fetchMenuItems();
  }

  Future<void> _fetchUserName() async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch user document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          if (data.containsKey('name')) {
            // Get the first word from DisplayName
            final fullName = data['name'] as String;
            final firstName = fullName.split(' ')[0];

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
        } else {
          setState(() {
            _firstName = 'there';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _firstName = 'there';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
      setState(() {
        _firstName = 'there';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMenuItems() async {
    try {
      // Fetch menu items from Firestore
      final menuItemsSnapshot = await FirebaseFirestore.instance
          .collection('app_items')
          .orderBy('order') // Add this if you want to control the order
          .get();

      final List<HomeMenuItem> items = menuItemsSnapshot.docs.map((doc) {
        return HomeMenuItem.fromMap(doc.data(), doc.id);
      }).toList();

      setState(() {
        _menuItems = items;
        _loadingMenuItems = false;
      });
    } catch (e) {
      print('Error fetching menu items: $e');
      setState(() {
        _loadingMenuItems = false;
        // Optionally provide some default menu items in case of failure
        _menuItems = [
          HomeMenuItem(
            id: 'default',
            title: 'Settings',
            icon: Icons.settings,
            color: const Color(0xFF8E8E93),
            route: '/settings',
          ),
        ];
      });
    }
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
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double tileWidth = constraints.maxWidth * 0.42;
                      double tileHeight = tileWidth * 0.9;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Wrap(
                          spacing: constraints.maxWidth *
                              0.05, // space between columns
                          runSpacing: 24, // space between rows
                          children: List.generate(_menuItems.length, (index) {
                            final isOffset = index % 2 != 0;

                            return Padding(
                              padding: EdgeInsets.only(
                                top: isOffset ? 12.0 : 0.0,
                              ),
                              child: SizedBox(
                                width: tileWidth,
                                height: tileHeight,
                                child: AppIconButton(
                                  item: _menuItems[index],
                                  index: index,
                                ),
                              ),
                            );
                          }),
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

  Widget _buildMenuItem(int index,
      {required double top, required double left}) {
    if (index >= _menuItems.length) return const SizedBox();
    return Positioned(
      top: top,
      left: left,
      child: SizedBox(
        width: 120,
        height: 120,
        child: AppIconButton(
          item: _menuItems[index],
          index: index,
        ),
      ),
    );
  }

  Widget _buildTile(int index) {
    if (index >= _menuItems.length) return const SizedBox();
    return SizedBox(
      width: 140,
      height: 140,
      child: AppIconButton(
        item: _menuItems[index],
        index: index,
      ),
    );
  }
}
