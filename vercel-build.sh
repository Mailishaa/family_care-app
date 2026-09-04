#!/bin/bash

set -e

echo "Installing Flutter..."

git clone --depth 1 --branch 3.41.4 https://github.com/flutter/flutter.git /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release
