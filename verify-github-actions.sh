#!/bin/bash

# GitHub Actions Setup Verification Script
# This script checks if everything is ready for automatic Cloudflare Worker deployment

echo "🔍 Verifying GitHub Actions Setup for Cloudflare Worker..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES=0

# Check 1: Workflow file exists
echo "📄 Checking workflow file..."
if [ -f ".github/workflows/deploy-worker.yml" ]; then
    echo -e "${GREEN}✅ Workflow file exists${NC}"
else
    echo -e "${RED}❌ Workflow file not found${NC}"
    ISSUES=$((ISSUES + 1))
fi

# Check 2: Worker directory structure
echo ""
echo "📁 Checking worker directory structure..."
if [ -d "cloudflare-worker" ]; then
    echo -e "${GREEN}✅ cloudflare-worker/ directory exists${NC}"
    
    if [ -f "cloudflare-worker/package.json" ]; then
        echo -e "${GREEN}✅ package.json exists${NC}"
    else
        echo -e "${RED}❌ package.json not found${NC}"
        ISSUES=$((ISSUES + 1))
    fi
    
    if [ -f "cloudflare-worker/wrangler.toml" ]; then
        echo -e "${GREEN}✅ wrangler.toml exists${NC}"
    else
        echo -e "${RED}❌ wrangler.toml not found${NC}"
        ISSUES=$((ISSUES + 1))
    fi
    
    if [ -f "cloudflare-worker/src/index.ts" ]; then
        echo -e "${GREEN}✅ src/index.ts exists${NC}"
    else
        echo -e "${RED}❌ src/index.ts not found${NC}"
        ISSUES=$((ISSUES + 1))
    fi
else
    echo -e "${RED}❌ cloudflare-worker/ directory not found${NC}"
    ISSUES=$((ISSUES + 1))
fi

# Check 3: Dependencies
echo ""
echo "📦 Checking dependencies..."
if [ -f "cloudflare-worker/package-lock.json" ]; then
    echo -e "${GREEN}✅ package-lock.json exists${NC}"
else
    echo -e "${YELLOW}⚠️  package-lock.json not found (run 'npm install' in cloudflare-worker/)${NC}"
fi

# Check 4: Wrangler config
echo ""
echo "⚙️  Checking wrangler configuration..."
if grep -q "name.*=.*\"flutter-analytics-api\"" cloudflare-worker/wrangler.toml 2>/dev/null; then
    echo -e "${GREEN}✅ Worker name configured${NC}"
else
    echo -e "${RED}❌ Worker name not found in wrangler.toml${NC}"
    ISSUES=$((ISSUES + 1))
fi

if grep -q "nodejs_compat" cloudflare-worker/wrangler.toml 2>/dev/null; then
    echo -e "${GREEN}✅ nodejs_compat flag enabled${NC}"
else
    echo -e "${YELLOW}⚠️  nodejs_compat flag not found${NC}"
fi

# Check 5: Local secrets (for reference)
echo ""
echo "🔐 Checking local environment (.dev.vars)..."
if [ -f "cloudflare-worker/.dev.vars" ]; then
    echo -e "${GREEN}✅ .dev.vars exists${NC}"
    
    if grep -q "DATABASE_URL" cloudflare-worker/.dev.vars; then
        echo -e "${GREEN}✅ DATABASE_URL configured locally${NC}"
    else
        echo -e "${YELLOW}⚠️  DATABASE_URL not found in .dev.vars${NC}"
    fi
    
    if grep -q "API_KEY" cloudflare-worker/.dev.vars; then
        echo -e "${GREEN}✅ API_KEY configured locally${NC}"
    else
        echo -e "${YELLOW}⚠️  API_KEY not found in .dev.vars${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  .dev.vars not found (needed for local development)${NC}"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════"
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo ""
    echo "📋 Next steps:"
    echo "1. Go to GitHub repo → Settings → Secrets and variables → Actions"
    echo "2. Add these 4 secrets:"
    echo "   - CLOUDFLARE_API_TOKEN"
    echo "   - CLOUDFLARE_ACCOUNT_ID"
    echo "   - DATABASE_URL"
    echo "   - API_KEY"
    echo ""
    echo "3. Push to main branch or manually trigger the workflow"
    echo ""
    echo "📖 See GITHUB_ACTIONS_SETUP.md for detailed instructions"
else
    echo -e "${RED}❌ Found $ISSUES issue(s) - please fix them first${NC}"
fi
echo "═══════════════════════════════════════════════"
