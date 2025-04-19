import 'package:flutter/material.dart';

class BudgetStep extends StatefulWidget {
  final ValueChanged<double> onBudgetChanged;

  const BudgetStep({super.key, required this.onBudgetChanged});

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  final _controller = TextEditingController(text: "100.00");
  final _focusNode = FocusNode();

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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: "Budget",
            prefixText: "\$",
            border: OutlineInputBorder(),
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
      ),
    );
  }
}
