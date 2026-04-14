# GitHub Credentials Setup — Muud Health
## © Muud Health — Armin Hoes, MD

This document provides the **permanent** credential setup for GitHub push access
from Cowork/Claude sessions and any CI/CD environment.

---

## Option A: GitHub PAT via Environment Variable (Recommended)

1. **Generate a Fine-Grained PAT** at https://github.com/settings/tokens?type=beta
   - Token name: `muud-cowork-access`
   - Expiration: 90 days (rotate quarterly)
   - Repository access: Select `muud-health/muud_health_app` (and any other repos)
   - Permissions: Contents (Read and write), Metadata (Read)

2. **Add as Cowork Environment Variable:**
   In your Cowork session settings or `.env` file, add:
   ```
   GITHUB_TOKEN=github_pat_xxxxxxxxxxxx
   ```

3. **The repo's git config will auto-detect the token** via the credential helper
   configured below.

## Option B: SSH Key (Alternative)

1. Generate an SSH key: `ssh-keygen -t ed25519 -C "armin@muudring.com"`
2. Add the public key to https://github.com/settings/keys
3. Change the remote URL:
   ```bash
   git remote set-url origin git@github.com:muud-health/muud_health_app.git
   ```

---

## Automated Setup Script

Run this once per session (or add to session initialization):

```bash
# If GITHUB_TOKEN env var is set, configure git to use it
if [ -n "$GITHUB_TOKEN" ]; then
  git config --global credential.helper store
  echo "https://muud-health:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
  chmod 600 ~/.git-credentials
  echo "✅ GitHub credentials configured"
fi
```

---

## CI/CD (GitHub Actions)

GitHub Actions automatically have `GITHUB_TOKEN` in the environment.
For cross-repo access, use a PAT stored as a repository secret:

```yaml
# In .github/workflows/*.yml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Verification

```bash
git push --dry-run origin main
# Should succeed without prompting for credentials
```
