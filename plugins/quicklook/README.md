# YAIF Quick Look thumbnails (macOS), experimental, not installed by install.sh

`build.sh` builds a host app + a Quick Look thumbnail extension (swiftc, no Xcode project, ad-hoc
signed) into `~/Applications` and registers it. It compiles, signs, registers and is approved
(`pluginkit -mA` shows `+`), but **on macOS 27.3 Quick Look never launches it** (no log line, no
crash). A stock Xcode "Thumbnail Extension" (QLSupportedContentTypes = org.yaif.image) fails the
same way on that machine, so the cause is probably the OS or that setup, not this code.
Retry on another Mac / a later macOS. `build.sh --uninstall` removes it.
