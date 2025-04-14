import 'package:flutter/material.dart';

class LocationStep extends StatefulWidget {
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<bool> onUseCurrentLocationChanged;

  const LocationStep({
    super.key,
    required this.onLocationChanged,
    required this.onUseCurrentLocationChanged,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  bool _useCurrent = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("Use Current Location"),
            value: _useCurrent,
            onChanged: (val) {
              setState(() => _useCurrent = val);
              widget.onUseCurrentLocationChanged(val);
            },
          ),
          if (!_useCurrent)
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter location",
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onLocationChanged,
            ),
        ],
      ),
    );
  }
}
