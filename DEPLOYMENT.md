# Muud Health — Deployment Guide

> Last updated: 2026-03-25

---

## Table of Contents

1. [Backend Deployment](#backend-deployment)
2. [iOS Release Build](#ios-release-build)
3. [Android Release Build](#android-release-build)
4. [Firebase Setup](#firebase-setup)
5. [Local Development](#local-development)
6. [Environment Variables Reference](#environment-variables-reference)

---

## Backend Deployment

### Option A: Render.com

The project includes a `render.yaml` blueprint for one-click deployment.

**Steps:**

1. Push code to GitHub
2. In Render dashboard: **New > Blueprint** and connect the repo
3. Set environment variables in the Render dashboard (all `sync: false` vars):

| Variable | Value |
|----------|-------|
| `MONGO_URI` | Your MongoDB Atlas connection string |
| `AWS_REGION` | `us-west-2` (or your region) |
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `COGNITO_USER_POOL_ID` | e.g. `us-west-2_aBcDeFgHi` |
| `COGNITO_CLIENT_ID` | Cognito app client ID |
| `COGNITO_DOMAIN` | e.g. `https://muud.auth.us-west-2.amazoncognito.com` |
| `S3_BUCKET_NAME` | S3 bucket for uploads |
| `ALLOWED_ORIGINS` | e.g. `https://muudhealth.com,muudhealth://callback` |
| `TWILIO_ACCOUNT_SID` | Twilio SID (optional) |
| `TWILIO_AUTH_TOKEN` | Twilio auth token (optional) |
| `TWILIO_PHONE_NUMBER` | e.g. `+15551234567` (optional) |
| `MAILGUN_API_KEY` | Mailgun key (optional) |
| `MAILGUN_DOMAIN` | Mailgun domain (optional) |
| `MAILGUN_FROM` | e.g. `Muud Health <noreply@mail.muudhealth.com>` (optional) |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Stringified Firebase service account JSON |

4. Deploy. Verify at `https://your-service.onrender.com/health`

**Render free-tier note:** Free instances spin down after 15min of inactivity. Use the Starter plan ($7/mo) for always-on.

### Option B: AWS ECS (Fargate)

For production-grade deployments with your existing AWS account.

**Steps:**

1. Build and push Docker image:
```bash
# Build
docker build -t muud-backend .

# Tag for ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com
docker tag muud-backend:latest <account-id>.dkr.ecr.us-west-2.amazonaws.com/muud-backend:latest
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/muud-backend:latest
```

2. Create ECS cluster (Fargate):
   - Task definition: 0.5 vCPU, 1GB memory
   - Container port: 4000
   - Set all env vars from `.env.example` as task definition environment variables
   - Use AWS Secrets Manager for sensitive values

3. Create an Application Load Balancer:
   - Listener: HTTPS 443 → Target Group → ECS tasks on port 4000
   - Health check path: `/health`

4. Set `ALLOWED_ORIGINS` to your production frontend domain

### Option C: Docker (any host)

```bash
docker build -t muud-backend .
docker run -d \
  --name muud-backend \
  -p 4000:4000 \
  --env-file backend/.env \
  muud-backend
```

---

## iOS Release Build

### Prerequisites

- macOS with Xcode installed
- Apple Developer account with distribution certificate
- Provisioning profiles configured in Xcode
- Flutter SDK ^3.9.2

### Build Steps

1. **Set environment variables:**
```bash
export API_BASE_URL=https://your-api.onrender.com   # or ECS URL
export COGNITO_DOMAIN=https://muud.auth.us-west-2.amazoncognito.com
export COGNITO_CLIENT_ID=your-client-id
```

2. **Run the build script:**
```bash
./scripts/build-ios.sh release
```

3. **Archive in Xcode:**
   - Open `frontend/ios/Runner.xcworkspace`
   - Select **Product > Archive**
   - In Organizer, click **Distribute App**
   - Choose **App Store Connect** distribution
   - Select your provisioning profile and team
   - Upload to App Store Connect

4. **Submit in App Store Connect:**
   - Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Select the build under TestFlight or App Store tab
   - Complete metadata (screenshots, description, privacy policy URL)
   - Submit for review

### iOS Bundle ID

The bundle identifier is set to `com.muudhealth.app` across:
- `ios/Runner.xcodeproj/project.pbxproj`
- `Info.plist` (via `$(PRODUCT_BUNDLE_IDENTIFIER)`)

Ensure this matches your Apple Developer portal App ID.

### Deep Linking

The app uses `muudhealth://` scheme for OAuth callbacks. Ensure:
- Cognito app client has `muudhealth://callback` in allowed callback URLs
- Cognito app client has `muudhealth://signout` in allowed sign-out URLs

---

## Android Release Build

### Prerequisites

- Android SDK
- Flutter SDK ^3.9.2
- Release keystore (see below)

### Keystore Setup

1. **Generate a keystore** (one-time):
```bash
keytool -genkey -v -keystore frontend/android/upload-key.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

2. **Create `frontend/android/key.properties`** (see `key.properties.example`):
```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=upload-key.jks
```

3. **Build:**
```bash
export API_BASE_URL=https://your-api.onrender.com
export COGNITO_DOMAIN=https://muud.auth.us-west-2.amazoncognito.com
export COGNITO_CLIENT_ID=your-client-id

# App Bundle for Play Store
./scripts/build-android.sh appbundle

# APK for direct install
./scripts/build-android.sh apk
```

### Application ID

The application ID is `com.muudhealth.app`, configured in:
- `android/app/build.gradle.kts`
- `AndroidManifest.xml` (via Gradle)

---

## Firebase Setup

Firebase is required for push notifications.

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create project "Muud Health" (or use existing)
3. Enable Cloud Messaging

### 2. Add Android App

1. In Firebase Console > Project Settings > Add App > Android
2. Package name: `com.muudhealth.app`
3. Download `google-services.json`
4. Place at: `frontend/android/app/google-services.json`

### 3. Add iOS App

1. In Firebase Console > Project Settings > Add App > iOS
2. Bundle ID: `com.muudhealth.app`
3. Download `GoogleService-Info.plist`
4. Place at: `frontend/ios/Runner/GoogleService-Info.plist`

### 4. Generate Service Account Key

1. Firebase Console > Project Settings > Service Accounts
2. Click "Generate New Private Key"
3. Download the JSON file
4. Stringify it and set as `FIREBASE_SERVICE_ACCOUNT_JSON` env var on your backend:

```bash
# Convert to single-line string
cat firebase-service-account.json | jq -c . > firebase-key-oneline.json

# Set in your hosting platform or .env
FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account","project_id":"muud-health",...}'
```

### 5. iOS APNs Configuration

1. In Apple Developer Portal > Keys, create an APNs key
2. Download the `.p8` file
3. In Firebase Console > Project Settings > Cloud Messaging > iOS:
   - Upload the APNs key
   - Enter Key ID and Team ID

---

## Local Development

### Quick Start with Docker Compose

```bash
# Start MongoDB + backend
docker compose up -d

# Backend is at http://localhost:4000
# MongoDB is at mongodb://localhost:27017/muud
```

### Manual Setup

**Backend:**
```bash
cd backend
cp .env.example .env
# Edit .env with your values (at minimum: MONGO_URI)
npm install
npm run dev
```

**Frontend:**
```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:4000 \
            --dart-define=COGNITO_DOMAIN=https://your-domain.auth.us-west-2.amazoncognito.com \
            --dart-define=COGNITO_CLIENT_ID=your-client-id
```

---

## Environment Variables Reference

### Backend (Node.js)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | No | `4000` | Server port |
| `NODE_ENV` | No | — | `production` or `development` |
| `MONGO_URI` | **Yes** | — | MongoDB connection string |
| `AWS_REGION` | **Yes** | — | AWS region (e.g. `us-west-2`) |
| `AWS_ACCESS_KEY_ID` | **Yes** | — | AWS IAM access key |
| `AWS_SECRET_ACCESS_KEY` | **Yes** | — | AWS IAM secret key |
| `COGNITO_USER_POOL_ID` | **Yes** | — | Cognito User Pool ID |
| `COGNITO_CLIENT_ID` | **Yes** | — | Cognito App Client ID |
| `COGNITO_DOMAIN` | No | — | Cognito hosted UI domain |
| `S3_BUCKET_NAME` | **Yes** | — | S3 bucket for uploads |
| `ALLOWED_ORIGINS` | **Yes** | `http://localhost:3000` | Comma-separated CORS origins |
| `TWILIO_ACCOUNT_SID` | No | — | Twilio (SMS) |
| `TWILIO_AUTH_TOKEN` | No | — | Twilio (SMS) |
| `TWILIO_PHONE_NUMBER` | No | — | Twilio sender number |
| `MAILGUN_API_KEY` | No | — | Mailgun (email) |
| `MAILGUN_DOMAIN` | No | — | Mailgun domain |
| `MAILGUN_FROM` | No | — | Mailgun sender |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | No | — | Firebase push notifications |

### Frontend (Flutter --dart-define)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `API_BASE_URL` | **Yes** | `http://localhost:4000` | Backend API URL |
| `COGNITO_DOMAIN` | **Yes** | — | Cognito hosted UI domain |
| `COGNITO_CLIENT_ID` | **Yes** | — | Cognito App Client ID |
| `COGNITO_REDIRECT_URI` | No | `muudhealth://callback` | OAuth callback URI |
| `COGNITO_LOGOUT_URI` | No | `muudhealth://signout` | Post-logout redirect URI |

---

*This guide is a living document. Update as infrastructure evolves.*
