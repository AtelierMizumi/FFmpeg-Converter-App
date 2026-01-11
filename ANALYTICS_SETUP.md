# Analytics System Setup Guide

Complete guide to deploy and configure your Flutter analytics system.

---

## Overview

Your analytics system is now **100% complete** with:

- **Backend**: Cloudflare Workers API (serverless)
- **Database**: PostgreSQL on Aiven
- **Frontend**: Flutter app with silent analytics
- **Dashboard**: Metabase (to be configured)

**Technology Stack:**
- Cloudflare Workers (Hono framework, TypeScript)
- PostgreSQL 16 (Aiven free tier)
- Flutter 3.10+ (Android, iOS, Linux, Windows, macOS)
- Metabase (open-source BI tool)

---

## Step 1: Database Setup (Aiven PostgreSQL)

### 1.1 Create Aiven Account
1. Go to https://aiven.io
2. Sign up for free account (no credit card required)
3. Create a new PostgreSQL 16 service
   - Region: Choose closest to your users
   - Plan: **Hobbyist** (free, 1GB storage)

### 1.2 Get Connection String
From Aiven console, copy your connection string:
```
postgresql://avnadmin:PASSWORD@HOST:PORT/defaultdb?sslmode=require
```

### 1.3 Run SQL Scripts
Open Aiven web console → **Query Editor**, then run these scripts **in order**:

```bash
# 1. Create tables (sessions, events, errors)
# Copy/paste contents of: database/01_create_tables.sql

# 2. Create indexes for performance
# Copy/paste contents of: database/02_create_indexes.sql

# 3. Create restricted user for Worker
# Copy/paste contents of: database/03_create_user.sql
# Note: Edit password in line 2 before running
```

**Important**: After running `03_create_user.sql`, create a new connection string:
```
postgresql://analytics_worker:YOUR_PASSWORD@HOST:PORT/defaultdb?sslmode=require
```

---

## Step 2: Deploy Cloudflare Worker

### 2.1 Install Prerequisites
```bash
# Install Node.js 18+ (if not installed)
node --version  # Should be 18.x or higher

# Install Wrangler CLI globally
npm install -g wrangler

# Login to Cloudflare
wrangler login
```

### 2.2 Install Dependencies
```bash
cd cloudflare-worker
npm install
```

### 2.3 Configure Secrets
```bash
# Set database connection string (use analytics_worker credentials)
wrangler secret put DATABASE_URL
# Paste: postgresql://analytics_worker:PASSWORD@HOST:PORT/defaultdb?sslmode=require

# Set API key
wrangler secret put API_KEY
# Paste: ak_472e76bfc9f5211d6570b3b3746f6603

# (Optional) Set ipinfo.io token for geolocation
# Sign up at https://ipinfo.io/signup for 50k free requests/month
wrangler secret put IPINFO_TOKEN
# Paste: your_token_here
```

### 2.4 Deploy
```bash
wrangler deploy
```

**Expected output:**
```
✨ Uploaded flutter-analytics-api (X.XX sec)
✨ Published flutter-analytics-api (X.XX sec)
   https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev
```

**SAVE THIS URL** - you'll need it for Flutter configuration.

### 2.5 Test Deployment
```bash
# Health check (no auth required)
curl https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev/health

# Should return:
# {"status":"healthy","timestamp":"...","database":"connected"}
```

---

## Step 3: Configure Flutter App

### 3.1 Update Worker URL
Edit `lib/config/analytics_config.dart`:

```dart
static const String workerUrl = 'https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev';
```

Replace `YOUR_SUBDOMAIN` with your actual Cloudflare subdomain.

### 3.2 Install Dependencies
```bash
flutter pub get
```

### 3.3 (Optional) Enable Debug Mode
To see analytics logs during development:

```dart
// lib/config/analytics_config.dart
static const bool debugMode = true;  // Set to true
```

---

## Step 4: Build & Test Flutter App

### 4.1 Run on Device
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Linux
flutter run -d linux

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

### 4.2 Verify Analytics
When app launches, you should see debug logs (if enabled):
```
Initializing analytics...
✓ Analytics initialized successfully
  Session ID: 123e4567-e89b-12d3-a456-426614174000
  User ID Hash: abc12345...
  First Launch: true
  Launch Count: 1
✓ Session sent successfully
Event queued: app_lifecycle - app_launched (1 in queue)
```

