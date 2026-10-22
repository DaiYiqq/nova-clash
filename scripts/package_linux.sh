#!/usr/bin/env bash
set -euo pipefail
APP_NAME="NovaClash"
VERSION="0.1.0"
BIN="nova_clash"
DIST="dist"
BUNDLE="build/linux/x64/release/bundle"
mkdir -p "$DIST"

# 1) tar.gz 便携包
tar -czf "$DIST/${APP_NAME}-${VERSION}-linux-x64.tar.gz" -C "$BUNDLE" .

# 2) .deb 安装包
DEB_ROOT="$DIST/.debroot"
rm -rf "$DEB_ROOT"
mkdir -p "$DEB_ROOT/DEBIAN" "$DEB_ROOT/usr/lib/${APP_NAME}" "$DEB_ROOT/usr/bin" "$DEB_ROOT/usr/share/applications" "$DEB_ROOT/usr/share/icons/hicolor/512x512/apps"
cp -r "$BUNDLE"/. "$DEB_ROOT/usr/lib/${APP_NAME}/"
cp assets/icon/icon.png "$DEB_ROOT/usr/share/icons/hicolor/512x512/apps/novaclash.png" 2>/dev/null || true

cat > "$DEB_ROOT/DEBIAN/control" <<EOF
Package: novaclash
Version: ${VERSION}
Section: net
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libblkid1, liblzma5
Maintainer: DaiYi <1703205607@qq.com>
Homepage: https://github.com/DaiYiqq/nova-clash
Description: NovaClash - 新一代跨平台代理客户端
EOF

cat > "$DEB_ROOT/usr/share/applications/novaclash.desktop" <<EOF
[Desktop Entry]
Name=${APP_NAME}
Comment=NovaClash 代理客户端
Exec=/usr/lib/${APP_NAME}/${BIN}
Icon=novaclash
Terminal=false
Type=Application
Categories=Network;
EOF

ln -sf "/usr/lib/${APP_NAME}/${BIN}" "$DEB_ROOT/usr/bin/novaclash"
dpkg-deb --build "$DEB_ROOT" "$DIST/${APP_NAME}-${VERSION}-linux-amd64.deb" >/dev/null
rm -rf "$DEB_ROOT"

# 3) 收集 Android 产物
cp build/app/outputs/flutter-apk/*.apk "$DIST/" 2>/dev/null || true
cp build/app/outputs/bundle/release/*.aab "$DIST/" 2>/dev/null || true

echo "--- dist/ ---"
ls -la "$DIST"
