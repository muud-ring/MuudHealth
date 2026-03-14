#!/bin/bash
set -euo pipefail

# Only run in remote (web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Ensure Flutter is on PATH (check common install locations)
for flutter_dir in "$HOME/flutter/bin" "/home/user/flutter/bin" "/usr/local/flutter/bin"; do
  if [ -d "$flutter_dir" ]; then
    export PATH="$flutter_dir:$PATH"
    break
  fi
done

# Install backend dependencies (Node.js)
if [ -f "$PROJECT_DIR/Backend/package.json" ]; then
  cd "$PROJECT_DIR/Backend"
  npm install --no-audit --no-fund
fi

# Install frontend dependencies (Flutter)
if [ -f "$PROJECT_DIR/frontend/pubspec.yaml" ]; then
  cd "$PROJECT_DIR/frontend"
  flutter pub get
fi
