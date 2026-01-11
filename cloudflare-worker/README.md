# Flutter Analytics API - Cloudflare Worker

Backend API for collecting analytics data from Flutter app. Runs on Cloudflare Workers (serverless) and stores data in PostgreSQL (Aiven).

## Architecture

```
Flutter App → Cloudflare Worker → PostgreSQL (Aiven) → Metabase
```

## Features

- **Session tracking**: Device info, OS, app version, network, locale, performance
- **Event tracking**: Batch processing for feature usage, video conversions, screen views
- **Error tracking**: Crash logs with stack traces
- **Geolocation enrichment**: IP → city-level location via ipinfo.io
- **API key authentication**: Secure endpoints
- **CORS enabled**: Accept requests from any origin
- **Health checks**: Monitor database connectivity

## Prerequisites

1. **Cloudflare account** (free tier)
2. **Aiven PostgreSQL database** (free tier 1GB)
3. **Wrangler CLI** installed: `npm install -g wrangler`
4. **Node.js** 18+ and npm

## Setup Instructions

### 1. Database Setup

Run these SQL scripts in your Aiven console (in order):

```bash
# 1. Create tables
database/01_create_tables.sql

# 2. Create indexes
database/02_create_indexes.sql

# 3. Create restricted user (for Worker access)
database/03_create_user.sql
```

Get your **connection string** from Aiven dashboard:
```
postgresql://analytics_worker:PASSWORD@HOST:PORT/defaultdb?sslmode=require
```

### 2. Install Dependencies

```bash
cd cloudflare-worker
npm install
```

### 3. Configure Secrets

Set environment variables using Wrangler:

```bash
# Required: Database connection string
wrangler secret put DATABASE_URL
# Paste: postgresql://analytics_worker:PASSWORD@HOST:PORT/defaultdb?sslmode=require

# Required: API key (use the one from previous session)
wrangler secret put API_KEY
# Paste: ak_472e76bfc9f5211d6570b3b3746f6603

# Optional: ipinfo.io token (free tier: 50k requests/month)
# Sign up at https://ipinfo.io/signup
wrangler secret put IPINFO_TOKEN
# Paste: your_ipinfo_token
```

### 4. Deploy to Cloudflare

```bash
wrangler deploy
```

Expected output:
```
Total Upload: XX.XX KiB / gzip: XX.XX KiB
Deployed flutter-analytics-api triggers (1.XX sec)
  https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev
```

**Save this URL** - you'll need it for Flutter app configuration.

### 5. Test the Deployment

```bash
# Health check (no auth)
curl https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev/health

# Test session endpoint
curl -X POST https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev/api/session \
  -H "Content-Type: application/json" \
  -H "Authorization: ak_472e76bfc9f5211d6570b3b3746f6603" \
  -d '{
    "session_id": "123e4567-e89b-12d3-a456-426614174000",
    "user_id_hash": "abc123def456",
    "timestamp": "2026-01-11T10:00:00Z",
    "device_model": "Pixel 7",
    "os_name": "Android",
    "os_version": "14",
    "app_version": "1.0.0"
  }'
```

Expected response:
```json
{
  "success": true,
  "session_id": "123e4567-e89b-12d3-a456-426614174000",
  "message": "Session recorded successfully"
}
```

## API Endpoints

### Health Check
```
GET /health
```
No authentication required. Returns database status.

### Record Session
```
POST /api/session
Authorization: ak_472e76bfc9f5211d6570b3b3746f6603
Content-Type: application/json
```

**Body**: See `src/types/index.ts` for `SessionData` interface

### Record Events (Batch)
```
POST /api/events
Authorization: ak_472e76bfc9f5211d6570b3b3746f6603
Content-Type: application/json
```

**Body**:
```json
{
  "session_id": "uuid",
  "events": [
    {
      "session_id": "uuid",
      "event_type": "video_conversion",
      "event_name": "conversion_started",
      "timestamp": "2026-01-11T10:00:00Z",
      "properties": {
        "input_format": "avi",
        "output_format": "mp4"
      }
    }
  ]
}
```

### Record Error
```
POST /api/errors
Authorization: ak_472e76bfc9f5211d6570b3b3746f6603
Content-Type: application/json
```

**Body**:
```json
{
  "session_id": "uuid",
  "timestamp": "2026-01-11T10:00:00Z",
  "error_type": "Exception",
  "error_message": "Video conversion failed",
  "stack_trace": "...",
  "context": {
    "file": "converter.dart",
    "line": 42
  }
}
```

## Development

### Local Development

```bash
# Run locally with Miniflare
wrangler dev

# Test with local database
wrangler dev --local
```

### View Logs

```bash
wrangler tail
```

### Update Secrets

```bash
wrangler secret put API_KEY
```

### Delete Secret

```bash
wrangler secret delete IPINFO_TOKEN
```

## Configuration

### wrangler.toml

- `name`: Worker name (must be unique in your account)
- `compatibility_date`: Cloudflare runtime compatibility
- `node_compat`: Enable Node.js APIs for database driver

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `API_KEY` | Yes | API key for authentication |
| `IPINFO_TOKEN` | No | ipinfo.io token (falls back to Cloudflare headers) |

## Security

- **API Key**: All endpoints under `/api/*` require authorization header
- **CORS**: Enabled for all origins (analytics use case)
- **SQL Injection**: Protected by parameterized queries
- **Rate Limiting**: Use Cloudflare dashboard to add rate limits if needed
- **Database User**: Restricted permissions (no DDL, only INSERT)

## Monitoring

### Cloudflare Dashboard

1. Go to **Workers & Pages** → Select your worker
2. View metrics: Requests, errors, CPU time, duration
3. Set up alerts for error rates

### Health Check Endpoint

Monitor `/health` endpoint with uptime monitoring (e.g., UptimeRobot):
```
GET https://flutter-analytics-api.YOUR_SUBDOMAIN.workers.dev/health
```

## Troubleshooting

### "Invalid API key" error
- Verify API key with `wrangler secret list`
- Check Authorization header format: `Authorization: YOUR_API_KEY`

### "Database connection failed"
- Verify DATABASE_URL secret is set correctly
- Check Aiven database is running (not paused)
- Verify connection string has `?sslmode=require`

### Geolocation not working
- Check if IPINFO_TOKEN is set (optional)
- Verify ipinfo.io quota (50k/month free tier)
- Falls back to Cloudflare CF-IPCountry header

### Worker not deploying
- Run `wrangler whoami` to verify authentication
- Check `wrangler.toml` syntax
- Ensure worker name is unique in your account

## Cost Estimate

**Free Tier Limits:**

| Service | Free Tier | Expected Usage | Cost |
|---------|-----------|----------------|------|
| Cloudflare Workers | 100k requests/day | ~1k/day | $0 |
| Aiven PostgreSQL | 1GB storage | ~100MB | $0 |
| ipinfo.io | 50k requests/month | ~1k/month | $0 |

**Total Monthly Cost**: $0 (within free tiers)

## Next Steps

1. **Flutter Integration**: Update Flutter app with Worker URL
2. **Metabase Setup**: Connect to Aiven database, import queries from `database/04_metabase_queries.sql`
3. **Custom Domain** (optional): Add custom domain in Cloudflare dashboard

## Support

- Cloudflare Workers Docs: https://developers.cloudflare.com/workers/
- Wrangler CLI Docs: https://developers.cloudflare.com/workers/wrangler/
- Aiven Docs: https://docs.aiven.io/

## License

MIT
