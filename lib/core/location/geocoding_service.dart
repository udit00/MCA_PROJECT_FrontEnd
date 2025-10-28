import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static final GeocodingService instance = GeocodingService._internal();
  GeocodingService._internal();

  /// Get address from latitude and longitude strings
  /// Returns a formatted address string or coordinates as fallback
  Future<String> getAddressFromLatLng(String lat, String lng) async {
    try {
      final double latitude = double.parse(lat);
      final double longitude = double.parse(lng);
      
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        return _formatAddress(place);
      }
      
      // Fallback to coordinates if no address found
      return 'Location: $lat, $lng';
    } catch (e) {
      // Return coordinates as fallback on any error
      return 'Location: $lat, $lng';
    }
  }

  /// Get current location address from Position
  Future<String> getCurrentAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        return _formatAddress(place);
      }
      
      // Fallback to coordinates if no address found
      return 'Location: ${position.latitude}, ${position.longitude}';
    } catch (e) {
      // Return coordinates as fallback on any error
      return 'Location: ${position.latitude}, ${position.longitude}';
    }
  }

  /// Format Placemark into a readable address string
  String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    // Add street/name
    if (place.street?.isNotEmpty == true) {
      addressParts.add(place.street!);
    } else if (place.name?.isNotEmpty == true) {
      addressParts.add(place.name!);
    }
    
    // Add sublocality
    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
    }
    
    // Add locality (city)
    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
    }
    
    // Add administrative area (state)
    if (place.administrativeArea?.isNotEmpty == true) {
      addressParts.add(place.administrativeArea!);
    }
    
    // Add postal code
    if (place.postalCode?.isNotEmpty == true) {
      addressParts.add(place.postalCode!);
    }
    
    // Add country
    if (place.country?.isNotEmpty == true) {
      addressParts.add(place.country!);
    }
    
    // Join parts with comma
    String formattedAddress = addressParts.join(', ');
    
    // If empty, return a minimal version
    if (formattedAddress.isEmpty) {
      formattedAddress = '${place.locality ?? 'Unknown'}, ${place.country ?? 'Location'}';
    }
    
    return formattedAddress;
  }
}

