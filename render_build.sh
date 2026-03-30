#!/bin/bash
# 1. Download the stable version of Flutter
git clone https://github.com/flutter/flutter.git -b stable

# 2. Add Flutter to the PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable web, get packages, and build the app!
flutter config --enable-web
flutter pub get
flutter build web --release