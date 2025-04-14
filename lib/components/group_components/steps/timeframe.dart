import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeFrameStep extends StatefulWidget {
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;
  final Function(bool)? onOvernightChanged;

  const TimeFrameStep({
    Key? key,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    this.onOvernightChanged,
  }) : super(key: key);

  @override
  State<TimeFrameStep> createState() => _TimeFrameStepState();
}

class _TimeFrameStepState extends State<TimeFrameStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  TimeOfDay _startTime = TimeOfDay.now();
  late TimeOfDay _endTime;
  bool _isOvernight = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Set initial end time to be 1 hour after start time
    _endTime = TimeOfDay(
      hour: (_startTime.hour + 1) % 24,
      minute: _startTime.minute,
    );

    // Initialize the parent's values
    widget.onStartTimeChanged(_startTime);
    widget.onEndTimeChanged(_endTime);
    if (widget.onOvernightChanged != null) {
      widget.onOvernightChanged!(_isOvernight);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        _updateOvernightStatus();
      });
      widget.onStartTimeChanged(_startTime);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
        _updateOvernightStatus();
      });
      widget.onEndTimeChanged(_endTime);
      if (widget.onOvernightChanged != null) {
        widget.onOvernightChanged!(_isOvernight);
      }
    }
  }

  void _updateOvernightStatus() {
    // Check if end time is earlier in the day than start time
    final int startMinutes = _timeOfDayToMinutes(_startTime);
    final int endMinutes = _timeOfDayToMinutes(_endTime);

    setState(() {
      _isOvernight = endMinutes < startMinutes;
    });

    if (widget.onOvernightChanged != null) {
      widget.onOvernightChanged!(_isOvernight);
    }
  }

  // Convert TimeOfDay to minutes for comparison
  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // 12-hour format with AM/PM
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final duration = _getDurationText();

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(_animation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Card(
            elevation: 4,
            shadowColor: Theme.of(context).shadowColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectStartTime(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimeOfDay(_startTime),
                            style: const TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectEndTime(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimeOfDay(_endTime),
                            style: const TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Overnight indicator
                  if (_isOvernight)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer
                            .withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Overnight',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Duration: $duration',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick time presets
                  Text(
                    'Quick Select',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildQuickTimeButton('30 min', 30),
                      _buildQuickTimeButton('1 hour', 60),
                      _buildQuickTimeButton('2 hours', 120),
                      _buildQuickTimeButton('3 hours', 180),
                      _buildQuickTimeButton('4 hours', 240),
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

  Widget _buildQuickTimeButton(String text, int durationInMinutes) {
    return InkWell(
      onTap: () {
        setState(() {
          // Keep start time the same, adjust end time based on duration
          final int startMinutes = _timeOfDayToMinutes(_startTime);
          final int endMinutes = startMinutes + durationInMinutes;

          final int endHour = (endMinutes ~/ 60) % 24;
          final int endMinute = endMinutes % 60;

          _endTime = TimeOfDay(hour: endHour, minute: endMinute);
          _updateOvernightStatus();
        });
        widget.onEndTimeChanged(_endTime);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getDurationText() {
    final int startMinutes = _timeOfDayToMinutes(_startTime);
    int endMinutes = _timeOfDayToMinutes(_endTime);

    // If end time is earlier in the day than start time, assume it's the next day
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours
    }

    final int durationMinutes = endMinutes - startMinutes;
    final int hours = durationMinutes ~/ 60;
    final int minutes = durationMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours hr ${minutes}min';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }
}
