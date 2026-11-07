#!/bin/zsh
set -e

cd "$(dirname "$0")"

echo "🔨 Building LamhaTranslate in Release mode..."
swift build -c release

APP_NAME="Lamha"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp ".build/release/LamhaTranslate" "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
fi

cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.lamha.translator.mac</string>
    <key>CFBundleName</key>
    <string>Lamha Translate</string>
    <key>CFBundleDisplayName</key>
    <string>Lamha Translate</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2.0</string>
    <key>CFBundleVersion</key>
    <string>3</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Binhanaa. All rights reserved. MIT License.</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>Lamha Translate reads selected text to provide instant translation across macOS applications.</string>
</dict>
</plist>
EOF

codesign --force --deep --sign - "${APP_BUNDLE}"
echo "✅ Successfully built ${APP_BUNDLE}"
