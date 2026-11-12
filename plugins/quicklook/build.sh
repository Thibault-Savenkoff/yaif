#!/bin/bash
# Builds YaifQuickLook.app (a host app + the Quick Look thumbnail extension) with swiftc/clang and
# signs it ad hoc, then registers it. Usage: plugins/quicklook/build.sh [--uninstall]
# Needs the Xcode (or Command Line Tools) toolchain. No Xcode project, no developer account.
set -eu
cd "$(dirname "$0")"
APP="$HOME/Applications/YaifQuickLook.app"
if [ "${1:-}" = --uninstall ]; then
  pluginkit -r "$APP/Contents/PlugIns/YaifThumb.appex" 2>/dev/null || true
  rm -rf "$APP"; qlmanage -r >/dev/null 2>&1 || true; echo "removed $APP"; exit 0
fi
VER=$(../../yaif --version 2>/dev/null | awk 'NR==1{print $2}' || true)
[ -n "$VER" ] || VER=$(sed -n 's/.*version:String := "\(.*\)"/\1/p' ../../yaif.li | head -1)
ARCH=$(uname -m)
T=$(mktemp -d)
B="$T/YaifQuickLook.app"
mkdir -p "$B/Contents/MacOS" "$B/Contents/PlugIns/YaifThumb.appex/Contents/MacOS"
sed "s/VERSION/$VER/" app.plist > "$B/Contents/Info.plist"
sed "s/VERSION/$VER/" appex.plist > "$B/Contents/PlugIns/YaifThumb.appex/Contents/Info.plist"
clang -O2 -c ../../libyaif/yaifdec.c -o "$T/yaifdec.o" -arch "$ARCH" -mmacosx-version-min=12.0
swiftc -O -target "$ARCH-apple-macos12.0" host.swift -o "$B/Contents/MacOS/YaifQuickLook"
swiftc -O -target "$ARCH-apple-macos12.0" -application-extension -parse-as-library \
  -module-name YaifThumb -import-objc-header bridge.h Thumb.swift "$T/yaifdec.o" \
  -framework QuickLookThumbnailing -framework CoreImage -framework CoreGraphics \
  -Xlinker -e -Xlinker _NSExtensionMain \
  -o "$B/Contents/PlugIns/YaifThumb.appex/Contents/MacOS/YaifThumb"
codesign --force --sign - --entitlements sandbox.entitlements "$B/Contents/PlugIns/YaifThumb.appex"
codesign --force --sign - "$B"
mkdir -p "$HOME/Applications"
rm -rf "$APP"; cp -R "$B" "$APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
pluginkit -a "$APP/Contents/PlugIns/YaifThumb.appex"
qlmanage -r >/dev/null 2>&1 || true
echo "installed $APP"
echo "if no thumbnail appears: System Settings > General > Login Items & Extensions > Quick Look, enable YAIF; then: killall Finder"
