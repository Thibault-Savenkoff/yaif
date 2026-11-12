# YAIF Quick Look thumbnails (macOS), experimental, not installed by install.sh

`build.sh` builds a host app + a Quick Look thumbnail extension (swiftc, no Xcode project, ad-hoc
signed) into `~/Applications` and registers it. It compiles, signs, registers and is approved
(`pluginkit -mA` shows `+`), but **on macOS 27.3 Quick Look never launches it** (no log line, no
crash). A stock Xcode "Thumbnail Extension" (QLSupportedContentTypes = org.yaif.image) fails the
same way on that machine, so the cause is probably the OS or that setup, not this code.
Retry on another Mac / a later macOS. `build.sh --uninstall` removes it.

Decode check without Quick Look: `selftest.swift` (see the commands in the 2026-11-12 session):
`clang -c ../../libyaif/yaifdec.c -o /tmp/y.o && swiftc -parse-as-library -import-objc-header bridge.h Thumb.swift selftest.swift /tmp/y.o -framework QuickLookThumbnailing -framework CoreImage -framework AppKit -o /tmp/selftest && /tmp/selftest a.yaif out.png`
