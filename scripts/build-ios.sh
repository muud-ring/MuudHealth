#!/usr/bin/env bash
# build-ios.sh — Build Muud Health iOS app
# Usage: ./scripts/build-ios.sh [debug|release]
set -euo pipefail

MODE="${1:-release}"
FRONTEND_DIR="$(cd "$(dirname "$0")/../frontend" && pwd)"

# Required env vars (set these or pass via --dart-define)
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

if [ "$MODE" = "release" ]; then
  echo "==> Building iOS release (no codesign — use Xcode for signing)..."
  flutter build ios --release --no-codesign "${DART_DEFINES[@]}"
  echo ""
  echo "Build complete. Open frontend/ios/Runner.xcworkspace in Xcode to:"
  echo "  1. Select your team/provisioning profile"
  echo "  2. Archive and distribute to App Store Connect"
elif [ "$MODE" = "debug" ]; then
  echo "==> Building iOS debug..."
  flutter build ios --debug --no-codesign "${DART_DEFINES[@]}"
else
  echo "Unknown mode: $MODE (use debug or release)"
  exit 1
fi
