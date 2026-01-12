import 'package:flutter/foundation.dart';
import '../config/analytics_config.dart';
import '../models/analytics_session.dart';
import 'device_info_service.dart';
import 'session_manager.dart';
import 'event_tracker.dart';
import 'error_reporter.dart';
import 'network_service.dart';

/// Main analytics service - orchestrates all analytics functionality
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;

  AnalyticsService._internal();

  final SessionManager _sessionManager = SessionManager();
  final EventTracker _eventTracker = EventTracker();

  bool _isInitialized = false;
  DateTime? _initStartTime;

  /// Initialize analytics system
  /// Call this in main() before runApp()
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!AnalyticsConfig.enabled) {
      if (kDebugMode) {
        print('Analytics disabled in config');
      }
      return;
    }

    _initStartTime = DateTime.now();

    try {
      if (AnalyticsConfig.debugMode) {
        print('Initializing analytics...');
      }

      // Setup error handlers
      ErrorReporter.setupErrorHandlers();

      // Initialize event tracker
      _eventTracker.initialize();

      // Create new session
      final sessionId = await _sessionManager.startNewSession();

      // Collect device info
      final deviceInfo = await DeviceInfoService.collectDeviceInfo();

      // Get user ID
      final userIdHash = await _sessionManager.getUserIdHash();

      // Check if first launch
      final isFirstLaunch = await _sessionManager.isFirstLaunch();
      final launchCount = await _sessionManager.getLaunchCount();

      // Calculate startup time
      final startupTimeMs = _initStartTime != null
          ? DateTime.now().difference(_initStartTime!).inMilliseconds
          : null;

      // Create session object
      final session = AnalyticsSession(
        sessionId: sessionId,
        userIdHash: userIdHash,
        timestamp: DateTime.now(),
        deviceModel: deviceInfo['device_model'],
        deviceBrand: deviceInfo['device_brand'],
        deviceManufacturer: deviceInfo['device_manufacturer'],
        deviceIdHash: deviceInfo['device_id_hash'],
        screenWidth: deviceInfo['screen_width'],
        screenHeight: deviceInfo['screen_height'],
        screenDensity: deviceInfo['screen_density'],
        supportedAbis: deviceInfo['supported_abis'],
        osName: deviceInfo['os_name'],
        osVersion: deviceInfo['os_version'],
        apiLevel: deviceInfo['api_level'],
        kernelVersion: deviceInfo['kernel_version'],
        appVersion: deviceInfo['app_version'],
        appBuildNumber: deviceInfo['app_build_number'],
        packageName: deviceInfo['package_name'],
        isFirstLaunch: isFirstLaunch,
        launchCount: launchCount,
        networkType: deviceInfo['network_type'],
        carrierName: deviceInfo['carrier_name'],
        localeLanguage: deviceInfo['locale_language'],
        localeCountry: deviceInfo['locale_country'],
        timezone: deviceInfo['timezone'],
        timezoneOffset: deviceInfo['timezone_offset'],
        startupTimeMs: startupTimeMs,
      );

      // Send session to backend
      await NetworkService.sendSession(session);

      // Track app launch event
      await _eventTracker.trackAppLaunched();

      _isInitialized = true;

      if (AnalyticsConfig.debugMode) {
        print('✓ Analytics initialized successfully');
        print('  Session ID: $sessionId');
        print('  User ID Hash: ${userIdHash.substring(0, 8)}...');
        print('  First Launch: $isFirstLaunch');
        print('  Launch Count: $launchCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize analytics: $e');
      }
    }
  }

  /// Track app resumed from background
  Future<void> onAppResumed() async {
    if (!_isInitialized) return;
    await _eventTracker.trackAppResumed();
  }

  /// Track app paused (backgrounded)
  Future<void> onAppPaused() async {
    if (!_isInitialized) return;
    await _eventTracker.trackAppPaused();
    await _eventTracker.flush(); // Flush events before pause
  }

  /// Get event tracker instance for custom tracking
  EventTracker get eventTracker => _eventTracker;

  /// Get session manager instance
  SessionManager get sessionManager => _sessionManager;

  /// Test connection to backend
  Future<bool> testConnection() async {
    return await NetworkService.testConnection();
  }

  /// Clear all analytics data (for testing or privacy)
  Future<void> clearAllData() async {
    await _sessionManager.clearAll();
    if (AnalyticsConfig.debugMode) {
      print('Analytics data cleared');
    }
  }

  /// Get current session ID
  Future<String> getSessionId() async {
    return await _sessionManager.getSessionId();
  }

  /// Check if analytics is initialized
  bool get isInitialized => _isInitialized;
}
