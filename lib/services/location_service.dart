import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, throw an error
      throw LocationServiceDisabledException('Location services are disabled.');
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, throw an error
        throw LocationPermissionDeniedException(
            'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw LocationPermissionPermanentlyDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// Get user's address from coordinates using reverse geocoding
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return _formatAddress(place);
      }
      return 'Address not found';
    } catch (e) {
      return 'Error getting address: $e';
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark place) {
    List<String> addressParts = [
      if (place.thoroughfare?.isNotEmpty == true) place.thoroughfare!,
      if (place.subLocality?.isNotEmpty == true) place.subLocality!,
      if (place.locality?.isNotEmpty == true) place.locality!,
      if (place.administrativeArea?.isNotEmpty == true)
        place.administrativeArea!,
      if (place.postalCode?.isNotEmpty == true) place.postalCode!,
      if (place.country?.isNotEmpty == true) place.country!,
    ];

    return addressParts.where((part) => part.isNotEmpty).join(', ');
  }
}

/// Custom exceptions for better error handling
class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);
  @override
  String toString() => message;
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message;
  LocationPermissionPermanentlyDeniedException(this.message);
  @override
  String toString() => message;
}

class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);
  @override
  String toString() => message;
}
