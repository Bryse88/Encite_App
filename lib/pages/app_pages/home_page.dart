import 'dart:ui';
import 'package:encite/components/HomeComponents/app_icon_button.dart';
import 'package:encite/components/background_painter.dart';
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            // Navigate to settings
                            Navigator.of(context).pushNamed('/settings');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loadingMenuItems
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _menuItems.isEmpty
                          ? const Center(
                              child: Text(
                                'No menu items found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _menuItems.length,
                              itemBuilder: (context, index) {
                                return AppIconButton(
                                  item: _menuItems[index],
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
