import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encite/components/LoginComponents/gradient_background.dart';
import 'package:encite/components/HomeComponents/home_menu_item.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer package to pubspec.yaml

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
  List<HomeMenuItem> _storyItems = []; // For stories
  bool _loadingMenuItems = true;
  bool isAvailable = true; // Availability toggle state

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Preload preferences to avoid delay in first build
    SharedPreferences.getInstance().then((prefs) {
      final cached = prefs.getString('cachedName');
      if (cached != null && mounted) {
        setState(() {
          _firstName = cached;
          _isLoading = false;
        });
      }
    });

    // Then let the actual Firestore call run in background
    _fetchUserName(); // It'll update if newer data exists

    // Fetch menu items from Firestore
    _fetchMenuItems();
  }

  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString('cachedName');

      if (cachedName != null && cachedName.isNotEmpty) {
        // Load from local storage immediately
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

      // Fetch from Firestore if no cache exists
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final fullName = data['name'] as String? ?? 'there';
        final firstName = fullName.split(' ')[0];

        // Cache it for future loads
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
      print('Error fetching name: $e');
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
          .orderBy('order')
          .get();

      final List<HomeMenuItem> items = menuItemsSnapshot.docs.map((doc) {
        return HomeMenuItem.fromMap(doc.data(), doc.id);
      }).toList();

      // Split items between stories and feed items (first 5 for stories, rest for feed)
      final storyItems = items.take(5).toList();
      final feedItems =
          items.skip(0).toList(); // Using all items for feed for now

      setState(() {
        _storyItems = storyItems;
        _menuItems = feedItems;
        _loadingMenuItems = false;
      });
    } catch (e) {
      print('Error fetching menu items: $e');
      setState(() {
        _loadingMenuItems = false;
        // Default menu items in case of failure
        _storyItems = [
          HomeMenuItem(
            id: 'default_story',
            title: 'Featured',
            icon: Icons.star,
            color: const Color(0xFF007AFF),
            route: '/featured',
          ),
        ];
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

  // Story Item Widget
  Widget _buildStoryItem(HomeMenuItem item) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, // reduce size
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  item.color.withOpacity(0.8),
                  item.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.pushNamed(context, item.route);
                },
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // Feed Item Card Widget
  Widget _buildFeedItem(HomeMenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Hero(
        tag: 'menu_${item.id}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, item.route);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            item.color.withOpacity(0.8),
                            item.color,
                          ],
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to open ${item.title}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Availability Toggle Widget
  Widget _buildAvailabilityToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isAvailable
              ? [
                  Color(0xFF007AFF),
                  Color(0xFF5AC8FA)
                ] // Blue gradient for "Available"
              : [Color(0xFFB0BEC5), Color(0xFF90A4AE)], // Greyish for "Busy"
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            setState(() => isAvailable = !isAvailable);
            _logAvailabilityStatus(isAvailable);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.do_not_disturb,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isAvailable ? 'Available' : 'Busy',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shimmering Loading Effect
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story shimmer
          Container(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24),
          // Feed items shimmer
          for (int i = 0; i < 5; i++)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _logAvailabilityStatus(bool status) async {
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

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isLoading || _loadingMenuItems ? 0.7 : 1.0,
            child: CustomScrollView(
              slivers: [
                // App Bar with greeting and availability toggle
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  pinned: false,
                  expandedHeight: 70,
                  flexibleSpace: Padding(
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
                        _buildAvailabilityToggle(),
                      ],
                    ),
                  ),
                ),

                // Stories Section
                SliverToBoxAdapter(
                  child: _loadingMenuItems
                      ? Container(
                          height: 110,
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[600]!,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 50,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Container(
                          height: 110,
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _storyItems.length,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            itemBuilder: (context, index) {
                              return _buildStoryItem(_storyItems[index]);
                            },
                          ),
                        ),
                ),

                // Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(0xFF007AFF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'For You',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Feed Items
                _loadingMenuItems
                    ? SliverToBoxAdapter(
                        child: Column(
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[800]!,
                                highlightColor: Colors.grey[600]!,
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Add animation for loading feed items with staggered effect
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration:
                                  Duration(milliseconds: 500 + (index * 100)),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 20),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildFeedItem(_menuItems[index]),
                            );
                          },
                          childCount: _menuItems.length,
                        ),
                      ),

                // Bottom Padding (for navigation bar)
                SliverToBoxAdapter(
                  child: SizedBox(height: 90),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
