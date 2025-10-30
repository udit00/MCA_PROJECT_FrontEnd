import 'package:zymm/core/network/api_service.dart';

class ImageUrlHelper {
  static const String baseUrl = ApiService.envUrl;

  /// Converts a profile picture URL to a full URL if it's a relative path
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    String fullUrl;
    
    // If already a full URL (contains ://), return as is
    if (imageUrl.contains('://')) {
      fullUrl = imageUrl;
      return fullUrl;
    }

    // If it's a relative path, prepend the base URL
    if (imageUrl.startsWith('/')) {
      fullUrl = '$baseUrl$imageUrl';
      return fullUrl;
    }

    // Otherwise, assume it needs a slash
    fullUrl = '$baseUrl/$imageUrl';
    return fullUrl;
  }
}

