import 'package:flutter/material.dart';

class BudgetStep extends StatefulWidget {
  final ValueChanged<double> onBudgetChanged;

  const BudgetStep({super.key, required this.onBudgetChanged});

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  final _controller = TextEditingController(text: "100.00");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Budget",
          prefixText: "\$",
          border: OutlineInputBorder(),
        ),
        onChanged: (val) {
          final budget = double.tryParse(val) ?? 0.0;
          widget.onBudgetChanged(budget);
        },
      ),
    );
  }
}
