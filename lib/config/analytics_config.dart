import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnalyticsConfig {
  static const bool enabled = true;
  static const bool debugMode = true;
  static const int maxBatchSize = 10;
  static const Duration batchInterval = Duration(seconds: 30);

  static String get workerUrl {
    // Priority: 1. Build environment variable (dart-define) 2. .env file 3. Default
    const envUrl = String.fromEnvironment('ANALYTICS_WORKER_URL');
    if (envUrl.isNotEmpty) return envUrl;

    return dotenv.env['ANALYTICS_WORKER_URL'] ??
        'https://ffmpeg-analytics-worker.thuanc177.workers.dev';
  }

  static String get apiKey {
    // Priority: 1. Build environment variable (dart-define) 2. .env file 3. Default
    const envKey = String.fromEnvironment('ANALYTICS_API_KEY');
    if (envKey.isNotEmpty) return envKey;

    return dotenv.env['ANALYTICS_API_KEY'] ?? 'your-api-key';
  }

  static const Duration retryDelay = Duration(seconds: 5);
  static const int maxRetries = 3;
}
