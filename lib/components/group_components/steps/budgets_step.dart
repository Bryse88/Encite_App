import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BudgetStep extends StatefulWidget {
  final ValueChanged<double> onBudgetChanged;

  const BudgetStep({super.key, required this.onBudgetChanged});

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  final _controller = TextEditingController(text: "100.00");
  final _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    // Instead of calling the callback immediately, schedule it for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budget = double.tryParse(_controller.text) ?? 0.0;
      widget.onBudgetChanged(budget);
    });

    // Add listener to focus node to track keyboard visibility
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isKeyboardVisible = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside the text field
      onTap: () => FocusScope.of(context).unfocus(),
      behavior:
          HitTestBehavior.opaque, // Ensures taps on empty space are detected
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What's your budget?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your total budget for this outing",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: "Budget",
                    prefixText: "\$",
                    border: OutlineInputBorder(),
                    helperText: "Tap anywhere to dismiss keyboard",
                  ),
                  onChanged: (val) {
                    final budget = double.tryParse(val) ?? 0.0;
                    widget.onBudgetChanged(budget);
                  },
                  onEditingComplete: () {
                    // Dismiss keyboard when user presses the "Done" button
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ),

          // Show "Done" button when keyboard is visible
          if (_isKeyboardVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom
                      : 20,
                  left: 24,
                  right: 24,
                ),
                height: 48,
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
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: const Center(
                      child: Text(
                        "Done",
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
    );
  }
}
