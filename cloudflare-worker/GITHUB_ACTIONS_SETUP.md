# GitHub Actions Setup for Cloudflare Worker Deployment

## Overview

This guide will help you set up automatic deployment of your Cloudflare Worker whenever you push code to the `main` branch.

## Required GitHub Secrets

You need to add the following secrets to your GitHub repository:

### 1. CLOUDFLARE_API_TOKEN

**What it is:** An API token that allows GitHub Actions to deploy to your Cloudflare account.

**How to get it:**

1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click **"Create Token"**
3. Click **"Use template"** next to **"Edit Cloudflare Workers"**
4. Configure the token:
   - **Token name:** `GitHub Actions Worker Deploy`
   - **Permissions:** 
     - Account / Workers Scripts / Edit
     - Account / Workers KV Storage / Edit (optional)
   - **Account Resources:**
     - Include / Your Account (select your account)
   - **Zone Resources:** All zones (or specific zones if preferred)
5. Click **"Continue to summary"** → **"Create Token"**
6. **IMPORTANT:** Copy the token immediately (you won't see it again!)

**Add to GitHub:**
1. Go to your GitHub repo: `Settings` → `Secrets and variables` → `Actions`
2. Click **"New repository secret"**
3. Name: `CLOUDFLARE_API_TOKEN`
4. Value: Paste the token you copied
5. Click **"Add secret"**

---

### 2. CLOUDFLARE_ACCOUNT_ID

**What it is:** Your Cloudflare account ID.

**How to get it:**

1. Go to https://dash.cloudflare.com
2. Select any website or go to Workers & Pages
3. Look at the URL or the right sidebar
4. Your Account ID is shown there (format: `f8d5077fe73cda5d916fd3f159036e7e`)

**Or get it from command line:**
```bash
wrangler whoami
```
Look for the "Account ID" column in the output.

**Add to GitHub:**
1. Go to your GitHub repo: `Settings` → `Secrets and variables` → `Actions`
2. Click **"New repository secret"**
3. Name: `CLOUDFLARE_ACCOUNT_ID`
4. Value: Your account ID
5. Click **"Add secret"**

---

### 3. DATABASE_URL

**What it is:** Your Neon PostgreSQL connection string.

**Value:**
```
postgresql://neondb_owner:npg_W9uh5LAngdzX@ep-lucky-haze-a11vt3gu-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

**Add to GitHub:**
1. Go to your GitHub repo: `Settings` → `Secrets and variables` → `Actions`
2. Click **"New repository secret"**
3. Name: `DATABASE_URL`
4. Value: The connection string above
5. Click **"Add secret"**

---

### 4. API_KEY

**What it is:** The authentication key your Flutter app uses to connect to the worker.

**Value:**
```
QoaTvd5X4wOPlHttsgNAaIBaxk9OsW99D_HZlNJA
```

**Add to GitHub:**
1. Go to your GitHub repo: `Settings` → `Secrets and variables` → `Actions`
2. Click **"New repository secret"**
3. Name: `API_KEY`
4. Value: The API key above
5. Click **"Add secret"**

---

## Summary of Required Secrets

| Secret Name | Description | Where to Get It |
|-------------|-------------|-----------------|
| `CLOUDFLARE_API_TOKEN` | API token for deployment | Cloudflare Dashboard → Profile → API Tokens |
| `CLOUDFLARE_ACCOUNT_ID` | Your Cloudflare account ID | Cloudflare Dashboard or `wrangler whoami` |
| `DATABASE_URL` | Neon PostgreSQL connection string | Already set up (see above) |
| `API_KEY` | Flutter app authentication key | Already set up (see above) |

---

## How the Workflow Works

The workflow (`.github/workflows/deploy-worker.yml`) will:

1. **Trigger on:**
   - Push to `main` branch
   - Changes to files in `cloudflare-worker/` directory
   - Manual trigger via GitHub Actions UI

2. **Steps:**
   - Check out your code
   - Set up Node.js environment
   - Install dependencies (`npm ci`)
   - Deploy to Cloudflare Workers using `wrangler`
   - Update secrets (DATABASE_URL, API_KEY)
   - Test the deployment by hitting the `/health` endpoint

3. **Result:**
   - Your worker is automatically deployed
   - You'll see deployment status in the Actions tab
   - If successful, changes are live at: `https://flutter-analytics-api.thuanc177.workers.dev`

---

## Testing the Setup

### Option 1: Manual Trigger (Recommended for first test)

1. Go to your GitHub repo
2. Click **"Actions"** tab
3. Click **"Deploy Cloudflare Worker"** in the left sidebar
4. Click **"Run workflow"** → Select `main` branch → **"Run workflow"**
5. Watch the deployment progress

### Option 2: Push a Change

1. Make a small change to any file in `cloudflare-worker/`
2. Commit and push to `main`:
   ```bash
   git add cloudflare-worker/
   git commit -m "Test auto-deploy"
   git push origin main
   ```
3. Go to **Actions** tab to see the deployment

---

## Troubleshooting

### ❌ "Invalid API Token"
- Double-check your `CLOUDFLARE_API_TOKEN` is correct
- Make sure the token has "Edit Cloudflare Workers" permissions
- Token might have expired - generate a new one

### ❌ "Account ID not found"
- Verify `CLOUDFLARE_ACCOUNT_ID` matches your actual account ID
- Run `wrangler whoami` locally to confirm

### ❌ Deployment succeeds but secrets not updated
- The `wrangler-action` should handle secrets automatically
- If issues persist, you can manually update secrets via:
  ```bash
  wrangler secret put DATABASE_URL
  wrangler secret put API_KEY
  ```

### ❌ Health check fails
- Wait a few seconds longer (cold start)
- Check Cloudflare dashboard → Workers & Pages → Your worker → Logs
- Manually test: `curl https://flutter-analytics-api.thuanc177.workers.dev/health`

---

## Current Status

- ✅ Workflow file created: `.github/workflows/deploy-worker.yml`
- ⏳ **Next step:** Add the 4 required secrets to your GitHub repository
- ⏳ **Then:** Test the workflow

---

## Quick Setup Checklist

- [ ] Add `CLOUDFLARE_API_TOKEN` to GitHub Secrets
- [ ] Add `CLOUDFLARE_ACCOUNT_ID` to GitHub Secrets
- [ ] Add `DATABASE_URL` to GitHub Secrets
- [ ] Add `API_KEY` to GitHub Secrets
- [ ] Test workflow manually from Actions tab
- [ ] Verify deployment at health endpoint

---

Once all secrets are added, your Cloudflare Worker will automatically deploy on every push to `main`! 🚀
