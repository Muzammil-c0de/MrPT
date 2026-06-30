#!/usr/bin/env bash
set -e

# Vercel does not ship Flutter, so fetch the SDK (full clone — a shallow
# clone breaks "flutter --version" with "Unable to determine engine version").
if [ -d flutter ]; then
  cd flutter && git pull && cd ..
else
  git clone https://github.com/flutter/flutter.git -b stable
fi

flutter/bin/flutter --version
flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get
flutter/bin/flutter build web --release
