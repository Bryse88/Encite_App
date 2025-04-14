import 'package:encite/services/location_service.dart' as custom_location;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({Key? key}) : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final custom_location.LocationService _locationService =
      custom_location.LocationService();
  bool _isLoading = false;
  String _locationMessage = 'Tap the button to get your location';
  String _addressMessage = '';
  Position? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _locationMessage,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        if (_addressMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _addressMessage,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _getLocation,
                child: const Text('Get Current Location'),
              ),
        if (_currentPosition != null) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _getAddress,
            child: const Text('Get Address'),
          ),
        ],
      ],
    );
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Getting your location...';
      _addressMessage = '';
    });

    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _locationMessage =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        _isLoading = false;
      });
    } catch (e) {
      _handleLocationError(e);
    }
  }

  Future<void> _getAddress() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      _addressMessage = 'Getting address...';
    });

    try {
      final address = await _locationService.getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      setState(() {
        _addressMessage = address;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _addressMessage = 'Error fetching address: $e';
        _isLoading = false;
      });
    }
  }

  void _handleLocationError(dynamic e) {
    setState(() {
      _locationMessage = 'Error: $e';
      _isLoading = false;
    });

    if (e is custom_location.LocationPermissionDeniedException) {
      _showPermissionDialog();
    } else if (e
        is custom_location.LocationPermissionPermanentlyDeniedException) {
      _showAppSettingsDialog();
    } else if (e is custom_location.LocationServiceDisabledException) {
      _showLocationServiceDialog();
    }
  }

  Future<void> _showPermissionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
              'This app needs location permission to function properly.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _getLocation();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAppSettingsDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
              'Location permission is permanently denied. Open app settings to enable it.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationServiceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to proceed.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
