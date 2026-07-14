#!/bin/sh
set -e

echo "▶ post_xcodebuild cleanup..."

# Remove temporary keychain if exists
security delete-keychain "$RUNNER_TEMP/app-signing.keychain-db" 2>/dev/null || true

echo "✓ post_xcodebuild done"
