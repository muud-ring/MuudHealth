#!/usr/bin/env bash
# build-android.sh — Build Muud Health Android app
# Usage: ./scripts/build-android.sh [apk|appbundle]
set -euo pipefail

TARGET="${1:-appbundle}"
FRONTEND_DIR="$(cd "$(dirname "$0")/../frontend" && pwd)"

# Required env vars
: "${API_BASE_URL:?Set API_BASE_URL (e.g. https://api.muudhealth.com)}"
: "${COGNITO_DOMAIN:?Set COGNITO_DOMAIN (e.g. https://muud.auth.us-west-2.amazoncognito.com)}"
: "${COGNITO_CLIENT_ID:?Set COGNITO_CLIENT_ID}"

# Optional (have defaults in code)
COGNITO_REDIRECT_URI="${COGNITO_REDIRECT_URI:-muudhealth://callback}"
COGNITO_LOGOUT_URI="${COGNITO_LOGOUT_URI:-muudhealth://signout}"

DART_DEFINES=(
  "--dart-define=API_BASE_URL=${API_BASE_URL}"
  "--dart-define=COGNITO_DOMAIN=${COGNITO_DOMAIN}"
  "--dart-define=COGNITO_CLIENT_ID=${COGNITO_CLIENT_ID}"
  "--dart-define=COGNITO_REDIRECT_URI=${COGNITO_REDIRECT_URI}"
  "--dart-define=COGNITO_LOGOUT_URI=${COGNITO_LOGOUT_URI}"
)

cd "$FRONTEND_DIR"

echo "==> Installing Flutter dependencies..."
flutter pub get

if [ "$TARGET" = "appbundle" ]; then
  echo "==> Building Android App Bundle (AAB) for Play Store..."
  flutter build appbundle --release "${DART_DEFINES[@]}"
  echo "Output: build/app/outputs/bundle/release/app-release.aab"
elif [ "$TARGET" = "apk" ]; then
  echo "==> Building Android APK..."
  flutter build apk --release "${DART_DEFINES[@]}"
  echo "Output: build/app/outputs/flutter-apk/app-release.apk"
else
  echo "Unknown target: $TARGET (use apk or appbundle)"
  exit 1
fi
