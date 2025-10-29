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
  static const String _gymIdPrefKey = 'gymIdPrefKey';
  static const String _roleIdPrefKey = 'roleIdPrefKey';

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

  Future<void> saveGymId(int gymId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gymIdPrefKey, gymId);
  }

  Future<int?> getGymId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gymIdPrefKey);
  }

  Future<void> _clearGymId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gymIdPrefKey);
  }

  Future<void> saveRoleId(int roleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_roleIdPrefKey, roleId);
  }

  Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleIdPrefKey);
  }

  Future<void> _clearRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleIdPrefKey);
  }

  Future<void> clearAllOnLogout() async {
    await _clearAuthToken();
    await _clearDisplayName();
    await _clearGymId();
    await _clearRoleId();
  }

}
