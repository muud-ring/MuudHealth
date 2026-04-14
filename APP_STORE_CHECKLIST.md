# Muud Health — App Store Deployment Checklist

> Step-by-step guide to get the Muud app from current state to live on the App Store and Google Play.
>
> **Current state**: Backend fully functional with 110 passing tests, CI/CD pipeline active, Docker deployment ready, Firebase and push notification infrastructure built, build scripts ready.
>
> **Legend**: [ ] = you must do this manually | [x] = already done

---

## Phase 1: Accounts & Legal (Do First — These Take Time)

### Step 1: Apple Developer Account
- [ ] Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)
- [ ] Wait for approval (usually 24–48 hours)
- [ ] Note your **Team ID** (found in Membership section)

### Step 2: Google Play Developer Account
- [ ] Register at [Google Play Console](https://play.google.com/console) ($25 one-time)
- [ ] Complete identity verification (can take 2–7 days)

### Step 3: Legal Documents
You need three documents hosted at public URLs before either store will accept your app:

- [ ] **Privacy Policy** — Required by both stores. Must detail what health data you collect, how it's stored, and how users can delete it. Host at e.g. `https://muudhealth.com/privacy`
- [ ] **Terms of Service** — Required by Apple for apps with accounts. Host at e.g. `https://muudhealth.com/terms`
- [ ] **Medical Disclaimer** — Required because this is a health/wellness app. Must state the app does not provide medical advice. Can be a section in Terms or standalone

> **Tip**: Start these now. Store reviews are commonly rejected for missing or inadequate privacy policies.

---

## Phase 2: AWS & Cloud Infrastructure Setup

### Step 4: MongoDB Atlas (Production Database)
- [ ] Create a [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) account (or use existing)
- [ ] Create a production cluster (M10+ recommended for production; M0 free tier for testing)
- [ ] Create a database user with read/write access
- [ ] Whitelist your backend server IP (or use `0.0.0.0/0` for Render/cloud)
- [ ] Copy the connection string → this is your `MONGO_URI`

### Step 5: AWS Cognito (Authentication)
- [ ] In AWS Console → Cognito → Create User Pool
- [ ] Configure sign-in: email + password
- [ ] Enable OAuth 2.0 with hosted UI
- [ ] Add app client:
  - Callback URL: `muudhealth://callback`
  - Sign-out URL: `muudhealth://signout`
  - OAuth flows: Authorization code grant
  - Scopes: openid, email, profile
- [ ] (Optional) Add social identity providers (Google, Apple, Facebook)
- [ ] Note these values:
  - `COGNITO_USER_POOL_ID` (e.g. `us-west-2_aBcDeFgHi`)
  - `COGNITO_CLIENT_ID` (from app client)
  - `COGNITO_DOMAIN` (e.g. `https://muud.auth.us-west-2.amazoncognito.com`)

### Step 6: AWS S3 (File Uploads)
- [ ] Create an S3 bucket (e.g. `muud-health-uploads`)
- [ ] Enable CORS on the bucket for your API domain
- [ ] Create an IAM user with S3 access, note:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `S3_BUCKET_NAME`

### Step 7: Firebase (Push Notifications)
- [ ] Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Add Android app with package name `com.muudhealth.app`
- [ ] Download `google-services.json` → place at `frontend/android/app/google-services.json`
- [ ] Add iOS app with bundle ID `com.muudhealth.app`
- [ ] Download `GoogleService-Info.plist` → place at `frontend/ios/Runner/GoogleService-Info.plist`
- [ ] Generate service account key (Project Settings → Service Accounts → Generate New Private Key)
- [ ] Stringify the JSON: `cat key.json | jq -c .` → this is your `FIREBASE_SERVICE_ACCOUNT_JSON`
- [ ] For iOS: Create APNs key in Apple Developer Portal → Keys → upload `.p8` to Firebase Cloud Messaging settings

---

## Phase 3: Deploy the Backend

### Step 8: Choose a Hosting Provider

**Option A — Render.com (Recommended for MVP)**
- [ ] Push code to GitHub
- [ ] In Render: New → Blueprint → connect repo
- [ ] The `render.yaml` auto-configures the service
- [ ] Add environment variables in Render dashboard:

```
PORT=10000
MONGO_URI=<from Step 4>
AWS_REGION=us-west-2
AWS_ACCESS_KEY_ID=<from Step 6>
AWS_SECRET_ACCESS_KEY=<from Step 6>
COGNITO_USER_POOL_ID=<from Step 5>
COGNITO_CLIENT_ID=<from Step 5>
COGNITO_DOMAIN=<from Step 5>
S3_BUCKET_NAME=<from Step 6>
ALLOWED_ORIGINS=muudhealth://callback,muudhealth://signout
FIREBASE_SERVICE_ACCOUNT_JSON=<from Step 7>
```

- [ ] Deploy and verify: `curl https://your-service.onrender.com/health`
- [ ] Note your API URL → this is your `API_BASE_URL`

**Option B — AWS ECS Fargate** (see DEPLOYMENT.md for details)

**Option C — Docker on any VPS** (see DEPLOYMENT.md for details)

### Step 9: Verify Backend
- [ ] Health check returns `{"status":"ok","service":"MUUD Backend"}`
- [ ] Test auth flow: POST to `/auth/token` with Cognito tokens
- [ ] Confirm MongoDB connection (check server logs for successful connection)

---

## Phase 4: Build the Android App

### Step 10: Generate Release Keystore
```bash
keytool -genkey -v \
  -keystore frontend/android/upload-key.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```
- [ ] Store the keystore password securely (you'll need it forever)
- [ ] **NEVER** commit the `.jks` file to git (already in `.gitignore`)

### Step 11: Configure Signing
- [ ] Create `frontend/android/key.properties` from the example:
```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=upload-key.jks
```

### Step 12: Build the App Bundle
```bash
export API_BASE_URL=https://your-api.onrender.com
export COGNITO_DOMAIN=https://muud.auth.us-west-2.amazoncognito.com
export COGNITO_CLIENT_ID=your-client-id

./scripts/build-android.sh appbundle
```
- [ ] Output: `frontend/build/app/outputs/bundle/release/app-release.aab`

### Step 13: Upload to Google Play Console
- [ ] In Google Play Console: Create App → "Muud Health"
- [ ] Fill in store listing:
  - App name: Muud Health
  - Short description (80 chars max)
  - Full description (4000 chars max)
  - App icon: 512x512 PNG
  - Feature graphic: 1024x500 PNG
  - Screenshots: minimum 2 per device type (phone), recommended 4-8
  - App category: Health & Fitness
  - Contact email
  - Privacy policy URL (from Step 3)
- [ ] Complete the Data Safety form (declare health data collection)
- [ ] Content rating questionnaire
- [ ] Target audience and content settings
- [ ] Upload AAB to Internal Testing track first
- [ ] Test with real devices via internal testing link
- [ ] Promote to Closed Testing → Open Testing → Production

---

## Phase 5: Build the iOS App

### Step 14: Configure Xcode Signing
- [ ] On a Mac, open `frontend/ios/Runner.xcworkspace` in Xcode
- [ ] Select the Runner target → Signing & Capabilities tab
- [ ] Set Team to your Apple Developer account
- [ ] Bundle Identifier should already be `com.muudhealth.app`
- [ ] Xcode auto-generates provisioning profiles

### Step 15: Register App ID in Apple Developer Portal
- [ ] Go to Certificates, Identifiers & Profiles
- [ ] Verify App ID `com.muudhealth.app` exists (Xcode usually creates it)
- [ ] Enable capabilities: Push Notifications, Associated Domains (if needed)

### Step 16: Build iOS Release
```bash
export API_BASE_URL=https://your-api.onrender.com
export COGNITO_DOMAIN=https://muud.auth.us-west-2.amazoncognito.com
export COGNITO_CLIENT_ID=your-client-id

./scripts/build-ios.sh release
```

### Step 17: Archive and Upload
- [ ] In Xcode: Product → Archive
- [ ] In Organizer: Distribute App → App Store Connect
- [ ] Select your provisioning profile and team
- [ ] Upload

### Step 18: Submit in App Store Connect
- [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Create new app: "Muud Health", bundle ID `com.muudhealth.app`
- [ ] Fill in metadata:
  - Screenshots: 6.7" (1290x2796) and 5.5" (1242x2208) minimum
  - Description, keywords, support URL
  - Privacy policy URL (from Step 3)
  - App category: Health & Fitness
- [ ] Select the build uploaded from Xcode
- [ ] Complete App Privacy section (declare health data usage)
- [ ] Submit to TestFlight first for beta testing
- [ ] After beta validation, submit for App Review

---

## Phase 6: Pre-Submission Quality Checks

### Step 19: Functional Testing
Before submitting to either store:
- [ ] Fresh install: app opens to login screen
- [ ] Sign up flow completes (email verification, OTP)
- [ ] Login works, token persists across app restarts
- [ ] Onboarding 8-step flow completes
- [ ] Home screen loads with data
- [ ] Journal: create, edit, preview, delete entries
- [ ] People: send/accept friend requests, view connections
- [ ] Chat: send messages, real-time delivery works
- [ ] Vault: add/view private entries
- [ ] Settings: edit profile, upload avatar
- [ ] Push notifications received (background + foreground)
- [ ] Logout clears tokens and returns to login
- [ ] Deep links (`muudhealth://callback`) handled correctly

### Step 20: App Store Review Gotchas
Common rejection reasons to prevent:

- [ ] **Demo account**: Apple requires a test account in the review notes if login is required. Provide Cognito test credentials in the App Review notes
- [ ] **Privacy labels match reality**: Ensure the data you declare in the privacy form matches what the app actually collects
- [ ] **No placeholder content**: All screens must have real content or graceful empty states
- [ ] **No crashes**: Test on oldest supported iOS/Android versions
- [ ] **HTTPS only**: All API calls must use HTTPS (already enforced)
- [ ] **No hardcoded dev URLs**: Ensure all API URLs come from `--dart-define` (already configured)

---

## Current Project Status (What's Already Done)

| Component | Status | Evidence |
|-----------|--------|----------|
| Backend API | [x] Complete | 14 routes, 13 controllers, 10 models |
| Backend tests | [x] 110 tests passing | Jest + supertest + mongodb-memory-server |
| CI/CD pipeline | [x] Active | GitHub Actions: lint, test, security audit, Docker build, Android build |
| Authentication | [x] AWS Cognito integrated | OAuth 2.0 + JWT verification on HTTP + WebSocket |
| Real-time chat | [x] Socket.IO | Room-based messaging with auth |
| Push notifications | [x] Firebase Admin SDK | Backend service + frontend integration |
| Rate limiting | [x] express-rate-limit | API + auth-specific limiters |
| Security headers | [x] Helmet.js | Production security headers |
| Input validation | [x] express-validator | Validation middleware + route validators |
| CORS | [x] Properly configured | Origin whitelist from env var (no wildcards) |
| Structured logging | [x] Pino logger | Replaces console.log in prod code |
| Docker deployment | [x] Dockerfile + compose | Production-ready container |
| Render blueprint | [x] render.yaml | One-click Render deployment |
| Build scripts | [x] iOS + Android | `scripts/build-ios.sh`, `scripts/build-android.sh` |
| Android signing | [x] Configured | `build.gradle.kts` reads `key.properties` |
| Deep linking | [x] Configured | `muudhealth://` scheme for OAuth callbacks |
| .env management | [x] No secrets in code | Cognito/AWS creds from env vars + `--dart-define` |
| Error handling | [x] Global error handler | `errorHandler.js` middleware |
| State management | [x] Riverpod | Providers for auth, journal, chat, people, biometrics |
| Dart print() cleaned | [x] 0 statements | All debug prints removed from frontend |

---

## Estimated Timeline

| Phase | Duration | Dependency |
|-------|----------|------------|
| Phase 1: Accounts & Legal | 1-2 weeks | Apple approval, legal drafting |
| Phase 2: AWS Setup | 1-2 days | Account access |
| Phase 3: Backend Deploy | 1-2 hours | Phase 2 complete |
| Phase 4: Android Build | 2-4 hours | Phases 2-3 complete |
| Phase 5: iOS Build | 2-4 hours | Phases 1-3 complete, Mac required |
| Phase 6: Testing & Submit | 3-5 days | All phases complete |
| **App Review** | 1-7 days | Apple typically 24-48hrs, Google 1-3 days |

**Total: ~3-4 weeks** from starting Phase 1 to both stores live.

---

## Quick Reference: All Environment Variables You Need

```bash
# Backend (.env or hosting dashboard)
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/muud
AWS_REGION=us-west-2
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
COGNITO_USER_POOL_ID=us-west-2_aBcDeFgHi
COGNITO_CLIENT_ID=abc123def456
COGNITO_DOMAIN=https://muud.auth.us-west-2.amazoncognito.com
S3_BUCKET_NAME=muud-health-uploads
ALLOWED_ORIGINS=muudhealth://callback,muudhealth://signout
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}

# Frontend (passed via --dart-define or build scripts)
API_BASE_URL=https://your-backend-url.onrender.com
COGNITO_DOMAIN=https://muud.auth.us-west-2.amazoncognito.com
COGNITO_CLIENT_ID=abc123def456
```

---

*This checklist is a living document. Check off items as you complete them.*
