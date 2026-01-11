# Analytics System - Quick Start

## 🚀 Setup Steps (30 minutes)

### 1. Database (Aiven) - 5 min
```bash
# Sign up at aiven.io → Create PostgreSQL service
# Run SQL scripts in order:
database/01_create_tables.sql
database/02_create_indexes.sql
database/03_create_user.sql  # Edit password first!
```

### 2. Deploy Worker - 10 min
```bash
cd cloudflare-worker
npm install
wrangler login
wrangler secret put DATABASE_URL    # analytics_worker connection string
wrangler secret put API_KEY         # ak_472e76bfc9f5211d6570b3b3746f6603
wrangler deploy
# ✓ Save the Worker URL!
```

### 3. Configure Flutter - 5 min
```dart
// lib/config/analytics_config.dart
static const String workerUrl = 'https://YOUR-WORKER-URL';
```
```bash
flutter pub get
```

### 4. Test - 5 min
```bash
flutter run
# Check logs for: "✓ Analytics initialized successfully"
# Verify in Aiven: SELECT * FROM app_sessions;
```

### 5. Setup Metabase - 5 min
```bash
# Use database/04_metabase_queries.sql
# Create dashboard with DAU, devices, conversions
```

---

## 📊 Tracking Code Examples

### Video Conversion
```dart
import 'package:flutter_test_application/services/analytics_service.dart';

// Start
await AnalyticsService.instance.eventTracker.trackVideoConversionStarted(
  inputFormat: 'avi',
  outputFormat: 'mp4',
  fileSizeMb: 45.6,
);

// Complete
await AnalyticsService.instance.eventTracker.trackVideoConversionCompleted(
  inputFormat: 'avi',
  outputFormat: 'mp4',
  durationSeconds: 120,
  fileSizeMb: 45.6,
  success: true,
);
```

### Screen Views
```dart
await AnalyticsService.instance.eventTracker.trackScreenView('converter_tab');
```

### Button Clicks
```dart
await AnalyticsService.instance.eventTracker.trackButtonClick('convert_button');
```

---

## 🔧 Troubleshooting

### Not sending data?
1. Check Worker URL in `lib/config/analytics_config.dart`
2. Enable debug: `debugMode = true`
3. Test health: `curl YOUR-WORKER-URL/health`
4. Check logs: `wrangler tail`

### Invalid API key?
```bash
wrangler secret list  # Verify API_KEY exists
```

### Database error?
- Verify connection string has `?sslmode=require`
- Check Aiven service is running
- Use `analytics_worker` user, not `avnadmin`

---

## 📁 File Structure

```
flutter_test_application/
├── database/                  # SQL scripts (run in Aiven)
│   ├── 01_create_tables.sql
│   ├── 02_create_indexes.sql
│   ├── 03_create_user.sql
│   └── 04_metabase_queries.sql
├── cloudflare-worker/         # Backend API
│   ├── src/
│   │   ├── index.ts          # Main router
│   │   ├── handlers/         # Endpoint handlers
│   │   ├── services/         # DB, validation, geo
│   │   └── types/            # TypeScript types
│   ├── package.json
│   ├── wrangler.toml
│   └── README.md
└── lib/
    ├── config/
    │   └── analytics_config.dart      # Worker URL, API key
    ├── models/
    │   ├── analytics_session.dart
    │   ├── analytics_event.dart
    │   └── analytics_error.dart
    ├── services/
    │   ├── analytics_service.dart     # Main orchestrator
    │   ├── device_info_service.dart   # Collect device data
    │   ├── session_manager.dart       # Session & user IDs
    │   ├── network_service.dart       # HTTP client
    │   ├── event_tracker.dart         # Batch events
    │   └── error_reporter.dart        # Crash reporting
    ├── utils/
    │   └── crypto_utils.dart          # SHA256 hashing
    └── main.dart                       # ✓ Analytics initialized
```

---

## 🎯 What Gets Tracked

**Automatically:**
- Device: model, brand, OS, screen size
- App: version, launches, first install
- Network: WiFi/Mobile/None
- Location: Country/city (from IP)
- Crashes: Stack traces

**Manually (add code):**
- Video conversions
- Screen views
- Button clicks
- File selections
- Custom events

---

## 💰 Cost: $0/month

- Cloudflare Workers: Free tier (100k req/day)
- Aiven PostgreSQL: Free tier (1GB)
- ipinfo.io: Free tier (50k req/month)

---

## 🔐 Security Checklist

- [x] All IDs are SHA256 hashed
- [x] API key authentication
- [x] SSL/TLS encryption
- [x] Restricted database user
- [x] No PII collected
- [ ] Update API key before production
- [ ] Add privacy policy to app

---

## 📞 Quick Commands

```bash
# Deploy Worker
cd cloudflare-worker && wrangler deploy

# View Worker logs
wrangler tail

# Test health
curl https://YOUR-WORKER-URL/health

# Check database
psql "postgresql://analytics_worker:PASSWORD@HOST:PORT/defaultdb?sslmode=require"

# Flutter run
flutter pub get && flutter run

# Force flush events (testing)
await AnalyticsService.instance.eventTracker.flush();
```

---

**Full Guide**: See `ANALYTICS_SETUP.md`
