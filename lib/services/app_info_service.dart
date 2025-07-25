import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom device and app info service to replace conflicting packages
class AppInfoService {
  static const MethodChannel _channel = MethodChannel('pleb_ln/app_info');

  /// Get app version information
  Future<AppVersionInfo> getAppVersion() async {
    try {
      if (kIsWeb) {
        return const AppVersionInfo(
          appName: 'pleb-ln',
          packageName: 'com.pleb.ln',
          version: '1.0.0',
          buildNumber: '1',
        );
      }

      // For mobile platforms, we can get this from pubspec or platform-specific code
      return const AppVersionInfo(
        appName: 'pleb-ln',
        packageName: 'com.pleb.ln',
        version: '1.0.0',
        buildNumber: '1',
      );
    } catch (e) {
      // Fallback values
      return const AppVersionInfo(
        appName: 'pleb-ln',
        packageName: 'com.pleb.ln',
        version: '1.0.0',
        buildNumber: '1',
      );
    }
  }

  /// Get basic device information
  Future<DeviceInfo> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        return const DeviceInfo(
          platform: 'web',
          model: 'Web Browser',
          systemVersion: 'Unknown',
          isPhysicalDevice: false,
        );
      }

      if (Platform.isAndroid) {
        return DeviceInfo(
          platform: 'android',
          model: await _getAndroidModel(),
          systemVersion: await _getAndroidVersion(),
          isPhysicalDevice: true,
        );
      }

      if (Platform.isIOS) {
        return DeviceInfo(
          platform: 'ios',
          model: await _getIOSModel(),
          systemVersion: await _getIOSVersion(),
          isPhysicalDevice: true,
        );
      }

      return const DeviceInfo(
        platform: 'unknown',
        model: 'Unknown',
        systemVersion: 'Unknown',
        isPhysicalDevice: true,
      );
    } catch (e) {
      return DeviceInfo(
        platform: Platform.operatingSystem,
        model: 'Unknown',
        systemVersion: 'Unknown',
        isPhysicalDevice: !kIsWeb,
      );
    }
  }

  Future<String> _getAndroidModel() async {
    try {
      final result = await _channel.invokeMethod('getAndroidModel');
      return result ?? 'Android Device';
    } catch (e) {
      return 'Android Device';
    }
  }

  Future<String> _getAndroidVersion() async {
    try {
      final result = await _channel.invokeMethod('getAndroidVersion');
      return result ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<String> _getIOSModel() async {
    try {
      final result = await _channel.invokeMethod('getIOSModel');
      return result ?? 'iOS Device';
    } catch (e) {
      return 'iOS Device';
    }
  }

  Future<String> _getIOSVersion() async {
    try {
      final result = await _channel.invokeMethod('getIOSVersion');
      return result ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Check if running on a physical device (not emulator)
  Future<bool> isPhysicalDevice() async {
    try {
      if (kIsWeb) return false;
      
      final result = await _channel.invokeMethod('isPhysicalDevice');
      return result ?? true;
    } catch (e) {
      return !kIsWeb; // Assume physical device if we can't determine
    }
  }

  /// Get available storage space (in bytes)
  Future<int?> getAvailableStorage() async {
    try {
      if (kIsWeb) return null;
      
      final result = await _channel.invokeMethod('getAvailableStorage');
      return result as int?;
    } catch (e) {
      return null;
    }
  }
}

/// App version information model
class AppVersionInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  const AppVersionInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  /// Get formatted version string
  String get formattedVersion => '$version+$buildNumber';

  @override
  String toString() => 'AppVersionInfo(appName: $appName, version: $formattedVersion)';
}

/// Device information model
class DeviceInfo {
  final String platform;
  final String model;
  final String systemVersion;
  final bool isPhysicalDevice;

  const DeviceInfo({
    required this.platform,
    required this.model,
    required this.systemVersion,
    required this.isPhysicalDevice,
  });

  /// Check if running on Android
  bool get isAndroid => platform.toLowerCase() == 'android';

  /// Check if running on iOS
  bool get isIOS => platform.toLowerCase() == 'ios';

  /// Check if running on web
  bool get isWeb => platform.toLowerCase() == 'web';

  /// Get platform display name
  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      case 'web':
        return 'Web';
      default:
        return platform.toUpperCase();
    }
  }

  @override
  String toString() => 'DeviceInfo(platform: $platformDisplayName, model: $model)';
}

/// App info service provider
final appInfoServiceProvider = Provider<AppInfoService>((ref) {
  return AppInfoService();
});

/// App version provider
final appVersionProvider = FutureProvider<AppVersionInfo>((ref) async {
  final appInfoService = ref.read(appInfoServiceProvider);
  return appInfoService.getAppVersion();
});

/// Device info provider
final deviceInfoProvider = FutureProvider<DeviceInfo>((ref) async {
  final appInfoService = ref.read(appInfoServiceProvider);
  return appInfoService.getDeviceInfo();
});

/// Physical device check provider
final isPhysicalDeviceProvider = FutureProvider<bool>((ref) async {
  final appInfoService = ref.read(appInfoServiceProvider);
  return appInfoService.isPhysicalDevice();
});

/// Formatted app version provider for display
final formattedVersionProvider = Provider<String>((ref) {
  final versionAsync = ref.watch(appVersionProvider);
  return versionAsync.when(
    data: (version) => version.formattedVersion,
    loading: () => 'Loading...',
    error: (error, stack) => 'Unknown',
  );
});

/// Platform display name provider
final platformNameProvider = Provider<String>((ref) {
  final deviceAsync = ref.watch(deviceInfoProvider);
  return deviceAsync.when(
    data: (device) => device.platformDisplayName,
    loading: () => 'Loading...',
    error: (error, stack) => 'Unknown',
  );
});
