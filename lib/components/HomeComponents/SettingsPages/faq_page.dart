import 'dart:ui';
import 'package:encite/components/MainComponents/background_painter.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;

  // List of FAQ items with a selected state to track expansion
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I create an event?',
      answer:
          'To create an event, tap on the "Create Event" button on the home screen. Fill out the event details including date, time, location, and description. You can also set privacy settings and invite friends directly from your contacts.',
      isExpanded: false,
      category: 'Events',
      icon: Icons.event_note,
    ),
    FAQItem(
      question: 'Can I schedule recurring events?',
      answer:
          'Yes! When creating an event, toggle the "Recurring" option and select your preferred frequency (daily, weekly, monthly). You can also set an end date for the recurring series or choose to continue indefinitely.',
      isExpanded: false,
      category: 'Events',
      icon: Icons.repeat,
    ),
    FAQItem(
      question: 'How do I join a group?',
      answer:
          'You can join groups by searching in the "Discover" tab, or by accepting invitations sent to you. If a group is private, you\'ll need to request to join and wait for approval from a group admin.',
      isExpanded: false,
      category: 'Groups',
      icon: Icons.group_add,
    ),
    FAQItem(
      question: 'How do I manage notifications?',
      answer:
          'Notification preferences can be managed in the Settings page. You can customize what types of notifications you receive (event reminders, messages, friend requests, etc.) and how you receive them.',
      isExpanded: false,
      category: 'Account',
      icon: Icons.notifications,
    ),
    FAQItem(
      question: 'Can I change my username?',
      answer:
          'Yes, you can change your username in the Settings > Profile section. Note that you can only change your username once every 30 days.',
      isExpanded: false,
      category: 'Account',
      icon: Icons.person,
    ),
    FAQItem(
      question: 'How does the AI scheduling feature work?',
      answer:
          'Our AI scheduler analyzes your availability, preferences, and past behaviors to suggest optimal times for your events. It also considers group members\' schedules when planning group activities to find times that work for everyone.',
      isExpanded: false,
      category: 'Features',
      icon: Icons.schedule,
    ),
    FAQItem(
      question: 'Is my data private?',
      answer:
          'Encite takes your privacy seriously. Your personal information is never shared with third parties without your consent. Event details are only visible to those you invite, and your location data is only used when you explicitly enable location features.',
      isExpanded: false,
      category: 'Privacy',
      icon: Icons.security,
    ),
    FAQItem(
      question: 'How do I delete my account?',
      answer:
          'To delete your account, go to Settings > Account > Delete Account. Please note that this action is permanent and will remove all your data from our servers. If you\'d prefer to take a break, you can temporarily deactivate your account instead.',
      isExpanded: false,
      category: 'Account',
      icon: Icons.delete,
    ),
    FAQItem(
      question: 'Can I export my events to other calendar apps?',
      answer:
          'Yes! Encite supports integration with most popular calendar apps. Go to Settings > Integrations to link your accounts or export events as .ics files that can be imported into other calendar applications.',
      isExpanded: false,
      category: 'Features',
      icon: Icons.calendar_today,
    ),
    FAQItem(
      question: 'How do I report inappropriate content or users?',
      answer:
          'You can report inappropriate content by tapping the three dots next to any post or event and selecting "Report". For user profiles, visit their profile page and tap "Report User" from the options menu. Our moderation team reviews all reports promptly.',
      isExpanded: false,
      category: 'Community',
      icon: Icons.flag,
    ),
  ];

  // Track which categories are selected for filtering
  final Map<String, bool> _selectedCategories = {
    'All': true,
    'Events': false,
    'Groups': false,
    'Account': false,
    'Features': false,
    'Privacy': false,
    'Community': false,
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

  // Filter FAQs based on selected categories
  List<FAQItem> get _filteredFaqItems {
    if (_selectedCategories['All'] == true) {
      return _faqItems;
    }

    return _faqItems
        .where((item) => _selectedCategories[item.category] == true)
        .toList();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Flexible(
                        child: Text(
                          'Frequently Asked Questions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.visible,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search FAQs...',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.white70),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (query) {
                            // Implement search functionality here
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Category filter chips
                SizedBox(
                  height: 60,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    scrollDirection: Axis.horizontal,
                    children: _selectedCategories.keys.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: _selectedCategories[category] == true,
                          label: Text(category),
                          checkmarkColor: Colors.white,
                          selectedColor: Colors.purpleAccent.withOpacity(0.7),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _selectedCategories[category] == true
                                ? Colors.white
                                : Colors.white70,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedCategories[category] == true
                                  ? Colors.purpleAccent
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (category == 'All') {
                                // If "All" is selected, deselect others
                                _selectedCategories
                                    .updateAll((key, value) => false);
                                _selectedCategories['All'] = true;
                              } else {
                                // If a specific category is selected, deselect "All"
                                _selectedCategories['All'] = false;
                                _selectedCategories[category] = selected;

                                // If nothing is selected, select "All" again
                                if (_selectedCategories.values
                                    .every((value) => value == false)) {
                                  _selectedCategories['All'] = true;
                                }
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // FAQ list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredFaqItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredFaqItems[index];
                            return _buildFaqCard(item, index);
                          },
                        ),
                ),

                // Still have questions section
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(FAQItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                key: Key(index.toString()),
                initiallyExpanded: item.isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    item.isExpanded = expanded;
                  });
                },
                leading: Icon(
                  item.icon,
                  color: _getCategoryColor(item.category),
                  size: 28,
                ),
                title: Text(
                  item.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCategoryColor(item.category).withOpacity(0.7),
                  ),
                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  Text(
                    item.answer,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.thumb_up_outlined, size: 16),
                        label: const Text('Helpful'),
                        onPressed: () {
                          // Implement feedback mechanism
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thanks for your feedback!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.thumb_down_outlined, size: 16),
                        label: const Text('Not helpful'),
                        onPressed: () {
                          // Implement feedback mechanism
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thanks for your feedback!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Events':
        return Colors.green;
      case 'Groups':
        return Colors.orange;
      case 'Account':
        return Colors.blue;
      case 'Features':
        return Colors.purple;
      case 'Privacy':
        return Colors.red;
      case 'Community':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;
  final IconData icon;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    required this.icon,
    this.isExpanded = false,
  });
}
