import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/analytics_config.dart';
import '../models/analytics_session.dart';
import '../models/analytics_event.dart';
import '../models/analytics_error.dart';

/// Network service for sending analytics data to Cloudflare Worker
class NetworkService {
  static final http.Client _client = http.Client();

  /// Send session data to backend
  static Future<bool> sendSession(AnalyticsSession session) async {
    if (!AnalyticsConfig.enabled) return false;

    try {
      final response = await _retryRequest(() async {
        return await _client.post(
          Uri.parse('${AnalyticsConfig.workerUrl}/api/session'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AnalyticsConfig.apiKey,
          },
          body: jsonEncode(session.toJson()),
        );
      });

      if (response.statusCode == 201) {
        if (AnalyticsConfig.debugMode) {
          print('✓ Session sent successfully');
        }
        return true;
      } else {
        if (AnalyticsConfig.debugMode) {
          print('✗ Session failed: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (AnalyticsConfig.debugMode) {
        print('✗ Session error: $e');
      }
      return false;
    }
  }

  /// Send batch of events to backend
  static Future<bool> sendEvents(
    String sessionId,
    List<AnalyticsEvent> events,
  ) async {
    if (!AnalyticsConfig.enabled || events.isEmpty) return false;

    try {
      final payload = {
        'session_id': sessionId,
        'events': events.map((e) => e.toJson()).toList(),
      };

      final response = await _retryRequest(() async {
        return await _client.post(
          Uri.parse('${AnalyticsConfig.workerUrl}/api/events'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AnalyticsConfig.apiKey,
          },
          body: jsonEncode(payload),
        );
      });

      if (response.statusCode == 201 || response.statusCode == 207) {
        if (AnalyticsConfig.debugMode) {
          print('✓ Events sent successfully (${events.length} events)');
        }
        return true;
      } else {
        if (AnalyticsConfig.debugMode) {
          print('✗ Events failed: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (AnalyticsConfig.debugMode) {
        print('✗ Events error: $e');
      }
      return false;
    }
  }

  /// Send error data to backend
  static Future<bool> sendError(AnalyticsError error) async {
    if (!AnalyticsConfig.enabled) return false;

    try {
      final response = await _retryRequest(() async {
        return await _client.post(
          Uri.parse('${AnalyticsConfig.workerUrl}/api/errors'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': AnalyticsConfig.apiKey,
          },
          body: jsonEncode(error.toJson()),
        );
      });

      if (response.statusCode == 201) {
        if (AnalyticsConfig.debugMode) {
          print('✓ Error sent successfully');
        }
        return true;
      } else {
        if (AnalyticsConfig.debugMode) {
          print('✗ Error failed: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (AnalyticsConfig.debugMode) {
        print('✗ Error sending error: $e');
      }
      return false;
    }
  }

  /// Retry logic with exponential backoff
  static Future<http.Response> _retryRequest(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    Duration delay = AnalyticsConfig.retryDelay;

    while (attempts < AnalyticsConfig.maxRetries) {
      try {
        final response = await request().timeout(const Duration(seconds: 10));

        // Success or non-retryable error
        if (response.statusCode < 500) {
          return response;
        }

        // Server error - retry
        attempts++;
        if (attempts < AnalyticsConfig.maxRetries) {
          await Future.delayed(delay);
          delay *= 2; // Exponential backoff
        }
      } catch (e) {
        attempts++;
        if (attempts >= AnalyticsConfig.maxRetries) {
          rethrow;
        }
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Test connection to backend
  static Future<bool> testConnection() async {
    try {
      final response = await _client
          .get(Uri.parse('${AnalyticsConfig.workerUrl}/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Connection test failed: $e');
      }
      return false;
    }
  }
}
