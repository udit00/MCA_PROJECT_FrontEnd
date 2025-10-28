import 'dart:io';

class NetworkInfo {
  /// Get device's local IP address
  /// Returns empty string if unable to fetch
  static Future<String> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
      return '0.0.0.0';
    } catch (e) {
      return '0.0.0.0';
    }
  }
}


