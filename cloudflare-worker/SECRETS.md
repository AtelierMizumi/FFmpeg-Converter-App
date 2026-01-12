# 🔐 GitHub Secrets Quick Reference

Copy and paste these values into your GitHub repository secrets.

**Location:** `Your Repo → Settings → Secrets and variables → Actions → New repository secret`

---

## 1. CLOUDFLARE_API_TOKEN

**Get it from:** https://dash.cloudflare.com/profile/api-tokens

1. Create Token → Edit Cloudflare Workers template
2. Copy the generated token
3. Add to GitHub with name: `CLOUDFLARE_API_TOKEN`

---

## 2. CLOUDFLARE_ACCOUNT_ID

**Value:**
```
f8d5077fe73cda5d916fd3f159036e7e
```
*(or run `wrangler whoami` to get your account ID)*

---

## 3. DATABASE_URL

**Value:**
```
postgresql://neondb_owner:npg_W9uh5LAngdzX@ep-lucky-haze-a11vt3gu-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

---

## 4. API_KEY

**Value:**
```
QoaTvd5X4wOPlHttsgNAaIBaxk9OsW99D_HZlNJA
```

---

## ✅ Verification

After adding all 4 secrets, go to:
- **Actions** tab
- Click **"Deploy Cloudflare Worker"**
- Click **"Run workflow"**
- Watch it deploy!

---

## 🎯 Expected Result

After successful deployment:
```bash
curl https://flutter-analytics-api.thuanc177.workers.dev/health
```

Should return:
```json
{
  "status": "healthy",
  "timestamp": "2026-01-12T...",
  "database": "connected"
}
```
