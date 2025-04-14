import 'package:flutter/material.dart';

class TransportStep extends StatefulWidget {
  final List<String> transportModes;
  final List<String> selectedModes;

  const TransportStep({
    super.key,
    required this.transportModes,
    required this.selectedModes,
  });

  @override
  State<TransportStep> createState() => _TransportStepState();
}

class _TransportStepState extends State<TransportStep> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Which modes of transportation can you use?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.transportModes.map((mode) {
            final selected = widget.selectedModes.contains(mode);
            return CheckboxListTile(
              title: Text(mode),
              value: selected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    widget.selectedModes.add(mode);
                  } else {
                    widget.selectedModes.remove(mode);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
