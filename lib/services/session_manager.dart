import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../utils/crypto_utils.dart';
import 'device_info_service.dart';

/// Manages session and user IDs with persistent storage
class SessionManager {
  static const String _keyUserId = 'analytics_user_id';
  static const String _keySessionId = 'analytics_session_id';
  static const String _keyIsFirstLaunch = 'analytics_is_first_launch';
  static const String _keyLaunchCount = 'analytics_launch_count';

  static final Uuid _uuid = const Uuid();

  String? _currentSessionId;
  String? _userIdHash;

  /// Get or create user ID (persistent across sessions)
  Future<String> getUserIdHash() async {
    if (_userIdHash != null) return _userIdHash!;

    final prefs = await SharedPreferences.getInstance();

    // Check if user ID exists
    String? userId = prefs.getString(_keyUserId);

    if (userId == null) {
      // Generate new user ID from device fingerprint
      final deviceFingerprint = await DeviceInfoService.getDeviceFingerprint();
      userId = _uuid.v4();
      await prefs.setString(_keyUserId, userId);

      // Combine UUID with device fingerprint for better uniqueness
      _userIdHash = CryptoUtils.sha256HashMultiple([userId, deviceFingerprint]);
    } else {
      // Hash existing user ID
      final deviceFingerprint = await DeviceInfoService.getDeviceFingerprint();
      _userIdHash = CryptoUtils.sha256HashMultiple([userId, deviceFingerprint]);
    }

    return _userIdHash!;
  }

  /// Get current session ID (changes per app launch)
  Future<String> getSessionId() async {
    if (_currentSessionId != null) return _currentSessionId!;

    final prefs = await SharedPreferences.getInstance();

    // Check if session exists
    String? sessionId = prefs.getString(_keySessionId);

    if (sessionId == null) {
      // Create new session
      sessionId = _uuid.v4();
      await prefs.setString(_keySessionId, sessionId);
    }

    _currentSessionId = sessionId;
    return _currentSessionId!;
  }

  /// Create new session (call on app launch)
  Future<String> startNewSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Generate new session ID
    final sessionId = _uuid.v4();
    await prefs.setString(_keySessionId, sessionId);

    _currentSessionId = sessionId;

    // Increment launch count
    await incrementLaunchCount();

    return sessionId;
  }

  /// Check if this is the first app launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    final isFirst = prefs.getBool(_keyIsFirstLaunch);

    if (isFirst == null || isFirst == true) {
      // Mark as not first launch
      await prefs.setBool(_keyIsFirstLaunch, false);
      return true;
    }

    return false;
  }

  /// Get total launch count
  Future<int> getLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLaunchCount) ?? 0;
  }

  /// Increment launch count
  Future<void> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyLaunchCount) ?? 0;
    await prefs.setInt(_keyLaunchCount, currentCount + 1);
  }

  /// Clear session (for testing)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionId);
    _currentSessionId = null;
  }

  /// Clear all analytics data (for testing or user privacy)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keySessionId);
    await prefs.remove(_keyIsFirstLaunch);
    await prefs.remove(_keyLaunchCount);

    _currentSessionId = null;
    _userIdHash = null;
  }
}
