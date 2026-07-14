#!/bin/sh
set -e

export PATH="$PATH:$HOME/flutter/bin"

echo "▶ Building Flutter iOS..."
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter build ios --release --no-codesign

echo "✓ pre_xcodebuild done"
