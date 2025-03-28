import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App Onboarding',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const OnboardingQuiz(),
    );
  }
}

class OnboardingQuiz extends StatefulWidget {
  const OnboardingQuiz({Key? key}) : super(key: key);

  @override
  _OnboardingQuizState createState() => _OnboardingQuizState();
}

class _OnboardingQuizState extends State<OnboardingQuiz> {
  final PageController _pageController = PageController();
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((_currentPage + 1) / _totalPages * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 6,
            ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "When's your birthday?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CupertinoButton(
                  onPressed: () async {
                    final DateTime? picked = await showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 300,
                          color: Colors.grey[900],
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  CupertinoButton(
                                    child: const Text('Done'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(_birthday ?? DateTime.now());
                                    },
                                  ),
                                ],
                              ),
                              Expanded(
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: _birthday ??
                                      DateTime.now().subtract(
                                          const Duration(days: 365 * 20)),
                                  maximumDate: DateTime.now(),
                                  minimumDate: DateTime.now().subtract(
                                      const Duration(days: 365 * 100)),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _birthday != null
                            ? '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}'
                            : 'Select Date',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildNextButton(),
        ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Which best describes your gender?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: genderOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  value: option,
                  groupValue: _gender,
                  activeColor: Colors.blue,
                  onChanged: (String? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildActivitiesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What activities do you enjoy most?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "(select up to 3)",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: _activityOptions.map((activity) {
                return CheckboxListTile(
                  title: Text(
                    activity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  value: _selectedActivities.contains(activity),
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (_selectedActivities.length < 3) {
                          _selectedActivities.add(activity);
                        }
                      } else {
                        _selectedActivities.remove(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          _buildNextButton(),
        ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Do you have any allergies or dietary preferences we should know about?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: dietaryOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  value: option,
                  groupValue: _dietaryPreference,
                  activeColor: Colors.blue,
                  onChanged: (String? value) {
                    setState(() {
                      _dietaryPreference = value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          if (_dietaryPreference == 'Other (please specify)')
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Please specify your dietary preferences',
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(height: 40),
          _buildNextButton(),
        ],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your ideal social gathering size?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: gatheringOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  value: option,
                  groupValue: _gatheringSize,
                  activeColor: Colors.blue,
                  onChanged: (String? value) {
                    setState(() {
                      _gatheringSize = value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          _buildNextButton(isLastPage: true),
        ],
      ),
    );
  }

  Widget _buildNextButton({bool isLastPage = false}) {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            isLastPage ? 'Finish' : 'Next',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            SizedBox(height: 24),
            Text(
              'Onboarding Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to the app',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
