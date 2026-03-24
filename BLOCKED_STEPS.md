# Blocked Steps — Muud App MVP V1.1

> **Created**: 2026-03-12
> **Total blocked steps**: 50
> **Status**: Awaiting external input to unblock

---

## How to Use This Document

Each blocked step lists:
- **What**: The step description
- **Blocker**: Why it cannot be executed autonomously
- **Resolution**: The specific action needed to unblock it

---

## Phase 1: Hardening (5 blocked)

### 1. Port Twilio SMS Integration
- **What**: Integrate Twilio SDK for SMS/OTP verification from Build #8
- **Blocker**: Requires Twilio account credentials (Account SID, Auth Token, phone number)
- **Resolution**:
  1. Sign up at [twilio.com](https://www.twilio.com)
  2. Get Account SID + Auth Token from the Twilio Console dashboard
  3. Purchase or provision a phone number for sending SMS
  4. Add to backend `.env`:
     ```
     TWILIO_ACCOUNT_SID=<your-sid>
     TWILIO_AUTH_TOKEN=<your-token>
     TWILIO_PHONE_NUMBER=<your-number>
     ```
  5. Once credentials are provided, the integration code (already scaffolded from Build #8) can be wired up

### 2. Port Mailgun Email Integration
- **What**: Integrate Mailgun for transactional emails (welcome, password reset, notifications)
- **Blocker**: Requires Mailgun account credentials (API key, domain)
- **Resolution**:
  1. Sign up at [mailgun.com](https://www.mailgun.com)
  2. Verify a sending domain (e.g., `mail.muudhealth.com`)
  3. Get API key from Mailgun dashboard
  4. Add to backend `.env`:
     ```
     MAILGUN_API_KEY=<your-key>
     MAILGUN_DOMAIN=<your-domain>
     MAILGUN_FROM=noreply@muudhealth.com
     ```
  5. Alternatively, use Nodemailer with an SMTP provider (Gmail, SES, etc.)

### 3. Provide Current AWS Cognito Credentials for .env Migration
- **What**: The hardcoded Cognito values need to be moved to environment variables, but the *actual production values* need confirmation
- **Blocker**: Need to confirm which Cognito User Pool and Client ID are the production/staging ones
- **Resolution**:
  1. Log into AWS Console → Cognito → User Pools
  2. Confirm the User Pool ID (currently `us-west-2_vrtcZ20k3` in code)
  3. Confirm the App Client IDs (two different ones found: `6j8cleke98rr4kq3nskumptqcm` and `754pdur7oaaqe0a5vtupvfp464`)
  4. Determine which is for production vs development
  5. Provide the values for `.env` configuration

### 4. Provide AWS S3 Bucket Configuration
- **What**: S3 bucket names and regions for file uploads
- **Blocker**: Bucket names are loaded from environment but not documented
- **Resolution**:
  1. Log into AWS Console → S3
  2. Identify the bucket(s) used for avatars and media uploads
  3. Add to backend `.env`:
     ```
     S3_BUCKET_NAME=<your-bucket>
     S3_REGION=us-west-2
     AWS_ACCESS_KEY_ID=<key>
     AWS_SECRET_ACCESS_KEY=<secret>
     ```

### 5. Provide MongoDB Connection String
- **What**: Production MongoDB URI for database connectivity
- **Blocker**: Connection string contains credentials and is environment-specific
- **Resolution**:
  1. If using MongoDB Atlas: Get connection string from Atlas dashboard → Connect → Drivers
  2. If using AWS DocumentDB: Get endpoint from AWS Console (note: Build #8 used DocumentDB with TLS)
  3. Add to backend `.env`:
     ```
     MONGODB_URI=mongodb+srv://<user>:<pass>@<cluster>.mongodb.net/muud?retryWrites=true
     ```

---

## Phase 2: Signal Pipeline (8 blocked)

### 6. Smart Ring BLE SDK/Protocol Documentation
- **What**: Implement Bluetooth Low Energy communication with Muud Smart Ring
- **Blocker**: No ring SDK, protocol specification, or BLE service/characteristic UUIDs available
- **Resolution**:
  1. Obtain the Muud Smart Ring hardware specification document
  2. Get BLE GATT service UUIDs and characteristic UUIDs for each data type (HR, HRV, SpO2, temperature, accelerometer)
  3. Get the data packet format/protocol for each characteristic
  4. If a vendor SDK exists (e.g., from the ring manufacturer), provide the SDK package
  5. Alternatively, provide the `muud-ring/MuudRingiOSApp` (Swift) source code — it likely contains the BLE protocol implementation

### 7. Smart Ring BLE Scanning & Pairing Implementation
- **What**: Build the Flutter BLE scanning, device discovery, and pairing flow
- **Blocker**: Depends on Step 6 (BLE protocol docs)
- **Resolution**: Unblock Step 6 first. Once protocol is known, implementation can proceed using `flutter_blue_plus`

### 8. Smart Ring Pairing UI Screen
- **What**: Build the user-facing ring pairing screen
- **Blocker**: Depends on Steps 6-7 (BLE implementation)
- **Resolution**: Unblock Step 6. UI can be partially built with mock data, but functional pairing requires the BLE layer

### 9. Smart Ring Status/Settings Screen
- **What**: Build ring battery, firmware, and settings management screen
- **Blocker**: Depends on Steps 6-7 (need to know what settings the ring exposes)
- **Resolution**: Unblock Step 6. Provide list of configurable ring parameters

### 10. Firebase Cloud Messaging — Frontend Integration
- **What**: Add `firebase_messaging` package and configure for push notifications
- **Blocker**: Requires a Firebase project with FCM enabled
- **Resolution**:
  1. Go to [Firebase Console](https://console.firebase.google.com)
  2. Create a project (or use existing one) for Muud Health
  3. Add Android app: package name `com.example.frontend` (or your production package name)
  4. Add iOS app: bundle ID from `ios/Runner.xcodeproj`
  5. Download `google-services.json` (Android) → place in `frontend/android/app/`
  6. Download `GoogleService-Info.plist` (iOS) → place in `frontend/ios/Runner/`
  7. Enable Cloud Messaging in Firebase Console
  8. Provide the FCM Server Key for backend integration

### 11. Firebase Cloud Messaging — Backend Token Registration
- **What**: Create endpoint for devices to register their FCM tokens
- **Blocker**: Depends on Step 10 (Firebase project setup)
- **Resolution**: Unblock Step 10. Then add Firebase Admin SDK credentials:
  ```
  FIREBASE_SERVICE_ACCOUNT_KEY=<path-to-service-account.json>
  ```

### 12. Wire Notification Permission to FCM
- **What**: Connect the existing onboarding notification permission UI to actual FCM registration
- **Blocker**: Depends on Steps 10-11
- **Resolution**: Unblock Steps 10-11 first

### 13. FCM Notification Dispatch Service
- **What**: Backend service to send push notifications for events (messages, friend requests, reminders)
- **Blocker**: Partially blocked — the dispatch logic can be written but cannot be tested without Firebase credentials
- **Resolution**: Unblock Step 10, provide Firebase Admin SDK service account JSON

---

## Phase 3: Testing & Security (3 blocked)

### 14. HIPAA Compliance Review
- **What**: Formal review of data handling practices against HIPAA requirements
- **Blocker**: Requires legal/compliance team input on:
  - What constitutes PHI (Protected Health Information) in this app
  - Data retention policies
  - Encryption requirements (at-rest and in-transit)
  - Business Associate Agreements (BAAs) with cloud providers
  - Audit logging requirements
- **Resolution**:
  1. Engage a HIPAA compliance consultant or healthcare attorney
  2. Determine if the app qualifies as a "covered entity" or "business associate"
  3. If yes: implement encryption-at-rest (MongoDB field-level encryption), audit logging, access controls, and BAAs with AWS/MongoDB Atlas
  4. If the app is classified as a wellness app (not medical device), HIPAA may not apply — but data protection best practices should still be followed
  5. Document the determination in a compliance report

### 15. Staging Environment Deployment Pipeline
- **What**: Automated deployment to a staging server for testing
- **Blocker**: No hosting infrastructure details provided
- **Resolution**:
  1. Choose a hosting platform:
     - **Render** (Build #8 had a Render URL — may already have an account)
     - **AWS ECS/EKS** (since already using AWS for Cognito/S3)
     - **Railway**, **Fly.io**, or **DigitalOcean App Platform**
  2. Provide hosting account credentials or access
  3. Provide the staging domain name
  4. Once provided, the GitHub Actions deployment step can be configured

### 16. Production Deployment Pipeline
- **What**: Automated deployment to production
- **Blocker**: Depends on Step 15 + production infrastructure decisions
- **Resolution**: Same as Step 15, but for the production environment. Additionally:
  1. Set up a production MongoDB cluster with encryption-at-rest
  2. Configure production Cognito User Pool (separate from dev)
  3. Set up production S3 buckets with appropriate access policies
  4. Configure a CDN (CloudFront) for static assets

---

## Phase 4: Intelligence (1 blocked)

### 17. AI Analytics Architecture Decision
- **What**: Design the AI/ML engine for predictive health insights
- **Blocker**: Requires decision on ML platform and approach
- **Resolution**:
  1. Choose an approach:
     - **Option A: Claude API** — Use Anthropic's Claude for natural language insights, journal sentiment analysis, and personalized recommendations. Lowest implementation cost. Requires API key.
     - **Option B: AWS SageMaker** — Custom ML models for biometric prediction. Higher cost, more control. Already in AWS ecosystem.
     - **Option C: Hybrid** — Claude for NLP tasks (journal analysis, recommendations) + lightweight statistical models (running on-server) for biometric trends. Best balance.
  2. Provide the chosen approach + any required API keys
  3. Add to backend `.env`:
     ```
     # If using Claude API
     ANTHROPIC_API_KEY=<your-key>

     # If using SageMaker
     SAGEMAKER_ENDPOINT=<your-endpoint>
     ```

---

## Phase 5: Ship-Ready (33 blocked)

### 18. Additional Language Translations
- **What**: Translate all app strings beyond English
- **Blocker**: Requires translation service or multilingual team
- **Resolution**:
  1. Determine target languages (e.g., Spanish, French, Portuguese, Mandarin)
  2. Options:
     - **Professional translation service** (e.g., Gengo, Translated.com) — most accurate
     - **AI-assisted translation** (Claude/GPT) + native speaker review — cost-effective
     - **Community translation** (Crowdin, Transifex) — scalable
  3. Export the English ARB file and send to translation service
  4. Import translated ARB files back into the project

### 19. Production MongoDB Setup
- **What**: Set up production database with encryption-at-rest
- **Blocker**: Requires MongoDB Atlas or AWS DocumentDB account with billing
- **Resolution**:
  1. **MongoDB Atlas** (recommended):
     - Create M10+ dedicated cluster (not shared — for HIPAA eligibility)
     - Enable encryption-at-rest (automatic on dedicated clusters)
     - Enable audit logging
     - Set up network peering with AWS VPC
     - Create database user with least-privilege access
  2. **AWS DocumentDB**:
     - Create cluster in same VPC as backend
     - Enable encryption using AWS KMS
     - Configure TLS (global-bundle.pem already present in codebase)

### 20. Production AWS Cognito Configuration
- **What**: Set up production Cognito User Pool (separate from dev)
- **Blocker**: Requires AWS account access
- **Resolution**:
  1. Create new User Pool for production (do not reuse dev pool)
  2. Configure password policies, MFA settings
  3. Set up App Client without client secret (for mobile)
  4. Configure OAuth 2.0 redirect URIs for production
  5. Set up hosted UI domain
  6. Configure social identity providers (Google, Apple, Facebook) with production OAuth app credentials

### 21. Production S3 Configuration
- **What**: Set up production S3 buckets with proper access policies
- **Blocker**: Requires AWS account access
- **Resolution**:
  1. Create production bucket(s) with:
     - Server-side encryption (SSE-S3 or SSE-KMS)
     - Versioning enabled
     - Lifecycle policies for cost management
     - CORS configuration for allowed origins
  2. Create IAM role/user with minimal S3 permissions
  3. Set up CloudFront distribution for public media delivery

### 22. Production Domain + SSL
- **What**: Configure production domain and HTTPS
- **Blocker**: Requires domain registration and DNS access
- **Resolution**:
  1. Register domain (e.g., `api.muudhealth.com`) if not already owned
  2. Set up SSL certificate via AWS Certificate Manager (free) or Let's Encrypt
  3. Configure DNS records (A/CNAME) pointing to hosting provider
  4. Set up API Gateway or load balancer with SSL termination

### 23. Android Release Signing
- **What**: Configure keystore for signed APK/AAB release builds
- **Blocker**: Requires keystore generation (one-time) and secure storage
- **Resolution**:
  1. Generate keystore:
     ```bash
     keytool -genkey -v -keystore muud-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias muud
     ```
  2. Store keystore file securely (NOT in git)
  3. Add to `frontend/android/key.properties`:
     ```
     storePassword=<password>
     keyPassword=<password>
     keyAlias=muud
     storeFile=<path-to-keystore>
     ```
  4. **CRITICAL**: Back up the keystore — losing it means you cannot update the app on Play Store

### 24. iOS Provisioning Profiles + Certificates
- **What**: Configure Apple signing for App Store distribution
- **Blocker**: Requires Apple Developer Program membership ($99/year)
- **Resolution**:
  1. Enroll in [Apple Developer Program](https://developer.apple.com/programs/)
  2. Create App ID for `com.muudhealth.app` (or chosen bundle ID)
  3. Create Distribution Certificate
  4. Create App Store Provisioning Profile
  5. Configure Xcode signing in `frontend/ios/Runner.xcodeproj`
  6. Set up Fastlane `match` for team certificate sharing (optional but recommended)

### 25. Privacy Policy Creation
- **What**: Create legally compliant privacy policy for health data
- **Blocker**: Requires legal review for health data regulations (HIPAA, GDPR, CCPA)
- **Resolution**:
  1. Engage a privacy attorney familiar with health app regulations
  2. Key areas to cover:
     - What health data is collected (biometrics, mood, journal entries)
     - How data is stored and encrypted
     - Third-party data sharing (AWS, analytics providers)
     - Data retention and deletion policies
     - User rights (access, export, delete)
     - GDPR compliance (if serving EU users)
     - CCPA compliance (if serving California users)
     - Children's privacy (COPPA if under-13 users possible)
  3. Alternatively, use a privacy policy generator (Termly, iubenda) as a starting point, then have an attorney review

### 26. Terms of Service Creation
- **What**: Create legally compliant terms of service
- **Blocker**: Requires legal review
- **Resolution**:
  1. Engage an attorney (same one doing privacy policy)
  2. Key areas: user responsibilities, health disclaimer, limitation of liability, dispute resolution, account termination
  3. Must include a **medical disclaimer** — the app provides wellness tools, not medical advice

### 27. Medical Disclaimer Content
- **What**: Write health/medical disclaimers for app store listing and in-app display
- **Blocker**: Requires legal/medical compliance review
- **Resolution**:
  1. Standard disclaimer template:
     > "Muud Health is a wellness application and does not provide medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider with questions about a medical condition."
  2. Have legal counsel review and approve
  3. Place in: app store description, onboarding flow, settings screen, and about page

### 28. App Store Developer Account (Google Play)
- **What**: Set up Google Play Console account for publishing
- **Blocker**: Requires Google Play Developer account ($25 one-time fee)
- **Resolution**:
  1. Register at [play.google.com/console](https://play.google.com/console)
  2. Pay $25 registration fee
  3. Complete identity verification
  4. Create app listing for Muud Health
  5. Set up internal testing track for beta

### 29. App Store Developer Account (Apple)
- **What**: Set up App Store Connect for publishing
- **Blocker**: Requires Apple Developer Program (see Step 24)
- **Resolution**: Same as Step 24 — the Developer Program includes App Store Connect access

### 30. App Store Screenshots
- **What**: Prepare screenshots for all required device sizes
- **Blocker**: Requires running app on simulators/devices with production data and UI
- **Resolution**:
  1. Requires all UI features to be complete and polished
  2. Run app on simulators for each required size:
     - iPhone 6.7" (iPhone 15 Pro Max)
     - iPhone 6.1" (iPhone 15 Pro)
     - iPad Pro 12.9"
     - Android phone (various)
     - Android tablet
  3. Use Fastlane `snapshot` or Flutter `integration_test` + `screenshot` package
  4. Create 5-8 screenshots per device showing key features

### 31. TestFlight Beta Testing Program
- **What**: Distribute beta builds to test users via TestFlight
- **Blocker**: Requires Apple Developer account + signed iOS build
- **Resolution**:
  1. Complete Steps 24 and 29
  2. Archive and upload build to App Store Connect
  3. Set up TestFlight internal testing group
  4. Add beta tester emails
  5. Distribute build and collect feedback via TestFlight

### 32. Google Play Beta Testing
- **What**: Distribute beta builds via Google Play internal/closed testing
- **Blocker**: Requires Google Play Developer account + signed Android build
- **Resolution**:
  1. Complete Steps 23 and 28
  2. Build signed AAB: `flutter build appbundle`
  3. Upload to Play Console → Internal Testing track
  4. Add tester email addresses
  5. Distribute and collect feedback

### 33. App Store Submission (iOS)
- **What**: Submit final build to Apple App Store
- **Blocker**: Requires all previous iOS steps + App Review compliance
- **Resolution**:
  1. Complete all Phase 5 items
  2. Fill out App Store Connect metadata (description, keywords, categories, age rating)
  3. Upload final build
  4. Submit for App Review
  5. **Note**: Health apps may require additional review — be prepared to explain data usage

### 34. App Store Submission (Google Play)
- **What**: Submit final build to Google Play Store
- **Blocker**: Requires all previous Android steps + policy compliance
- **Resolution**:
  1. Complete all Phase 5 items
  2. Fill out Play Console listing (description, screenshots, categories)
  3. Complete Data Safety section (health data declarations)
  4. Upload signed AAB to Production track
  5. Submit for review

### 35-38. Production Environment Variables (4 steps)
- **What**: Configure all environment variables for production deployment
- **Blocker**: Each requires the corresponding service account/credentials
- **Resolution**: Consolidated list of all required production `.env` values:
  ```env
  # Server
  PORT=4000
  NODE_ENV=production

  # MongoDB
  MONGODB_URI=<production-connection-string>

  # AWS Cognito
  AWS_REGION=us-west-2
  COGNITO_USER_POOL_ID=<production-pool-id>
  COGNITO_CLIENT_ID=<production-client-id>
  COGNITO_DOMAIN=<production-cognito-domain>

  # AWS S3
  S3_BUCKET_NAME=<production-bucket>
  AWS_ACCESS_KEY_ID=<production-key>
  AWS_SECRET_ACCESS_KEY=<production-secret>

  # Firebase (Push Notifications)
  FIREBASE_SERVICE_ACCOUNT_KEY=<path-to-json>

  # Twilio (SMS)
  TWILIO_ACCOUNT_SID=<sid>
  TWILIO_AUTH_TOKEN=<token>
  TWILIO_PHONE_NUMBER=<number>

  # Mailgun (Email)
  MAILGUN_API_KEY=<key>
  MAILGUN_DOMAIN=<domain>

  # AI (if using Claude API)
  ANTHROPIC_API_KEY=<key>

  # Error Tracking
  SENTRY_DSN=<dsn>

  # App Config
  ALLOWED_ORIGINS=https://muudhealth.com,https://app.muudhealth.com
  JWT_ISSUER=https://cognito-idp.us-west-2.amazonaws.com/<pool-id>
  ```

### 39-42. Production Infrastructure Setup (4 steps)
- **What**: Provision and configure production servers, CDN, monitoring
- **Blocker**: Requires cloud account access and infrastructure decisions
- **Resolution**:
  1. **Hosting**: Choose between:
     - AWS ECS (Fargate) — serverless containers, auto-scaling, fits AWS ecosystem
     - Render — simple, already used in Build #8
     - Railway — easy deployment with GitHub integration
  2. **CDN**: CloudFront for S3 media delivery
  3. **Monitoring**: CloudWatch or Datadog for server/API monitoring
  4. **Scaling**: Redis for Socket.IO adapter (enables horizontal scaling)

### 43-46. VoiceOver/TalkBack Testing (4 steps)
- **What**: Test accessibility with native screen readers on real devices
- **Blocker**: Requires physical iOS device (VoiceOver) and Android device (TalkBack)
- **Resolution**:
  1. Test on iOS Simulator with Accessibility Inspector (partial — not full VoiceOver)
  2. Test on Android Emulator with TalkBack enabled
  3. For full testing: use physical devices
  4. Alternatively: use automated accessibility testing tools (`flutter_test` with `semantics` matchers)

### 47-50. User Acceptance Testing (4 steps)
- **What**: Real users testing the app in production-like environment
- **Blocker**: Requires beta testers, test devices, and staging environment
- **Resolution**:
  1. Recruit 10-20 beta testers (employees, friends, early adopters)
  2. Set up staging environment (Step 15)
  3. Distribute via TestFlight (iOS) + Internal Testing (Android)
  4. Create feedback collection mechanism (Google Form, in-app feedback, or dedicated tool like Instabug)
  5. Run 2-week beta period, collect and address feedback
  6. Iterate on critical issues before production launch

---

## Priority Order for Unblocking

| Priority | Steps | Impact | Effort |
|----------|-------|--------|--------|
| **P0 — Immediate** | 3, 4, 5 (AWS credentials) | Enables production deployment | Low — just provide existing credentials |
| **P1 — This Week** | 10-13 (Firebase) | Enables push notifications | Medium — create Firebase project |
| **P2 — This Week** | 1, 2 (Twilio/Mailgun) | Enables SMS/email | Medium — sign up for services |
| **P3 — This Sprint** | 15, 16 (hosting) | Enables staging/production deploy | Medium — choose and configure hosting |
| **P4 — This Sprint** | 6-9 (ring SDK) | Enables core hardware feature | High — requires hardware docs |
| **P5 — This Sprint** | 17 (AI decision) | Enables intelligence features | Low — make architectural decision |
| **P6 — Before Launch** | 23-34 (app store) | Enables distribution | Medium — accounts + legal review |
| **P7 — Before Launch** | 14, 25-27 (legal/compliance) | Enables compliant launch | High — requires professional services |
| **P8 — Post-Launch** | 18 (translations) | Enables international users | Medium — translation service |
| **P9 — Ongoing** | 43-50 (testing) | Ensures quality | Ongoing effort |

---

## Quick Wins (Unblock Multiple Steps)

1. **Create Firebase Project** → Unblocks Steps 10, 11, 12, 13 (4 steps)
2. **Provide AWS Credentials** → Unblocks Steps 3, 4, 5, 20, 21 (5 steps)
3. **Choose Hosting Platform** → Unblocks Steps 15, 16, 39-42 (6 steps)
4. **Enroll in Apple Developer Program** → Unblocks Steps 24, 29, 31, 33 (4 steps)
5. **Engage Legal Counsel** → Unblocks Steps 14, 25, 26, 27 (4 steps)

---

*Provide any of the above credentials or decisions and the corresponding steps can be executed immediately.*
