import 'dart:developer' as developer;
import 'package:zymm/core/network/api_service.dart';

class ImageUrlHelper {
  static const String baseUrl = ApiService.envUrl;

  /// Converts a profile picture URL to a full URL if it's a relative path
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      developer.log('⚠️ ImageUrlHelper: imageUrl is null or empty');
      return '';
    }

    String fullUrl;
    
    // If already a full URL (contains ://), return as is
    if (imageUrl.contains('://')) {
      fullUrl = imageUrl;
      developer.log('✅ ImageUrlHelper: Already full URL: $fullUrl');
      return fullUrl;
    }

    // If it's a relative path, prepend the base URL
    if (imageUrl.startsWith('/')) {
      fullUrl = '$baseUrl$imageUrl';
      developer.log('✅ ImageUrlHelper: Converted relative URL: $imageUrl → $fullUrl');
      return fullUrl;
    }

    // Otherwise, assume it needs a slash
    fullUrl = '$baseUrl/$imageUrl';
    developer.log('✅ ImageUrlHelper: Added base URL and slash: $imageUrl → $fullUrl');
    return fullUrl;
  }
}

