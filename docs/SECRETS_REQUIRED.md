# GitHub Actions Secrets — MuudHealth CD Pipeline

This document lists every secret required by `.github/workflows/cd.yml`.
Set missing secrets at: **GitHub → Settings → Secrets and variables → Actions → New repository secret**

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ SET | Secret is already configured in the repo |
| ❌ MISSING | Secret must be added before the relevant job will succeed |
| P0 | Blocks backend deploy to AWS ECS |
| P1 | Blocks Android app bundle build |
| P2 | Blocks iOS IPA build |

---

## P0 — Backend Deploy (AWS ECS)

### `AWS_DEPLOY_ROLE_ARN` ❌ MISSING

**Priority:** P0 — the `deploy-backend` job will fail at the "Configure AWS credentials" step without this.

**What it is:** The ARN of an AWS IAM role that GitHub Actions assumes via OIDC (no long-lived AWS keys required). The role must have permissions to push to ECR, register ECS task definitions, and update the `muud-api-service` service on the `muud-production` cluster.

**How to get it:**
1. In the AWS Console → IAM → Roles → Create Role.
2. Choose **Web identity** → Identity provider: `token.actions.githubusercontent.com`.
3. Audience: `sts.amazonaws.com`.
4. Condition: `repo:muud-ring/MuudHealth:ref:refs/heads/main`.
5. Attach a policy granting: `ecr:GetAuthorizationToken`, `ecr:BatchCheckLayerAvailability`, `ecr:PutImage`, `ecr:InitiateLayerUpload`, `ecr:UploadLayerPart`, `ecr:CompleteLayerUpload`, `ecs:RegisterTaskDefinition`, `ecs:UpdateService`, `ecs:DescribeServices`, `iam:PassRole`.
6. Copy the role ARN — format: `arn:aws:iam::<ACCOUNT_ID>:role/<RoleName>`.

**Secret value:** `arn:aws:iam::<ACCOUNT_ID>:role/<RoleName>`

---

### `API_BASE_URL` ❌ MISSING

**Priority:** P0 (post-deploy health check) / P1 (Android build) / P2 (iOS build) — used in all three jobs.

**What it is:** The public HTTPS base URL of the deployed API, without a trailing slash. Used for the post-deploy health check (`GET /health`) and as a Flutter compile-time constant.

**How to get it:** This is the DNS name of your AWS Application Load Balancer (or custom domain) in front of `muud-api-service`. Find it in: AWS Console → EC2 → Load Balancers, or Route 53 if a custom domain is configured.

**Secret value example:** `https://api.muudhealth.com`

---

## P1 — Android App Bundle

### `ANDROID_KEYSTORE_BASE64` ❌ MISSING

**Priority:** P1 — the Android build decodes this into `upload-keystore.jks` before signing.

**What it is:** The Google Play upload keystore (`.jks` file) encoded as base64.

**How to get it:**
1. If you already have a keystore: `base64 -w0 upload-keystore.jks`
2. If you need to create one: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias <alias>`
3. Paste the base64 output as the secret value.

**Secret value:** Base64-encoded contents of your `.jks` keystore file.

---

### `ANDROID_KEY_ALIAS` ❌ MISSING

**Priority:** P1

**What it is:** The alias of the signing key inside the keystore (set when the keystore was created).

**How to get it:** `keytool -list -keystore upload-keystore.jks` — the alias is listed in the output.

**Secret value:** A short string, e.g. `upload` or `muud-upload`.

---

### `ANDROID_KEY_PASSWORD` ❌ MISSING

**Priority:** P1

**What it is:** The password for the individual key entry within the keystore.

**How to get it:** This is the password you set when creating the key with `keytool -genkey`. If the key and store share a password, set this to the same value as `ANDROID_STORE_PASSWORD`.

**Secret value:** The key password string.

---

### `ANDROID_STORE_PASSWORD` ❌ MISSING

**Priority:** P1

**What it is:** The password for the keystore file itself (the `-storepass` value used with `keytool`).

**How to get it:** This is the store-level password set when the keystore was created.

**Secret value:** The store password string.

---

## P2 — iOS IPA Build

### `IOS_P12_BASE64` ❌ MISSING

**Priority:** P2 — used by `cd.yml` in the "Import signing certificate" step.

> **Note:** The repo already has `IOS_DIST_CERT_P12_BASE64` set (from a previous iOS workflow). The `cd.yml` currently references `IOS_P12_BASE64`, which is a **different name**. This discrepancy has been fixed separately (see commit `fix(cd): use correct IOS_DIST_CERT_P12_BASE64 secret name in iOS build job`). After that fix lands, you do **not** need to add `IOS_P12_BASE64` — the existing `IOS_DIST_CERT_P12_BASE64` will be used.
>
> If you want belt-and-suspenders coverage, you can also add `IOS_P12_BASE64` pointing to the same value as `IOS_DIST_CERT_P12_BASE64`.

**What it is (if adding separately):** Your Apple Distribution certificate exported from Keychain Access as a `.p12` file, encoded as base64.

**How to get it:**
1. Keychain Access → My Certificates → right-click your distribution cert → Export.
2. Save as `.p12` with a password.
3. `base64 -w0 cert.p12` → paste output as secret.

**Secret value:** Base64-encoded `.p12` file contents.

---

### `IOS_P12_PASSWORD` ❌ MISSING

**Priority:** P2

**What it is:** The password used when exporting the `.p12` certificate file from Keychain Access.

**How to get it:** This is the password you entered when exporting via Keychain Access or `openssl pkcs12`.

**Secret value:** The `.p12` export password string.

---

## Already Set ✅

These secrets are currently configured in the repository and do **not** need to be re-added:

| Secret Name | Used By | Notes |
|---|---|---|
| `APPLE_APP_SPECIFIC_PASSWORD` | iOS distribution / TestFlight upload (separate workflow) | ✅ Set |
| `APPLE_ID_USERNAME` | iOS distribution / TestFlight upload | ✅ Set |
| `APPLE_TEAM_ID` | iOS code signing | ✅ Set |
| `IOS_DIST_CERT_P12_BASE64` | iOS build — used after the `cd.yml` fix | ✅ Set — `cd.yml` now references this name |
| `IOS_PROVISIONING_PROFILE_BASE64` | iOS build (`cd.yml` line: `PROVISIONING_PROFILE_BASE64`) | ✅ Set |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Fastlane Match (separate workflow) | ✅ Set |
| `MATCH_PASSWORD` | Fastlane Match (separate workflow) | ✅ Set |

---

## Quick Checklist

```
[ ] AWS_DEPLOY_ROLE_ARN        — P0: create IAM OIDC role, paste ARN
[ ] API_BASE_URL               — P0/P1/P2: ALB DNS or custom domain (HTTPS, no trailing slash)
[ ] ANDROID_KEYSTORE_BASE64    — P1: base64-encode upload-keystore.jks
[ ] ANDROID_KEY_ALIAS          — P1: alias used when keystore was created
[ ] ANDROID_KEY_PASSWORD       — P1: key-level password
[ ] ANDROID_STORE_PASSWORD     — P1: store-level password
[ ] IOS_P12_PASSWORD           — P2: .p12 export password
    (IOS_P12_BASE64 is no longer needed — cd.yml now uses IOS_DIST_CERT_P12_BASE64 ✅)
```

---

*Last updated: automatically generated during CD pipeline audit.*
