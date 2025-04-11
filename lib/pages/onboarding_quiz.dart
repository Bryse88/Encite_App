import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/HomeComponents/home_tools/gradient_button.dart';
import 'package:encite/components/HomeComponents/home_tools/gradient_text.dart';
import 'package:encite/components/ProfileComponents/utils/tag_generator.dart';
import 'package:encite/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingQuiz extends StatefulWidget {
  const OnboardingQuiz({Key? key}) : super(key: key);

  @override
  _OnboardingQuizState createState() => _OnboardingQuizState();
}

class _OnboardingQuizState extends State<OnboardingQuiz>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<int> _requiredPages = [
    0,
    1,
    2,
    3,
    4,
    5,
    6
  ]; // Indices of required pages

  int _currentPage = 0;
  final int _totalPages = 7;

  // For storing user's responses
  DateTime? _birthday;
  List<String> _selectedActivities = [];
  String? _dietaryPreference;
  String? _gatheringSize;

  final List<String> _activityOptions = [
    'Try new restaurants / cafes',
    'Explore nature or go hiking',
    'Go to live events',
    'Attend classes or workshops',
    'Hosting or joining game/movie nights',
    'Play sports or working out',
    'Attending workshops or creative classes',
    'Volunteering or joining community events',
  ];
  Map<String, int> _locationPriorities = {};
  int? _planningStyle; // Add to state
  Set<String> _selectedVibes = {};
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _animationController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    } else {
      // Submit data and navigate to home screen
      _submitData();
    }
  }

  void _submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final onboardingData = {
      'birthday': _birthday?.toIso8601String(),
      'vibes': _selectedVibes.toList(),
      'activities': _selectedActivities,
      'dietaryPreference': _dietaryPreference,
      'scheduleDensity': _activityLevel,
      'planningStyle': _planningStyle,
      'locationPriorities': _locationPriorities,
      'completedAt': Timestamp.now(),
    };

    final identityTags = generateIdentityTags(
      activities: _selectedActivities,
      vibes: _selectedVibes,
      scheduleDensity: _activityLevel,
      planningStyle: _planningStyle,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('onboarding')
          .doc('main')
          .set(onboardingData);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('onboarding')
          .doc('identityTags')
          .set({
        'tags': identityTags,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      print("Error saving onboarding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Text(
                    'Step ${_currentPage + 1} of $_totalPages',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF767676),
                    ),
                  ),
                  const Spacer(),
                  // GestureDetector(
                  //   onTap: () {
                  //     // Skip option
                  //     Navigator.of(context).pushReplacement(
                  //       MaterialPageRoute(
                  //         builder: (context) => const HomeScreen(),
                  //       ),
                  //     );
                  //   },
                  //   child: const Text(
                  //     'Skip',
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w500,
                  //       color: Color(0xFFFF5A5F),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // Dots progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    width: _currentPage == index ? 20.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          //? const Color(0xFFFF5A5F)
                          ? const Color(0xFF007AFF)
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // Quiz Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildBirthdayPage(),
                  _buildVibesPage(),
                  _buildActivitiesPage(),
                  _buildDietaryPage(),
                  _buildDensityOfSchedulePage(),
                  _buildPlanningStylePage(),
                  _buildRankingPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayPage() {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "When's your birthday?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF484848),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This helps us customize your experience.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF767676),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 300,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            color: const Color(0xFFF5F5F5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  CupertinoButton(
                                    child: const Text(
                                      'Done',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(_birthday ?? DateTime.now());
                                    },
                                  ),
                                ]),
                          ),
                          Expanded(
                            child: CupertinoTheme(
                              data: const CupertinoThemeData(
                                textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors
                                        .black, // 👈 make picker text black
                                  ),
                                ),
                              ),
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: _birthday ??
                                    DateTime.now().subtract(
                                        const Duration(days: 365 * 25)),
                                maximumDate: DateTime.now(),
                                minimumDate: DateTime.now()
                                    .subtract(const Duration(days: 365 * 100)),
                                onDateTimeChanged: (newDate) {
                                  _birthday = newDate;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );

                if (picked != null) {
                  setState(() {
                    _birthday = picked;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _birthday != null
                          ? '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}'
                          : 'Select your birthday',
                      style: TextStyle(
                        color: _birthday != null
                            ? const Color(0xFF484848)
                            : const Color(0xFF767676),
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF767676),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            _buildNextButton(_birthday != null),
          ],
        ),
      ),
    );
  }

  Widget _buildVibesPage() {
    final vibeOptions = [
      'Chill & Laid-back',
      'Social & Outgoing',
      'Focused and Prodcutive',
      'Intimate',
      'Adventurous',
      'Artisitc & Creative',
      'Loud & Energetic',
    ];

    return FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "What kind of experiences are you usually looking for?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF484848),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Select vibes that match your social preferences.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF767676),
                ),
              ),
              const SizedBox(height: 40),
              ...vibeOptions.map((option) {
                final isSelected = _selectedVibes.contains(option);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedVibes.remove(option);
                      } else {
                        _selectedVibes.add(option);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF007AFF)
                            : const Color(0xFFDDDDDD),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? const Color(0xFFF0F7FF) // Light blue background
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        isSelected
                            ? GradientText(
                                option,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF484848),
                                ),
                              ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF007AFF),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 60),
              _buildNextButton(_selectedVibes.isNotEmpty),
            ],
          ),
        ));
  }

  Widget _buildActivitiesPage() {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "What activities do you enjoy most?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF484848),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Select up to 3 activities to help us find the perfect experiences for you.",
              style: TextStyle(fontSize: 16, color: Color(0xFF767676)),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: _activityOptions.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedActivities.remove(activity);
                      } else if (_selectedActivities.length < 3) {
                        _selectedActivities.add(activity);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFFDDDDDD),
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      activity,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF484848),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 60),
            _buildNextButton(_selectedActivities.isNotEmpty),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryPage() {
    final dietaryOptions = [
      'No allergies or restrictions',
      'Vegetarian/Vegan',
      'Gluten-free',
      'Nut allergies',
      'Dairy-free',
      'Other (please specify)',
    ];

    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Any dietary preferences?",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF484848)),
            ),
            const SizedBox(height: 12),
            const Text(
              "This helps us recommend suitable food experiences.",
              style: TextStyle(fontSize: 16, color: Color(0xFF767676)),
            ),
            const SizedBox(height: 40),
            ...dietaryOptions.map((option) {
              final isSelected = _dietaryPreference == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _dietaryPreference = option;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0F8FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF007AFF)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  child: Row(
                    children: [
                      isSelected
                          ? GradientText(
                              option,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          : Text(
                              option,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF484848)),
                            ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF007AFF), size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
            if (_dietaryPreference == 'Other (please specify)')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Please specify your dietary preferences',
                    hintStyle: const TextStyle(color: Color(0xFF767676)),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF007AFF)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF484848)),
                ),
              ),
            const SizedBox(height: 60),
            _buildNextButton(_dietaryPreference != null),
          ],
        ),
      ),
    );
  }

  int? _activityLevel;
  Widget _buildDensityOfSchedulePage() {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "How busy do you enjoy being when going out?",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF484848)),
            ),
            const SizedBox(height: 12),
            const Text(
              "1 = very relaxed, 5 = packed with things to do",
              style: TextStyle(fontSize: 16, color: Color(0xFF767676)),
            ),
            const SizedBox(height: 40),

            // Slider value indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: _activityLevel == index + 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _activityLevel == index + 1
                          ? const Color(0xFF007AFF)
                          : const Color(0xFF767676),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // The slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF007AFF),
                inactiveTrackColor: const Color(0xFFDDDDDD),
                thumbColor: Colors.white,
                overlayColor: const Color(0x29007AFF),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 14,
                  elevation: 4,
                ),
                trackHeight: 6.0,
              ),
              child: Slider(
                min: 1,
                max: 5,
                divisions: 4,
                value: _activityLevel?.toDouble() ?? 3.0,
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value.round();
                  });
                },
              ),
            ),

            // Selected value description
            Container(
              margin: const EdgeInsets.only(top: 24, bottom: 60),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF007AFF)),
              ),
              child: Row(
                children: [
                  GradientText(
                    _getActivityDescription(_activityLevel),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            _buildNextButton(_activityLevel != null),
          ],
        ),
      ),
    );
  }

