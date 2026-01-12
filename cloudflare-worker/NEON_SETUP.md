# Neon Setup Instructions

## What Changed

We've switched from Aiven PostgreSQL to Neon, which is specifically designed for serverless and edge environments like Cloudflare Workers.

**Benefits of Neon:**
- ✅ HTTP-based driver that works perfectly with Cloudflare Workers
- ✅ No SSL certificate issues
- ✅ Built-in connection pooling
- ✅ Automatic scaling and sleep when idle (generous free tier)
- ✅ Fast cold starts

## Setup Steps

### 1. Create a Neon Account

1. Go to https://console.neon.tech
2. Sign up for a free account (no credit card required)
3. Create a new project

### 2. Create the Database Tables

Once your Neon project is created:

1. Go to the **SQL Editor** in the Neon console
2. Run the schema creation script (located in `cloudflare-worker/schema.sql` or wherever you have it)

Alternatively, if you have an existing Aiven database you want to migrate:

```bash
# Export from Aiven
pg_dump $AIVEN_DATABASE_URL > backup.sql

# Import to Neon
psql $NEON_DATABASE_URL < backup.sql
```

### 3. Get Your Connection String

1. In the Neon console, go to your project dashboard
2. Click on **Connection Details**
3. **IMPORTANT:** Use the **"Pooled connection"** string (not the direct connection)
   - The pooled connection URL will look like: `postgres://user:pass@ep-xxx-pooler.region.aws.neon.tech/dbname`
   - Notice the `-pooler` in the hostname

### 4. Update Local Development

Edit `cloudflare-worker/.dev.vars`:

```env
DATABASE_URL="YOUR_NEON_POOLED_CONNECTION_STRING"
API_KEY="QoaTvd5X4wOPlHttsgNAaIBaxk9OsW99D_HZlNJA"
```

### 5. Test Locally

```bash
cd cloudflare-worker
npm run dev

# In another terminal:
curl http://localhost:8787/health
```

You should see:
```json
{
  "status": "healthy",
  "timestamp": "2026-01-12T...",
  "database": "connected"
}
```

### 6. Deploy to Production

Update the DATABASE_URL secret in Cloudflare:

```bash
cd cloudflare-worker

# Set the new Neon connection string
echo "YOUR_NEON_POOLED_CONNECTION_STRING" | wrangler secret put DATABASE_URL

# Deploy
wrangler deploy

# Test
curl https://flutter-analytics-api.thuanc177.workers.dev/health
```

## Troubleshooting

### "Failed to connect"
- Make sure you're using the **pooled connection** string (has `-pooler` in hostname)
- Verify the connection string is correct in `.dev.vars` or Cloudflare secrets

### "Table does not exist"
- Run the schema creation script in the Neon SQL Editor
- Make sure you're connected to the correct database

### "Permission denied"
- Check that your Neon database user has the necessary permissions
- The default Neon user should have full access

## Code Changes Summary

- ❌ Removed: `postgres` package (postgres.js)
- ✅ Added: `@neondatabase/serverless`
- ❌ Removed: All CA certificate handling code
- ✅ Simplified: Database service now uses Neon's HTTP-based driver
- ✅ Kept: All the same API endpoints and functionality

The migration is complete! Just update your DATABASE_URL and you're ready to go.
