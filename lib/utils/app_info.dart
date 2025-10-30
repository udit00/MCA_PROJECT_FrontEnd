import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';


class AppInfo {
  // Private constructor
  AppInfo._internal();

  // The single shared instance
  static final AppInfo _instance = AppInfo._internal();

  // Factory constructor — returns the same instance every time
  factory AppInfo() => _instance;

  // Fields to hold data
  late final String platform;
  late final String version;
  late final String buildNumber;

  // Initialization method
  Future<void> init() async {
    // Detect platform
    if (Platform.isAndroid) {
      platform = "Android";
    } else if (Platform.isIOS) {
      platform = "iOS";
    } else if (Platform.isMacOS) {
      platform = "macOS";
    } else if (Platform.isLinux) {
      platform = "Linux";
    } else if (Platform.isWindows) {
      platform = "Windows";
    } else {
      platform = "Unknown";
    }

    // Get package info
    final packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}