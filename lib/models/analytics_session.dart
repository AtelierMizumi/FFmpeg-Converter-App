/// Session data model
class AnalyticsSession {
  final String sessionId;
  final String userIdHash;
  final DateTime timestamp;

  // Device info
  final String? deviceModel;
  final String? deviceBrand;
  final String? deviceManufacturer;
  final String? deviceIdHash;
  final int? screenWidth;
  final int? screenHeight;
  final double? screenDensity;
  final List<String>? supportedAbis;

  // OS info
  final String? osName;
  final String? osVersion;
  final int? apiLevel;
  final String? kernelVersion;

  // App info
  final String? appVersion;
  final String? appBuildNumber;
  final String? packageName;
  final bool? isFirstLaunch;
  final String? installSource;
  final int? launchCount;

  // Network info
  final String? networkType;
  final String? carrierName;
  final String? ipAddress;

  // Locale info
  final String? localeLanguage;
  final String? localeCountry;
  final String? timezone;
  final int? timezoneOffset;
  final String? currency;

  // Performance info
  final int? startupTimeMs;
  final double? memoryUsageMb;
  final double? availableStorageGb;

  AnalyticsSession({
    required this.sessionId,
    required this.userIdHash,
    required this.timestamp,
    this.deviceModel,
    this.deviceBrand,
    this.deviceManufacturer,
    this.deviceIdHash,
    this.screenWidth,
    this.screenHeight,
    this.screenDensity,
    this.supportedAbis,
    this.osName,
    this.osVersion,
    this.apiLevel,
    this.kernelVersion,
    this.appVersion,
    this.appBuildNumber,
    this.packageName,
    this.isFirstLaunch,
    this.installSource,
    this.launchCount,
    this.networkType,
    this.carrierName,
    this.ipAddress,
    this.localeLanguage,
    this.localeCountry,
    this.timezone,
    this.timezoneOffset,
    this.currency,
    this.startupTimeMs,
    this.memoryUsageMb,
    this.availableStorageGb,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id_hash': userIdHash,
      'timestamp': timestamp.toIso8601String(),
      if (deviceModel != null) 'device_model': deviceModel,
      if (deviceBrand != null) 'device_brand': deviceBrand,
      if (deviceManufacturer != null) 'device_manufacturer': deviceManufacturer,
      if (deviceIdHash != null) 'device_id_hash': deviceIdHash,
      if (screenWidth != null) 'screen_width': screenWidth,
      if (screenHeight != null) 'screen_height': screenHeight,
      if (screenDensity != null) 'screen_density': screenDensity,
      if (supportedAbis != null) 'supported_abis': supportedAbis,
      if (osName != null) 'os_name': osName,
      if (osVersion != null) 'os_version': osVersion,
      if (apiLevel != null) 'api_level': apiLevel,
      if (kernelVersion != null) 'kernel_version': kernelVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (appBuildNumber != null) 'app_build_number': appBuildNumber,
      if (packageName != null) 'package_name': packageName,
      if (isFirstLaunch != null) 'is_first_launch': isFirstLaunch,
      if (installSource != null) 'install_source': installSource,
      if (launchCount != null) 'launch_count': launchCount,
      if (networkType != null) 'network_type': networkType,
      if (carrierName != null) 'carrier_name': carrierName,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (localeLanguage != null) 'locale_language': localeLanguage,
      if (localeCountry != null) 'locale_country': localeCountry,
      if (timezone != null) 'timezone': timezone,
      if (timezoneOffset != null) 'timezone_offset': timezoneOffset,
      if (currency != null) 'currency': currency,
      if (startupTimeMs != null) 'startup_time_ms': startupTimeMs,
      if (memoryUsageMb != null) 'memory_usage_mb': memoryUsageMb,
      if (availableStorageGb != null)
        'available_storage_gb': availableStorageGb,
    };
  }
}
