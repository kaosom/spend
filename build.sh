#!/bin/bash
# Install Flutter SDK for Vercel

echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running flutter build web..."
flutter build web --release
