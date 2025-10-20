import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Private constructor
  StorageService._internal();

  // Single instance (lazily initialized)
  static final StorageService _instance = StorageService._internal();

  // Public getter to access the same instance everywhere
  static StorageService get instance => _instance;

  static const String _authTokenPrefKey = 'authTokenPrefKey';
  static const String _displayNamePrefKey = 'displayNamePrefKey';

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenPrefKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenPrefKey);
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenPrefKey);
  }

  Future<void> saveDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNamePrefKey, displayName);
  }

  Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayNamePrefKey);
  }

  Future<void> _clearDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_displayNamePrefKey);
  }

  Future<void> clearAllOnLogout() async {
    await _clearAuthToken();
    await _clearDisplayName();
  }

}
