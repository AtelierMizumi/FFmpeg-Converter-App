import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../utils/crypto_utils.dart';

/// Service to collect device, OS, app, network, and locale information
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static final Connectivity _connectivity = Connectivity();

  /// Collect all device information
  static Future<Map<String, dynamic>> collectDeviceInfo() async {
    final Map<String, dynamic> info = {};

    try {
      // Device & OS info
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        info.addAll(_getAndroidInfo(androidInfo));
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        info.addAll(_getIosInfo(iosInfo));
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        info.addAll(_getLinuxInfo(linuxInfo));
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        info.addAll(_getWindowsInfo(windowsInfo));
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        info.addAll(_getMacInfo(macInfo));
      }

      // App info
      final appInfo = await _getAppInfo();
      info.addAll(appInfo);

      // Network info
      final networkInfo = await _getNetworkInfo();
      info.addAll(networkInfo);

      // Locale info
      final localeInfo = _getLocaleInfo();
      info.addAll(localeInfo);

      // Screen info
      final screenInfo = _getScreenInfo();
      info.addAll(screenInfo);
    } catch (e) {
      if (kDebugMode) {
        print('Error collecting device info: $e');
      }
    }

    return info;
  }

  /// Extract Android device information
  static Map<String, dynamic> _getAndroidInfo(AndroidDeviceInfo info) {
    return {
      'device_model': info.model,
      'device_brand': info.brand,
      'device_manufacturer': info.manufacturer,
      'device_id_hash': CryptoUtils.sha256Hash(info.id),
      'supported_abis': info.supportedAbis,
      'os_name': 'Android',
      'os_version': info.version.release,
      'api_level': info.version.sdkInt,
      'kernel_version': info.version.incremental,
    };
  }

  /// Extract iOS device information
  static Map<String, dynamic> _getIosInfo(IosDeviceInfo info) {
    return {
      'device_model': info.model,
      'device_brand': 'Apple',
      'device_manufacturer': 'Apple',
      'device_id_hash': CryptoUtils.sha256Hash(
        info.identifierForVendor ?? 'unknown',
      ),
      'os_name': info.systemName,
      'os_version': info.systemVersion,
    };
  }

  /// Extract Linux device information
  static Map<String, dynamic> _getLinuxInfo(LinuxDeviceInfo info) {
    return {
      'device_model': info.prettyName,
      'device_id_hash': CryptoUtils.sha256Hash(info.machineId ?? 'unknown'),
      'os_name': 'Linux',
      'os_version': info.version ?? 'unknown',
      'kernel_version': info.versionId,
    };
  }

  /// Extract Windows device information
  static Map<String, dynamic> _getWindowsInfo(WindowsDeviceInfo info) {
    return {
      'device_model': info.computerName,
      'device_manufacturer': info.computerName,
      'os_name': 'Windows',
      'os_version':
          '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
    };
  }

  /// Extract macOS device information
  static Map<String, dynamic> _getMacInfo(MacOsDeviceInfo info) {
    return {
      'device_model': info.model,
      'device_brand': 'Apple',
      'device_manufacturer': 'Apple',
      'os_name': 'macOS',
      'os_version': info.osRelease,
      'kernel_version': info.kernelVersion,
    };
  }

  /// Get app information
  static Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'app_version': packageInfo.version,
        'app_build_number': packageInfo.buildNumber,
        'package_name': packageInfo.packageName,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting app info: $e');
      }
      return {};
    }
  }

  /// Get network information
  static Future<Map<String, dynamic>> _getNetworkInfo() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      String networkType = 'none';
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        networkType = 'wifi';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        networkType = 'mobile';
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        networkType = 'ethernet';
      }

      return {'network_type': networkType};
    } catch (e) {
      if (kDebugMode) {
        print('Error getting network info: $e');
      }
      return {'network_type': 'unknown'};
    }
  }

  /// Get locale information
  static Map<String, dynamic> _getLocaleInfo() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale;
      final now = DateTime.now();

      return {
        'locale_language': locale.languageCode,
        'locale_country': locale.countryCode,
        'timezone': now.timeZoneName,
        'timezone_offset': now.timeZoneOffset.inMinutes,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting locale info: $e');
      }
      return {};
    }
  }

  /// Get screen information
  static Map<String, dynamic> _getScreenInfo() {
    try {
      final view = ui.PlatformDispatcher.instance.views.first;
      final physicalSize = view.physicalSize;
      final devicePixelRatio = view.devicePixelRatio;

      return {
        'screen_width': physicalSize.width.toInt(),
        'screen_height': physicalSize.height.toInt(),
        'screen_density': devicePixelRatio,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting screen info: $e');
      }
      return {};
    }
  }

  /// Generate unique device fingerprint (hashed)
  static Future<String> getDeviceFingerprint() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return CryptoUtils.sha256Hash(androidInfo.id);
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return CryptoUtils.sha256Hash(iosInfo.identifierForVendor ?? 'unknown');
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return CryptoUtils.sha256Hash(linuxInfo.machineId ?? 'unknown');
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return CryptoUtils.sha256Hash(windowsInfo.computerName);
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return CryptoUtils.sha256Hash(macInfo.systemGUID ?? 'unknown');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device fingerprint: $e');
      }
    }

    // Fallback to timestamp-based ID
    return CryptoUtils.sha256Hash(DateTime.now().toIso8601String());
  }
}
