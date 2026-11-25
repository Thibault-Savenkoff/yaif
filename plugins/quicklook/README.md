# YAIF Quick Look thumbnails (macOS), installed by install.sh

`build.sh` builds a host app + a Quick Look thumbnail extension (swiftc, no Xcode project, ad-hoc
signed) into `~/Applications` and registers it; `install.sh` offers it on macOS. Finder thumbnails
confirmed on a real Mac (M4) on 2026-11-25. On macOS 27.3 (2026-11-12) Quick Look never launched it
(no log line, no crash; a stock Xcode extension failed the same way), and it works after the Mac's
later macOS updates (so most likely the OS; the code did not change). `build.sh --uninstall` removes it.

Decode check without Quick Look: `selftest.swift` (see the commands in the 2026-11-12 session):
`clang -c ../../libyaif/yaifdec.c -o /tmp/y.o && swiftc -parse-as-library -import-objc-header bridge.h Thumb.swift selftest.swift /tmp/y.o -framework QuickLookThumbnailing -framework CoreImage -framework AppKit -o /tmp/selftest && /tmp/selftest a.yaif out.png`
