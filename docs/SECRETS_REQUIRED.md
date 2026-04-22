# GitHub Actions Secrets — MuudHealth CD Pipeline

This document lists every secret required by `.github/workflows/cd.yml`.
Set missing secrets at: **GitHub → Settings → Secrets and variables → Actions → New repository secret**

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ SET | Secret is already configured in the repo |
| ⚠️ MANUAL | Secret is set to a placeholder — Dr. Hoes must update it manually |
| ❌ MISSING | Secret must be added before the relevant job will succeed |
| P0 | Blocks backend deploy to AWS ECS |
| P1 | Blocks Android app bundle build |
| P2 | Blocks iOS IPA build |

---

## Current Secret Status

| Secret | Status |
|--------|--------|
| `API_BASE_URL` | ✅ SET — `https://api.muudhealth.com` |
| `AWS_DEPLOY_ROLE_ARN` | ✅ SET — `arn:aws:iam::650138640062:role/MuudGitHubActionsDeployRole` ⚠️ Role may need manual creation — see below |
| `ANDROID_KEYSTORE_BASE64` | ✅ SET — Generated keystore |
| `ANDROID_KEY_ALIAS` | ✅ SET — `muud-key` |
| `ANDROID_KEY_PASSWORD` | ✅ SET — `MuudHealth2024!` |
| `ANDROID_STORE_PASSWORD` | ✅ SET — `MuudHealth2024!` |
| `IOS_P12_PASSWORD` | ⚠️ PLACEHOLDER — must be set by Dr. Hoes (see below) |

---

## P0 — Backend Deploy (AWS ECS)

### `AWS_DEPLOY_ROLE_ARN` — Role May Need Manual Creation

**Current value:** `arn:aws:iam::650138640062:role/MuudGitHubActionsDeployRole`

The role ARN has been set. However, the IAM role itself may not yet exist in AWS.

**To create the role using CloudFormation (recommended):**

A ready-to-deploy CloudFormation template is at `infra/muud-github-oidc-cfn.yaml`. Deploy it:

```bash
aws cloudformation deploy \
  --template-file infra/muud-github-oidc-cfn.yaml \
  --stack-name muud-github-oidc \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

**Or to create it manually:**
1. AWS Console → IAM → Roles → Create Role
2. Choose **Web identity** → Identity provider: `token.actions.githubusercontent.com`
3. Audience: `sts.amazonaws.com`
4. Condition: `repo:muud-ring/MuudHealth:*`
5. Role name: `MuudGitHubActionsDeployRole`
6. Attach policies:
   - `AmazonECS_FullAccess`
   - `AmazonEC2ContainerRegistryPowerUser`
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`

---

## P2 — iOS IPA Build

### `IOS_P12_PASSWORD` ⚠️ MUST BE SET MANUALLY

**Current value:** `REQUIRES_MANUAL_SET` (placeholder — CD will fail on iOS step)

**What it is:** The password protecting the `.p12` file used to export `IOS_DIST_CERT_P12_BASE64`.

**How to get it:**
1. Open **Keychain Access** on your Mac
2. Find your Apple Distribution certificate
3. Right-click → Export → save as `.p12`
4. The password you enter during export is `IOS_P12_PASSWORD`
5. The base64 of the file is `IOS_DIST_CERT_P12_BASE64`

**Set it at:** https://github.com/muud-ring/MuudHealth/settings/secrets/actions

---

## CI Status (as of last update)

| Job | Status |
|-----|--------|
| Security Audit | ✅ PASSING |
| Backend Lint & Test (110 unit tests) | ✅ PASSING |
| Frontend Analyze & Test (47 tests) | ✅ PASSING |
| Docker Build Check | ✅ PASSING |
| Build Android APK | ✅ PASSING |

**CI is 100% green on `main` branch.**

---

## Android Keystore Details

The Android keystore was generated and stored as `ANDROID_KEYSTORE_BASE64`. Details:

- **Alias:** `muud-key`
- **Key password / Store password:** `MuudHealth2024!`
- **Algorithm:** RSA 2048
- **Validity:** 10,000 days

> ⚠️ Before publishing to the Play Store, replace this with a proper production keystore generated and stored securely. The keystore used to sign the first published APK/AAB must be used for all future updates.
<!-- deploy trigger: 2026-04-22T19:54:21Z -->
