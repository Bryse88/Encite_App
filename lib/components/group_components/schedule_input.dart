import 'package:encite/components/group_components/steps/budgets_step.dart';
import 'package:encite/components/group_components/steps/location_step.dart';
import 'package:encite/components/group_components/steps/timeframe.dart';
import 'package:encite/components/group_components/steps/transportation_step.dart';
import 'package:flutter/material.dart';

class SchedulerForm extends StatefulWidget {
  const SchedulerForm({Key? key}) : super(key: key);

  @override
  State<SchedulerForm> createState() => _SchedulerFormState();
}

class _SchedulerFormState extends State<SchedulerForm>
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

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Schedule Created!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Time: ${_startTime?.format(context)} – ${_endTime?.format(context)}"),
            Text("Budget: \$${_budget.toStringAsFixed(2)}"),
            Text(
                "Location: ${_useCurrentLocation ? "Current Location" : _location}"),
            Text("Transport: ${_selectedTransportModes.join(", ")}"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Done"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Schedule")),
      // Use PageView with vertical scroll direction
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical, // Vertical sliding
        physics: const NeverScrollableScrollPhysics(), // Prevent user scrolling
        children: [
          // Each step is a separate page
          TimeFrameStep(
            onStartTimeChanged: (t) => _startTime = t,
            onEndTimeChanged: (t) => _endTime = t,
          ),
          BudgetStep(onBudgetChanged: (b) => _budget = b),
          LocationStep(
            onLocationChanged: (l) => _location = l,
            onUseCurrentLocationChanged: (v) => _useCurrentLocation = v,
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
      bottomNavigationBar: Padding(
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
                        _currentPage == _totalPages - 1 ? 'Finish' : 'Next',
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