### 4.3 Check Database
Run query in Aiven console:
```sql
SELECT * FROM app_sessions ORDER BY timestamp DESC LIMIT 5;
SELECT * FROM app_events ORDER BY timestamp DESC LIMIT 10;
```

You should see your session and events!

---

## Step 5: Integrate Analytics in Your App

### 5.1 Track Video Conversions
In your video conversion code:

```dart
import 'package:flutter_test_application/services/analytics_service.dart';

// When conversion starts
await AnalyticsService.instance.eventTracker.trackVideoConversionStarted(
  inputFormat: 'avi',
  outputFormat: 'mp4',
  fileSizeMb: 45.6,
);

// When conversion completes
await AnalyticsService.instance.eventTracker.trackVideoConversionCompleted(
  inputFormat: 'avi',
  outputFormat: 'mp4',
  durationSeconds: 120,
  fileSizeMb: 45.6,
  success: true,
);
```

### 5.2 Track Screen Views
```dart
// Track which screens users visit
await AnalyticsService.instance.eventTracker.trackScreenView('converter_tab');
```

### 5.3 Track Button Clicks
```dart
// Track button interactions
await AnalyticsService.instance.eventTracker.trackButtonClick(
  'convert_button',
  extra: {'format': 'mp4'},
);
```

### 5.4 Track File Selection
```dart
await AnalyticsService.instance.eventTracker.trackFileSelected(
  fileType: 'video/avi',
  fileSizeMb: 100.5,
);
```

### 5.5 Track Custom Events
```dart
import 'package:flutter_test_application/models/analytics_event.dart';

final sessionId = await AnalyticsService.instance.getSessionId();
await AnalyticsService.instance.eventTracker.trackEvent(
  AnalyticsEvent(
    sessionId: sessionId,
    eventType: 'custom',
    eventName: 'feature_used',
    timestamp: DateTime.now(),
    properties: {
      'feature_name': 'batch_conversion',
      'file_count': 5,
    },
  ),
);
```

---

## Step 6: Setup Metabase Dashboard

### 6.1 Install Metabase
**Option A: Cloud (Easiest)**
1. Sign up at https://www.metabase.com/start/oss/
2. Free for personal use

**Option B: Self-hosted (Docker)**
```bash
docker run -d -p 3000:3000 \
  -e MB_DB_TYPE=postgres \
  -e MB_DB_DBNAME=defaultdb \
  -e MB_DB_PORT=PORT \
  -e MB_DB_USER=avnadmin \
  -e MB_DB_PASS=PASSWORD \
  -e MB_DB_HOST=HOST \
  metabase/metabase
```

