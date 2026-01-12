/// Event data model
class AnalyticsEvent {
  final String sessionId;
  final String eventType;
  final String eventName;
  final DateTime timestamp;
  final Map<String, dynamic>? properties;

  AnalyticsEvent({
    required this.sessionId,
    required this.eventType,
    required this.eventName,
    required this.timestamp,
    this.properties,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'event_type': eventType,
      'event_name': eventName,
      'timestamp': timestamp.toIso8601String(),
      if (properties != null) 'properties': properties,
    };
  }
}

/// Predefined event types for common actions
class EventType {
  static const String appLifecycle = 'app_lifecycle';
  static const String navigation = 'navigation';
  static const String videoConversion = 'video_conversion';
  static const String userAction = 'user_action';
  static const String performance = 'performance';
}

/// Helper methods to create common events
extension AnalyticsEventHelpers on AnalyticsEvent {
  /// Track app launch
  static AnalyticsEvent appLaunch(String sessionId) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.appLifecycle,
      eventName: 'app_launched',
      timestamp: DateTime.now(),
    );
  }

  /// Track app resume from background
  static AnalyticsEvent appResumed(String sessionId) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.appLifecycle,
      eventName: 'app_resumed',
      timestamp: DateTime.now(),
    );
  }

  /// Track app paused (backgrounded)
  static AnalyticsEvent appPaused(String sessionId) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.appLifecycle,
      eventName: 'app_paused',
      timestamp: DateTime.now(),
    );
  }

  /// Track screen view
  static AnalyticsEvent screenView(String sessionId, String screenName) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.navigation,
      eventName: 'screen_view',
      timestamp: DateTime.now(),
      properties: {'screen_name': screenName},
    );
  }

  /// Track video conversion started
  static AnalyticsEvent videoConversionStarted(
    String sessionId, {
    required String inputFormat,
    required String outputFormat,
    double? fileSizeMb,
  }) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.videoConversion,
      eventName: 'conversion_started',
      timestamp: DateTime.now(),
      properties: {
        'input_format': inputFormat,
        'output_format': outputFormat,
        if (fileSizeMb != null) 'file_size_mb': fileSizeMb,
      },
    );
  }

  /// Track video conversion completed
  static AnalyticsEvent videoConversionCompleted(
    String sessionId, {
    required String inputFormat,
    required String outputFormat,
    required int durationSeconds,
    required double fileSizeMb,
    required bool success,
    String? errorMessage,
  }) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.videoConversion,
      eventName: 'conversion_completed',
      timestamp: DateTime.now(),
      properties: {
        'input_format': inputFormat,
        'output_format': outputFormat,
        'duration_seconds': durationSeconds,
        'file_size_mb': fileSizeMb,
        'success': success,
        if (errorMessage != null) 'error_message': errorMessage,
      },
    );
  }

  /// Track button click
  static AnalyticsEvent buttonClick(
    String sessionId,
    String buttonName, {
    Map<String, dynamic>? extra,
  }) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.userAction,
      eventName: 'button_click',
      timestamp: DateTime.now(),
      properties: {'button_name': buttonName, if (extra != null) ...extra},
    );
  }

  /// Track file selected
  static AnalyticsEvent fileSelected(
    String sessionId, {
    required String fileType,
    required double fileSizeMb,
  }) {
    return AnalyticsEvent(
      sessionId: sessionId,
      eventType: EventType.userAction,
      eventName: 'file_selected',
      timestamp: DateTime.now(),
      properties: {'file_type': fileType, 'file_size_mb': fileSizeMb},
    );
  }
}
