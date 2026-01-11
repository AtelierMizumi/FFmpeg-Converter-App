/// Error/crash data model
class AnalyticsError {
  final String sessionId;
  final DateTime timestamp;
  final String errorType;
  final String errorMessage;
  final String? stackTrace;
  final Map<String, dynamic>? context;

  AnalyticsError({
    required this.sessionId,
    required this.timestamp,
    required this.errorType,
    required this.errorMessage,
    this.stackTrace,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'error_type': errorType,
      'error_message': errorMessage,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (context != null) 'context': context,
    };
  }

  /// Create from Flutter Error
  factory AnalyticsError.fromFlutterError(
    String sessionId,
    dynamic exception,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    return AnalyticsError(
      sessionId: sessionId,
      timestamp: DateTime.now(),
      errorType: exception.runtimeType.toString(),
      errorMessage: exception.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
    );
  }

  /// Create from generic exception
  factory AnalyticsError.fromException(
    String sessionId,
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AnalyticsError(
      sessionId: sessionId,
      timestamp: DateTime.now(),
      errorType: exception.runtimeType.toString(),
      errorMessage: exception.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
    );
  }

  /// Create custom error
  factory AnalyticsError.custom(
    String sessionId, {
    required String errorType,
    required String errorMessage,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AnalyticsError(
      sessionId: sessionId,
      timestamp: DateTime.now(),
      errorType: errorType,
      errorMessage: errorMessage,
      stackTrace: stackTrace?.toString(),
      context: context,
    );
  }
}