### 6.2 Connect to Database
1. Open Metabase (http://localhost:3000 or cloud URL)
2. Add database:
   - Type: PostgreSQL
   - Host: Your Aiven host
   - Port: Your Aiven port
   - Database: `defaultdb`
   - Username: `avnadmin`
   - Password: Your password
   - SSL: Required

### 6.3 Import Pre-built Queries
Open `database/04_metabase_queries.sql` and create these as saved questions:

**Popular Queries:**
1. **Total Users**: `SELECT COUNT(DISTINCT user_id_hash) FROM app_sessions`
2. **Daily Active Users**: See section "Daily Active Users (DAU)"
3. **Top Devices**: See section "Top Device Models"
4. **Conversion Metrics**: See section "Video Conversion Success Rate"
5. **Crash Rate**: See section "Error Rate by Day"

### 6.4 Create Dashboard
1. Create new dashboard: "FFmpeg Converter Analytics"
2. Add visualizations:
   - Line chart: Daily active users
   - Pie chart: Device brands
   - Bar chart: Top conversion formats
   - Number: Total conversions today
   - Table: Recent errors

---

## Step 7: Troubleshooting

### Analytics not sending data?

**1. Check Worker URL**
```dart
// lib/config/analytics_config.dart
// Make sure this matches your deployed Worker URL
static const String workerUrl = 'https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev';
```

**2. Test Worker health**
```bash
curl https://YOUR-WORKER-URL/health
```

**3. Enable debug mode**
```dart
static const bool debugMode = true;
```

**4. Check Cloudflare logs**
```bash
wrangler tail
```

### "Invalid API key" error?

Verify API key matches:
```bash
# Check Worker secret
wrangler secret list

# Check Flutter config
grep -r "apiKey" lib/config/analytics_config.dart
```

### Database connection failed?

1. Verify connection string has `?sslmode=require`
2. Check Aiven service is running (not paused)
3. Test connection:
   ```bash
   psql "postgresql://analytics_worker:PASSWORD@HOST:PORT/defaultdb?sslmode=require"
   ```

### Events not appearing in database?

Events are batched! They send when:
- Queue reaches 10 events, OR
- 5 minutes elapse, OR
- App is paused/closed

Force flush for testing:
```dart
await AnalyticsService.instance.eventTracker.flush();
```

---

## Step 8: Production Checklist

Before releasing to production:

### Security
- [ ] Change API key in `lib/config/analytics_config.dart`
- [ ] Update Worker secret: `wrangler secret put API_KEY`
- [ ] Use restricted database user (`analytics_worker`, not `avnadmin`)
- [ ] Verify SSL is enabled (`?sslmode=require`)

### Performance
- [ ] Adjust batch size if needed (default: 10 events)
- [ ] Configure Cloudflare rate limits (Workers dashboard)
- [ ] Add indexes to frequently queried columns

### Privacy
- [ ] Review data collection in `device_info_service.dart`
- [ ] Ensure all IDs are hashed (SHA256)
- [ ] Add privacy policy to your app
- [ ] Comply with GDPR/CCPA if applicable

### Monitoring
- [ ] Setup Cloudflare email alerts for Worker errors
- [ ] Monitor Aiven storage usage
- [ ] Check ipinfo.io quota (50k/month free)
- [ ] Setup UptimeRobot for `/health` endpoint

### Disable Analytics (if needed)
```dart
// lib/config/analytics_config.dart
static const bool enabled = false;  // Disables all tracking
```

---

## Architecture Reference

```
┌─────────────────┐
│  Flutter App    │
│  (Android/iOS/  │
│   Desktop)      │
└────────┬────────┘
         │ HTTPS POST
         │ (session/events/errors)
         ▼
┌─────────────────┐
│ Cloudflare      │
│ Worker          │
│ (Hono API)      │
└────────┬────────┘
         │ PostgreSQL
         │ (SSL)
         ▼
┌─────────────────┐      ┌─────────────────┐
│ Aiven           │◄─────┤ Metabase        │
│ PostgreSQL      │ SQL  │ Dashboard       │
│ (Database)      │      │ (Visualization) │
└─────────────────┘      └─────────────────┘
         ▲
         │ IP Geolocation
         │ (Optional)
┌─────────────────┐
│ ipinfo.io       │
└─────────────────┘
```

---

## API Reference

### Endpoints

**POST /api/session**
- Creates new session with device/OS/app data
- Auth: API key required
- Returns: `{success: true, session_id: "uuid"}`

**POST /api/events**
- Batch upload events
- Auth: API key required
- Body: `{session_id: "uuid", events: [...]}`
- Returns: `{success: true, recorded: 10}`

**POST /api/errors**
- Report crash/error
- Auth: API key required
- Body: `{session_id: "uuid", error_type: "...", ...}`
- Returns: `{success: true}`

**GET /health**
- Health check (no auth)
- Returns: `{status: "healthy", database: "connected"}`

---

## Cost Breakdown

| Service | Free Tier | Expected Usage | Monthly Cost |
|---------|-----------|----------------|--------------|
| Cloudflare Workers | 100k requests/day | ~1k/day | $0 |
| Aiven PostgreSQL | 1GB storage | ~100MB | $0 |
| ipinfo.io | 50k requests/month | ~1k/month | $0 |
| Metabase Cloud | N/A | Self-hosted | $0 |
| **TOTAL** | - | - | **$0/month** |

---

## Support & Resources

- **Cloudflare Workers**: https://developers.cloudflare.com/workers/
- **Aiven PostgreSQL**: https://docs.aiven.io/
- **Flutter Packages**: https://pub.dev
- **Metabase Docs**: https://www.metabase.com/docs/

---

## What's Next?

1. **Deploy Worker** → Test with Flutter app
2. **Run SQL scripts** → Setup database tables
3. **Configure Flutter** → Update Worker URL
4. **Add tracking** → Instrument video conversions
5. **Setup Metabase** → Create dashboards
6. **Monitor** → Watch your analytics grow!

**Estimated setup time**: 30-45 minutes

---

Last updated: January 11, 2026
