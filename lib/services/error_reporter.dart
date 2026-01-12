import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analytics_error.dart';
import '../config/analytics_config.dart';
import 'network_service.dart';
import 'session_manager.dart';

/// Reports errors and crashes to analytics backend
class ErrorReporter {
  static final SessionManager _sessionManager = SessionManager();

  /// Report a Flutter error
  static Future<void> reportFlutterError(FlutterErrorDetails details) async {
    if (!AnalyticsConfig.enabled) return;

    try {
      final sessionId = await _sessionManager.getSessionId();
      final error = AnalyticsError.fromFlutterError(
        sessionId,
        details.exception,
        details.stack,
        context: {
          'library': details.library ?? 'unknown',
          'context': details.context?.toString() ?? 'none',
        },
      );

      await NetworkService.sendError(error);

      if (AnalyticsConfig.debugMode) {
        print('Error reported: ${error.errorType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to report error: $e');
      }
    }
  }

  /// Report a generic exception
  static Future<void> reportException(
    dynamic exception,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) async {
    if (!AnalyticsConfig.enabled) return;

    try {
      final sessionId = await _sessionManager.getSessionId();
      final error = AnalyticsError.fromFlutterError(
        sessionId,
        exception,
        stackTrace,
        context: context,
      );

      await NetworkService.sendError(error);

      if (AnalyticsConfig.debugMode) {
        print('Exception reported: ${error.errorType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to report exception: $e');
      }
    }
  }

  /// Report a custom error
  static Future<void> reportCustomError({
    required String errorType,
    required String errorMessage,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!AnalyticsConfig.enabled) return;

    try {
      final sessionId = await _sessionManager.getSessionId();
      final error = AnalyticsError.custom(
        sessionId,
        errorType: errorType,
        errorMessage: errorMessage,
        stackTrace: stackTrace,
        context: context,
      );

      await NetworkService.sendError(error);

      if (AnalyticsConfig.debugMode) {
        print('Custom error reported: $errorType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to report custom error: $e');
      }
    }
  }

  /// Handle Flutter framework errors
  static void handleFlutterError(FlutterErrorDetails details) {
    // Report to analytics
    reportFlutterError(details);

    // Also report to Flutter's default error handler
    FlutterError.presentError(details);
  }

  /// Setup global error handlers
  static void setupErrorHandlers() {
    // Catch Flutter framework errors
    FlutterError.onError = handleFlutterError;

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      reportException(error, stack, context: {'source': 'platform_dispatcher'});
      return true; // Mark as handled
    };

    if (AnalyticsConfig.debugMode) {
      print('Error handlers initialized');
    }
  }
}
