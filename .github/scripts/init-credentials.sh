#!/usr/bin/env bash
# Muud Health — Session Credential Initializer
# © Muud Health — Armin Hoes, MD
#
# Run at the start of any Cowork/CI session to configure GitHub push access.
# Usage: source .github/scripts/init-credentials.sh

set -euo pipefail

# ── GitHub ────────────────────────────────────────────────────────
if [ -n "${GITHUB_TOKEN:-}" ]; then
  git config --global credential.helper store
  echo "https://muud-health:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
  chmod 600 ~/.git-credentials
  echo "✅ GitHub credentials configured (PAT)"
elif [ -n "${GH_TOKEN:-}" ]; then
  git config --global credential.helper store
  echo "https://muud-health:${GH_TOKEN}@github.com" > ~/.git-credentials
  chmod 600 ~/.git-credentials
  echo "✅ GitHub credentials configured (GH_TOKEN)"
else
  echo "⚠️  No GITHUB_TOKEN or GH_TOKEN found — git push will fail"
  echo "   Set GITHUB_TOKEN in your Cowork environment settings"
fi

# ── AWS (for Cognito, S3, DocumentDB) ────────────────────────────
if [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
  echo "✅ AWS credentials present"
else
  echo "⚠️  AWS credentials not found — backend cloud services unavailable"
fi

# ── MongoDB ───────────────────────────────────────────────────────
if [ -n "${MONGODB_URI:-}" ]; then
  echo "✅ MongoDB URI configured"
else
  echo "⚠️  MONGODB_URI not set — database connections will fail"
fi

# ── Summary ───────────────────────────────────────────────────────
echo ""
echo "Session credential check complete."
echo "Run 'git push --dry-run origin main' to verify GitHub access."
