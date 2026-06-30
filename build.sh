#!/usr/bin/env bash
set -e

# Pin the exact Flutter stable revision this project was built against
# (see .metadata). Avoids version drift on Vercel and guarantees the SDK
# satisfies pubspec.lock (dart >=3.10.7, flutter >=3.38.0).
FLUTTER_REV="3b62efc2a3da49882f43c372e0bc53daef7295a6"

# Vercel does not ship Flutter. Full clone (a shallow clone breaks
# "flutter --version" with "Unable to determine engine version").
if [ ! -d flutter ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi
cd flutter
git fetch --tags origin
git checkout "$FLUTTER_REV"
cd ..

flutter/bin/flutter --version
flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get
flutter/bin/flutter build web --release
