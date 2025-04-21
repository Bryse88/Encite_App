import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/components/Schedule/schedule_presentation_page.dart';
import 'package:encite/components/group_components/steps/budgets_step.dart';
import 'package:encite/components/group_components/steps/location_step.dart';
import 'package:encite/components/group_components/steps/timeframe.dart';
import 'package:encite/components/group_components/steps/transportation_step.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encite/services/schedule_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class SoloSchedulerForm extends StatefulWidget {
  const SoloSchedulerForm({Key? key}) : super(key: key);

  @override
  State<SoloSchedulerForm> createState() => _SchedulerFormState();
}

class _SchedulerFormState extends State<SoloSchedulerForm>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _budget = 0.0;
  String _location = '';
  bool _useCurrentLocation = false;
  final List<String> _selectedTransportModes = [];
  bool _isLoading = false;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      _showSummaryDialog();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  Future<String?> _getCurrentLocation() async {
    try {
      // Check location services and permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();

      // Get location name
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.administrativeArea}';
      }

      return null;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  void _showSummaryDialog() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await fetchUserPreferences();

    if (prefs == null) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't load user preferences.")),
      );
      return;
    }

    // Handle location
    String locationName;
    if (_useCurrentLocation) {
      final currentLocation = await _getCurrentLocation();
      locationName = currentLocation ?? "Madison, WI";
    } else {
      locationName = _location.isNotEmpty ? _location : "Madison, WI";
    }

    // Prepare time values
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, _startTime?.hour ?? 14,
        _startTime?.minute ?? 0);
    final end = DateTime(now.year, now.month, now.day, _endTime?.hour ?? 18,
        _endTime?.minute ?? 0);

    // Map user preferences to API format
    final schedulePayload = {
      "location": locationName,
      "startTime": start.toUtc().toIso8601String(),
      "endTime": end.toUtc().toIso8601String(),
      "birthday": prefs['birthday'] ?? "2000-01-01",
      "experience_vibes": prefs['experience_vibes'] ?? ["Social & Outgoing"],
      "activities": prefs['activities'] ?? ["Try new restaurants / cafes"],
      "dietary_preference": prefs['dietary_preference'] ?? "No Preference",
      "travel_willingness": _selectedTransportModes.contains("Walking")
          ? "Walking Distance (< 15 min)"
          : "Short drive (15-30 min)",
      "location_priorities": {
        "Ambience & Atmosphere": prefs['ambience_priority'] ?? 3,
        "Cost / Budget":
            _budget > 0 ? 1 : 5, // Higher priority if budget is low
        "Distance / Travel Time": 3,
        "Food & Drink Quality": prefs['food_quality_priority'] ?? 4,
        "Reviews & Popularity": prefs['popularity_priority'] ?? 2,
        "Unique or Specialty Offerings": prefs['uniqueness_priority'] ?? 6
      },
      "schedule_density": prefs['schedule_density'] ?? 4
    };
    print('Local start: $start');
    print('Local end: $end');
    print('UTC start: ${start.toUtc()}');
    print('UTC end: ${end.toUtc()}');

    // Send to backend API
    final schedule = await ScheduleService().generateSchedule(schedulePayload);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (schedule != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SchedulePresentationPage(schedule: schedule),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create schedule. Please try again."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchUserPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('onboarding')
          .doc('main')
          .get();

      return doc.data();
    } catch (e) {
      print('Error fetching user preferences: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Schedule")),
      // Use PageView with vertical scroll direction
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Creating your Social Plans",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical, // Vertical sliding
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent user scrolling
              children: [
                // Each step is a separate page
                TimeFrameStep(
                  onStartTimeChanged: (t) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _startTime = t);
                    });
                  },
                  onEndTimeChanged: (t) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _endTime = t);
                    });
                  },
                ),

                BudgetStep(onBudgetChanged: (b) => setState(() => _budget = b)),
                LocationStep(
                  onLocationChanged: (l) => setState(() => _location = l),
                  onUseCurrentLocationChanged: (v) =>
                      setState(() => _useCurrentLocation = v),
                ),
                TransportStep(
                  selectedModes: _selectedTransportModes,
                  transportModes: const [
                    'Rideshare',
                    'Walking',
                    'Personal Vehicle',
                    'Public Transportation'
                  ],
                ),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back button (only visible after first page)
                  if (_currentPage > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        height: 56.0,
                        width: 56.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF007AFF),
                            width: 2.0,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _previousPage,
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Next/Finish button (expanded to fill remaining space)
                  Expanded(
                    child: Container(
                      height: 56.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _nextPage,
                          child: Center(
                            child: Text(
                              _currentPage == _totalPages - 1
                                  ? 'Create Schedule'
                                  : 'Next',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
