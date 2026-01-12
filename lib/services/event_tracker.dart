import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/analytics_config.dart';
import '../models/analytics_event.dart';
import 'network_service.dart';
import 'session_manager.dart';

/// Tracks events and batches them for efficient sending
class EventTracker {
  static final EventTracker _instance = EventTracker._internal();
  factory EventTracker() => _instance;
  EventTracker._internal();

  final List<AnalyticsEvent> _eventQueue = [];
  Timer? _batchTimer;
  final SessionManager _sessionManager = SessionManager();

  /// Initialize event tracker with batch timer
  void initialize() {
    _startBatchTimer();
  }

  /// Track a custom event
  Future<void> trackEvent(AnalyticsEvent event) async {
    if (!AnalyticsConfig.enabled) return;

    _eventQueue.add(event);

    if (AnalyticsConfig.debugMode) {
      print(
        'Event queued: ${event.eventType} - ${event.eventName} (${_eventQueue.length} in queue)',
      );
    }

    // Send immediately if batch size reached
    if (_eventQueue.length >= AnalyticsConfig.maxBatchSize) {
      await _flushEvents();
    }
  }

  /// Track app lifecycle events
  Future<void> trackAppLaunched() async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(AnalyticsEventHelpers.appLaunch(sessionId));
  }

  Future<void> trackAppResumed() async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(AnalyticsEventHelpers.appResumed(sessionId));
  }

  Future<void> trackAppPaused() async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(AnalyticsEventHelpers.appPaused(sessionId));
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(AnalyticsEventHelpers.screenView(sessionId, screenName));
  }

  /// Track video conversion started
  Future<void> trackVideoConversionStarted({
    required String inputFormat,
    required String outputFormat,
    double? fileSizeMb,
  }) async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(
      AnalyticsEventHelpers.videoConversionStarted(
        sessionId,
        inputFormat: inputFormat,
        outputFormat: outputFormat,
        fileSizeMb: fileSizeMb,
      ),
    );
  }

  /// Track video conversion completed
  Future<void> trackVideoConversionCompleted({
    required String inputFormat,
    required String outputFormat,
    required int durationSeconds,
    required double fileSizeMb,
    required bool success,
    String? errorMessage,
  }) async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(
      AnalyticsEventHelpers.videoConversionCompleted(
        sessionId,
        inputFormat: inputFormat,
        outputFormat: outputFormat,
        durationSeconds: durationSeconds,
        fileSizeMb: fileSizeMb,
        success: success,
        errorMessage: errorMessage,
      ),
    );
  }

  /// Track button click
  Future<void> trackButtonClick(
    String buttonName, {
    Map<String, dynamic>? extra,
  }) async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(
      AnalyticsEventHelpers.buttonClick(sessionId, buttonName, extra: extra),
    );
  }

  /// Track file selected
  Future<void> trackFileSelected({
    required String fileType,
    required double fileSizeMb,
  }) async {
    final sessionId = await _sessionManager.getSessionId();
    await trackEvent(
      AnalyticsEventHelpers.fileSelected(
        sessionId,
        fileType: fileType,
        fileSizeMb: fileSizeMb,
      ),
    );
  }

  /// Start batch timer
  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(AnalyticsConfig.batchInterval, (_) {
      _flushEvents();
    });
  }

  /// Send all queued events
  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;

    // Copy events and clear queue
    final eventsToSend = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();

    try {
      final sessionId = await _sessionManager.getSessionId();
      final success = await NetworkService.sendEvents(sessionId, eventsToSend);

      if (!success) {
        // Re-queue events on failure (with limit to prevent infinite growth)
        if (_eventQueue.length < 100) {
          _eventQueue.addAll(eventsToSend);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error flushing events: $e');
      }
      // Re-queue on error
      if (_eventQueue.length < 100) {
        _eventQueue.addAll(eventsToSend);
      }
    }
  }

  /// Force flush all events (call on app pause/terminate)
  Future<void> flush() async {
    await _flushEvents();
  }

  /// Get current queue size
  int get queueSize => _eventQueue.length;

  /// Dispose resources
  void dispose() {
    _batchTimer?.cancel();
    _eventQueue.clear();
  }
}
