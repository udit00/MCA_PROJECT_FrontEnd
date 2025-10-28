import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationData {
  final String latitude;
  final String longitude;

  LocationData({required this.latitude, required this.longitude});
}

class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  /// Get current location with permission handling
  /// Returns LocationData with lat/long as strings
  /// Throws exception if permission denied or location unavailable
  Future<LocationData> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException('Location services are disabled.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedForeverException(
          'Location permissions are permanently denied. Please enable them in settings.',
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationData(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Check if location permission is permanently denied
  Future<bool> isLocationPermissionDeniedForever() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  /// Open app settings
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }

  /// Show permission dialog when permanently denied
  static void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8),
              Text('Location Required'),
            ],
          ),
          content: const Text(
            'This feature requires access to your location. '
            'Please enable location permission in your device settings to continue.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Show location service disabled dialog
  static void showLocationServiceDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Location Service Disabled'),
            ],
          ),
          content: const Text(
            'Please enable location services on your device to continue.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Get location with user-friendly error handling
  /// Shows appropriate dialogs based on error type
  Future<LocationData?> getLocationWithErrorHandling(BuildContext context) async {
    try {
      return await getCurrentLocation();
    } on LocationServiceDisabledException catch (_) {
      if (context.mounted) {
        showLocationServiceDisabledDialog(context);
      }
      return null;
    } on LocationPermissionDeniedForeverException catch (_) {
      if (context.mounted) {
        showPermissionDeniedDialog(context);
      }
      return null;
    } on LocationPermissionDeniedException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required. Please grant permission to continue.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return null;
    } catch (e) {
      // Handle Google Play Services missing or other errors
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Location Error'),
                ],
              ),
              content: Text(
                'Unable to access location services. This may be due to:\n\n'
                '• Missing Google Play Services\n'
                '• Location hardware unavailable\n'
                '• System error\n\n'
                'Error: ${e.toString()}',
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      return null;
    }
  }
}

// Custom exceptions
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);
  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);
  @override
  String toString() => message;
}

class LocationPermissionDeniedForeverException implements Exception {
  final String message;
  LocationPermissionDeniedForeverException(this.message);
  @override
  String toString() => message;
}

