import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Private constructor
  StorageService._internal();

  // Single instance (lazily initialized)
  static final StorageService _instance = StorageService._internal();

  // Public getter to access the same instance everywhere
  static StorageService get instance => _instance;

  static const String _authTokenKey = 'authToken';

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }
}
