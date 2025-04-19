// Example implementation of EventsPage
import 'package:encite/components/Colors/uber_colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class EventsPage extends StatelessWidget {
  final DateTime selectedDate;

  const EventsPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = dateFormat.format(selectedDate);

    // Get events for the selected date
    final events = _getEventsForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate'),
        backgroundColor: UberColors.primary,
      ),
      body: events.isEmpty
          ? const Center(
              child: Text(
                'No events for this date',
                style: TextStyle(
                  fontSize: 16,
                  color: UberColors.textSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventCard(event: event);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventPage(selectedDate: selectedDate),
            ),
          );
        },
        backgroundColor: UberColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Example helper method to get events for a specific date
List<Event> _getEventsForDate(DateTime date) {
  // This would typically fetch from your data source
  // For now, returning a dummy implementation
  final events = <Event>[];

  // Check if this date has any events in your database/state
  // Here you would query your actual events data

  return events;
}

// Example Event class
class Event {
  final String title;
  final String description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;

  Event({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
  });
}

// Example EventCard widget
class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatTimeOfDay(event.startTime)} - ${_formatTimeOfDay(event.endTime)}',
              style: TextStyle(
                color: UberColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(event.description),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// Example AddEventPage
class AddEventPage extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
        backgroundColor: UberColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Time selection widgets would go here
              // Color selection would go here
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UberColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Save Event',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // Create new event
      final newEvent = Event(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
      );

      // Save event to your data source
      // This would typically use a provider, bloc, or other state management

      // Close the page and return to events list
      Navigator.pop(context);
    }
  }
}
