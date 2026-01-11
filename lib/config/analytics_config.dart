/// Analytics configuration
///
/// Update WORKER_URL after deploying Cloudflare Worker
class AnalyticsConfig {
  // TODO: Replace with your deployed Cloudflare Worker URL
  // Example: https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev
  static const String workerUrl = 'YOUR_WORKER_URL_HERE';

  // API Key (from setup)
  static const String apiKey = 'ak_472e76bfc9f5211d6570b3b3746f6603';

  // Event batching configuration
  static const int maxBatchSize = 10; // Send after 10 events
  static const Duration batchInterval = Duration(
    minutes: 5,
  ); // Or send every 5 minutes

  // Network retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Enable/disable analytics (useful for debug builds)
  static const bool enabled = true; // Set to false to disable analytics

  // Debug logging
  static const bool debugMode = false; // Set to true to see analytics logs
}
