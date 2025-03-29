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

  int _currentPage = 0;
  final int _totalPages = 5;

  // For storing user's responses
  DateTime? _birthday;
  String? _gender;
  List<String> _selectedActivities = [];
  String? _dietaryPreference;
  String? _gatheringSize;

  final List<String> _activityOptions = [
    'Outdoor adventures',
    'Food & dining',
    'Arts & culture',
    'Sports & fitness',
    'Tech & gaming',
    'Learning & workshops',
    'Music & nightlife',
    'Community service',
  ];

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

  void _submitData() {
    // Here you would typically send this data to your backend
    final userData = {
      'birthday': _birthday,
      'gender': _gender,
      'activities': _selectedActivities,
      'dietaryPreference': _dietaryPreference,
      'gatheringSize': _gatheringSize,
    };

    print('User onboarding data: $userData');

    // Navigate to home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
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
                  GestureDetector(
                    onTap: () {
                      // Skip option
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF5A5F),
                      ),
                    ),
                  ),
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
                          ? const Color(0xFFFF5A5F)
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
                  _buildGenderPage(),
                  _buildActivitiesPage(),
                  _buildDietaryPage(),
                  _buildGatheringSizePage(),
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
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            color: Colors.grey[100],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CupertinoButton(
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Color(0xFF767676)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoButton(
                                  child: const Text(
                                    'Done',
                                    style: TextStyle(color: Color(0xFFFF5A5F)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(_birthday ?? DateTime.now());
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: _birthday ??
                                  DateTime.now()
                                      .subtract(const Duration(days: 365 * 25)),
                              maximumDate: DateTime.now(),
                              minimumDate: DateTime.now()
                                  .subtract(const Duration(days: 365 * 100)),
                              onDateTimeChanged: (DateTime newDate) {
                                _birthday = newDate;
                              },
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

  Widget _buildGenderPage() {
    final genderOptions = [
      'Male',
      'Female',
      'Non-binary',
      'Other',
      'Prefer not to say',
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
              "Which best describes your gender?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF484848),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Help us personalize your recommendations.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF767676),
              ),
            ),
            const SizedBox(height: 40),
            ...genderOptions.map((option) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _gender = option;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _gender == option
                          ? const Color(0xFFFF5A5F)
                          : const Color(0xFFDDDDDD),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _gender == option
                        ? const Color(0xFFFFF8F9)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          color: _gender == option
                              ? const Color(0xFFFF5A5F)
                              : const Color(0xFF484848),
                          fontSize: 16,
                          fontWeight: _gender == option
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (_gender == option)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFFF5A5F),
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 60),
            _buildNextButton(_gender != null),
          ],
        ),
      ),
    );
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
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF767676),
              ),
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
                      } else {
                        if (_selectedActivities.length < 3) {
                          _selectedActivities.add(activity);
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFFF5A5F) : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF5A5F)
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
                color: Color(0xFF484848),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This helps us recommend suitable food experiences.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF767676),
              ),
            ),
            const SizedBox(height: 40),
            ...dietaryOptions.map((option) {
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
                    border: Border.all(
                      color: _dietaryPreference == option
                          ? const Color(0xFFFF5A5F)
                          : const Color(0xFFDDDDDD),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _dietaryPreference == option
                        ? const Color(0xFFFFF8F9)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          color: _dietaryPreference == option
                              ? const Color(0xFFFF5A5F)
                              : const Color(0xFF484848),
                          fontSize: 16,
                          fontWeight: _dietaryPreference == option
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (_dietaryPreference == option)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFFF5A5F),
                          size: 20,
                        ),
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
                      borderSide: const BorderSide(color: Color(0xFFFF5A5F)),
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

  Widget _buildGatheringSizePage() {
    final gatheringOptions = [
      'Just me and one other person',
      'Small group (3-5 people)',
      'Medium group (6-15 people)',
      'Large events (15+ people)',
      'Depends on the activity',
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
              "What's your ideal gathering size?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF484848),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "We'll find social events that match your comfort level.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF767676),
              ),
            ),
            const SizedBox(height: 40),
            ...gatheringOptions.map((option) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _gatheringSize = option;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _gatheringSize == option
                          ? const Color(0xFFFF5A5F)
                          : const Color(0xFFDDDDDD),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _gatheringSize == option
                        ? const Color(0xFFFFF8F9)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          color: _gatheringSize == option
                              ? const Color(0xFFFF5A5F)
                              : const Color(0xFF484848),
                          fontSize: 16,
                          fontWeight: _gatheringSize == option
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (_gatheringSize == option)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFFF5A5F),
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 60),
            _buildNextButton(_gatheringSize != null, isLastPage: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isEnabled, {bool isLastPage = false}) {
    return GestureDetector(
      onTap: isEnabled ? _nextPage : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFFF5A5F) : const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF5A5F).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            isLastPage ? 'Finish' : 'Continue',
            style: TextStyle(
              color: isEnabled ? Colors.white : const Color(0xFF767676),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder for the home screen after onboarding
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F9),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFFFF5A5F),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'You\'re all set!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF484848),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Get ready to discover amazing experiences tailored just for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF767676),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GestureDetector(
                onTap: () {
                  // Go to main app content
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A5F),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5A5F).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Start Exploring',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
