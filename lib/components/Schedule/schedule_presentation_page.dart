import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encite/models/activity.dart';
import 'package:encite/models/schedule.dart';
import 'package:encite/services/schedule_service.dart';
import 'activity_card.dart';

class SchedulePresentationPage extends StatefulWidget {
  final Schedule schedule;

  const SchedulePresentationPage({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  State<SchedulePresentationPage> createState() =>
      _SchedulePresentationPageState();
}

class _SchedulePresentationPageState extends State<SchedulePresentationPage> {
  late Schedule _schedule;
  final _scheduleService = ScheduleService();
  bool _isLoading = false;
  bool _showingRatingsDialog = false;

  @override
  void initState() {
    super.initState();
    _schedule = widget.schedule;
  }

  Future<void> _saveSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _scheduleService.saveSchedule(_schedule);

      if (!mounted) return;

      // Show ratings dialog before navigating away
      if (!_showingRatingsDialog) {
        _showingRatingsDialog = true;
        await _showRatingDialog();
        _showingRatingsDialog = false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule saved successfully!')));
      Navigator.pop(context, _schedule);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save schedule: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showRatingDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    double rating = 3.0; // Default rating
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double rating = 3.0; // Default rating

        return AlertDialog(
          title: const Text('Rate Your Schedule'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'How would you rate the activities we\'ve suggested?'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating.floor()
                              ? Icons.star
                              : (index < rating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('ratings')
                      .doc(_schedule.id)
                      .set({
                    'scheduleId': _schedule.id,
                    'rating': rating,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving rating: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _discardSchedule() {
    Navigator.pop(context);
  }

  Future<void> _requestSubstituteActivity(int index) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activity = _schedule.activities[index];
      final substitute = await _scheduleService.requestSubstituteActivity(
        activity.id,
        _schedule,
      );

      if (substitute != null) {
        setState(() {
          final newActivities = List<Activity>.from(_schedule.activities);
          newActivities[index] = substitute;
          _schedule = Schedule(
            id: _schedule.id,
            activities: newActivities,
            createdAt: _schedule.createdAt,
          );
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not find a suitable alternative activity.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get substitute activity: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Schedule', style: theme.textTheme.titleLarge),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show information about AI-generated schedules
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Your Schedule'),
                  content: const Text(
                    'This schedule was created based on your personal preferences by our AI assistant. Each activity was selected to match your interests, budget, and time constraints.\n\nIf you don\'t like an activity, tap the refresh button to get an alternative suggestion.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Main content
                CustomScrollView(
                  slivers: [
                    // Header with total cost and time frame
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total cost and time frame in a nice card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Cost',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${_schedule.totalCost.toStringAsFixed(2)}',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Replace the existing time frame display with:
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Time Frame',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _schedule
                                              .localTimeFrame, // Use local time frame here
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // Activity list
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          bottom: 100), // Space for bottom buttons
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final activity = _schedule.activities[index];
                            return ActivityCard(
                              activity: activity,
                              onDelete: () => _requestSubstituteActivity(index),
                              isDarkMode: isDarkMode,
                            );
                          },
                          childCount: _schedule.activities.length,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom buttons
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56.0,
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
                                onTap: _discardSchedule,
                                child: const Center(
                                  child: Text(
                                    'Discard',
                                    style: TextStyle(
                                      color: Color(0xFF007AFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                onTap: _saveSchedule,
                                child: const Center(
                                  child: Text(
                                    'Save Schedule',
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
