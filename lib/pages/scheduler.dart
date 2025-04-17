import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:encite/models/activity.dart';
import 'package:encite/models/schedule.dart';

// Models
// class Activity {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime startTime;
//   final DateTime endTime;
//   final double price;
//   final String imageUrl;

//   Activity({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.startTime,
//     required this.endTime,
//     required this.price,
//     required this.imageUrl,
//   });

//   Activity copyWith({
//     String? id,
//     String? title,
//     String? description,
//     DateTime? startTime,
//     DateTime? endTime,
//     double? price,
//     String? imageUrl,
//   }) {
//     return Activity(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       price: price ?? this.price,
//       imageUrl: imageUrl ?? this.imageUrl,
//     );
//   }
// }

// class Schedule {
//   final String id;
//   final List<Activity> activities;
//   final DateTime createdAt;

//   Schedule({
//     required this.id,
//     required this.activities,
//     required this.createdAt,
//   });

//   double get totalCost =>
//       activities.fold(0, (sum, activity) => sum + activity.price);

//   DateTime get startTime => activities.isNotEmpty
//       ? activities
//           .map((a) => a.startTime)
//           .reduce((a, b) => a.isBefore(b) ? a : b)
//       : DateTime.now();

//   DateTime get endTime => activities.isNotEmpty
//       ? activities.map((a) => a.endTime).reduce((a, b) => a.isAfter(b) ? a : b)
//       : DateTime.now();

//   String get timeFrame {
//     final timeFormat = DateFormat('h:mm a');
//     return '${timeFormat.format(startTime)} – ${timeFormat.format(endTime)}';
//   }
// }

class ScheduleService {
  Future<Activity> requestSubstituteActivity(
      String activityId, Schedule schedule) async {
    // Replace this mock with real API call later
    await Future.delayed(const Duration(seconds: 1));

    return Activity(
      id: 'substitute_$activityId',
      title: 'Substitute Activity',
      description: 'This is a substitute activity recommended by our AI.',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      price: 35.99,
      imageUrl: 'https://picsum.photos/200?random=123',
    );
  }

  Future<void> saveSchedule(Schedule schedule) async {
    final docRef =
        FirebaseFirestore.instance.collection('schedules').doc(schedule.id);

    await docRef.set({
      'id': schedule.id,
      'createdAt': schedule.createdAt.toIso8601String(),
      'activities': schedule.activities
          .map((a) => {
                'id': a.id,
                'title': a.title,
                'description': a.description,
                'startTime': a.startTime.toIso8601String(),
                'endTime': a.endTime.toIso8601String(),
                'price': a.price,
                'imageUrl': a.imageUrl,
              })
          .toList(),
    });
  }
}

// The main schedule presentation page
class SchedulePresentationPage extends StatefulWidget {
  final Schedule schedule;

  const SchedulePresentationPage({Key? key, required this.schedule})
      : super(key: key);

  @override
  State<SchedulePresentationPage> createState() =>
      _SchedulePresentationPageState();
}

class _SchedulePresentationPageState extends State<SchedulePresentationPage> {
  late Schedule _schedule;
  final _scheduleService = ScheduleService();
  bool _isLoading = false;

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
      // Show success message or navigate away
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule saved successfully!')));
      Navigator.pop(context, _schedule);
    } catch (e) {
      // Show error message
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
          activity.id, _schedule);

      setState(() {
        final newActivities = List<Activity>.from(_schedule.activities);
        newActivities[index] = substitute;
        _schedule = Schedule(
          id: _schedule.id,
          activities: newActivities,
          createdAt: _schedule.createdAt,
        );
      });
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
                            // Total cost
                            Row(
                              children: [
                                Text(
                                  'Total Cost',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${_schedule.totalCost.toStringAsFixed(2)}',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Time frame
                            Row(
                              children: [
                                Text(
                                  'Time Frame',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _schedule.timeFrame,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
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
                          child: ElevatedButton(
                            onPressed: _discardSchedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              foregroundColor:
                                  isDarkMode ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Discard'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveSchedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Save Schedule'),
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

// Activity card component
class ActivityCard extends StatefulWidget {
  final Activity activity;
  final VoidCallback onDelete;
  final bool isDarkMode;

  const ActivityCard({
    Key? key,
    required this.activity,
    required this.onDelete,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: widget.activity.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and delete button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.activity.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Request substitute activity',
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),

                  // Time range
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${timeFormat.format(widget.activity.startTime)} - ${timeFormat.format(widget.activity.endTime)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Price
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '\$${widget.activity.price.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description (expandable)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Description',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 16,
                            ),
                          ],
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.activity.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