// Helper function to get description based on activity level
  String _getActivityDescription(int? level) {
    if (level == null) return "Choose your preference";

    switch (level) {
      case 1:
        return "Very relaxed pace";
      case 2:
        return "Casual with some free time";
      case 3:
        return "Balanced schedule";
      case 4:
        return "Fairly active schedule";
      case 5:
        return "Packed with activities";
      default:
        return "Choose your preference";
    }
  }

  Widget _buildPlanningStylePage() {
    final timeList = [
      'Walkable (0-15 min)',
      'Short drive (15-30 min)',
      'Longer travel is fine (30+ min)',
    ];

    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "How far are you willing to travel for an activity?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF484848),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This helps us customize your experience.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF767676),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              // decoration: BoxDecoration(
              //   color: Colors.transparent,
              //   borderRadius: BorderRadius.circular(20),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.05),
              //       blurRadius: 10,
              //       spreadRadius: 1,
              //     ),
              //   ],
              // ),
              child: Column(
                children: timeList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = _planningStyle == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _planningStyle = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF007AFF)
                              : const Color(0xFFDDDDDD),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color:
                            isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          isSelected
                              ? GradientText(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF484848),
                                  ),
                                ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF007AFF),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 60),
            _buildNextButton(_planningStyle != null),
          ],
        ),
      ),
    );
  }

  final List<String> _rankingFactors = [
    'Distance / Travel Time',
    'Cost / Budget',
    'Food & Drink Quality',
    'Ambience & Atmosphere',
    'Reviews & Popularity',
    'Unique or Specialty Offerings',
  ];

  Widget _buildRankingPage() {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                // decoration: BoxDecoration(
                //   gradient: const LinearGradient(
                //     colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                //     begin: Alignment.topLeft,
                //     end: Alignment.bottomRight,
                //   ),
                //   borderRadius: BorderRadius.circular(16),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.1),
                //       blurRadius: 10,
                //       spreadRadius: 1,
                //     ),
                //   ],
                // ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's more important when choosing a location?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF484848),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                // decoration: BoxDecoration(
                //   color: Colors.grey[200],
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: const Text(
                  "Rank in order of importance (1 is most important)",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF767676),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(20),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.05),
                //       blurRadius: 10,
                //       spreadRadius: 1,
                //     ),
                //   ],
                // ),
                child: Column(
                  children: _rankingFactors.map((factor) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F0FE),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${_locationPriorities[factor] ?? '-'}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _locationPriorities[factor] != null
                                      ? const Color(0xFF007AFF)
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              factor,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF484848),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: PopupMenuButton<int>(
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF767676),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) {
                                return List.generate(6, (i) => i + 1)
                                    .map((rank) {
                                  final isUsed =
                                      _locationPriorities.containsValue(rank) &&
                                          _locationPriorities[factor] != rank;
                                  return PopupMenuItem(
                                    value: rank,
                                    enabled: !isUsed,
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        color:
                                            isUsed ? Colors.white : Colors.grey,
                                        fontWeight: isUsed
                                            ? FontWeight.normal
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              onSelected: (val) {
                                setState(() {
                                  _locationPriorities.removeWhere(
                                      (key, value) => value == val);
                                  _locationPriorities[factor] = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                  height:
                      80), // More padding for safe space above bottom button
              _buildNextButton(_locationPriorities.length == 6,
                  isLastPage: true),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isEnabled, {bool isLastPage = false}) {
    return isEnabled
        ? GradientButton(
            onPressed: _nextPage,
            label: isLastPage ? 'Finish' : 'Continue',
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Color(0xFF767676),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
  }
}
