#!/bin/sh
set -e

install_flutter_sdk() {
  echo "▶ Downloading Flutter SDK..."
  FLUTTER_VERSION="3.44.4-stable"
  FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${FLUTTER_VERSION}.zip"
  mkdir -p "$HOME/flutter"
  curl -L "$FLUTTER_URL" -o "/tmp/flutter.zip"
  unzip -q "/tmp/flutter.zip" -d "$HOME"
  rm -f "/tmp/flutter.zip"
}

echo "▶ Checking Flutter installation..."
if command -v flutter >/dev/null 2>&1; then
  echo "▶ Flutter already installed: $(flutter --version | head -n 1)"
else
  if command -v brew >/dev/null 2>&1; then
    if brew list --cask flutter >/dev/null 2>&1; then
      echo "▶ Upgrading existing Flutter cask..."
      brew upgrade --cask flutter
    else
      echo "▶ Installing Flutter via Homebrew cask..."
      if ! brew install --cask flutter; then
        echo "⚠️ Homebrew cask install failed, falling back to manual Flutter download"
        install_flutter_sdk
      fi
    fi
  else
    install_flutter_sdk
  fi
fi

export PATH="$HOME/flutter/bin:$PATH"

echo "▶ Switching to stable Flutter channel..."
flutter channel stable
flutter upgrade

echo "▶ Installing dependencies..."
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

echo "▶ Generating code..."
dart run build_runner build --delete-conflicting-outputs

echo "▶ Generating iOS project artifacts for Xcode Cloud..."
flutter build ios --no-codesign

echo "✓ post_clone done"
