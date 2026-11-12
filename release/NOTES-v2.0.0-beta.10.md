Tenth beta: **a security and robustness pass over every decoder, and JPEG sources now convert correctly.**

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **JPEG sources are decoded correctly.** Earlier betas mis-decoded some JPEGs (a bug in the
  compiler's JPEG reader, fixed in Lisaac 0.7, which this build uses): colours could be off by a
  lot on some files. Re-encode JPEGs you converted with beta.9 or older if you care about exactness.
  The web converter has the same fix.
- **Crafted or corrupt files can no longer crash the decoders or hang them.** Fixed in the CLI, the
  C library, the JavaScript decoder, the Windows codec and the viewer plugins: size overflows,
  oversized headers on tiny files (minutes of CPU), ICC/EXIF/TIFF buffer overruns, unbounded loops
  in the HEIC metadata reader. Images above 500 Mpx are refused on Windows (32-bit `long`).
- **Encoder:** a worker that fails now makes the command fail instead of printing "Done"; sources
  over 65535 px are refused; the HDR gain map uses the same quality as the main image.
- **Update check:** `beta.10` is now seen as newer than `beta.9` (it was the reverse).
- **Installers:** the Windows installers no longer overwrite a long `PATH` with a single entry; the
  MSI removes the PowerShell profile line; a failed `makensis`/`wixl` fails the build; `install.sh`
  no longer removes the old NOVA before the YAIF download is verified, finds Homebrew libraries on
  Apple Silicon (HEIC, WebP, RAW, AVIF), and reports failed plugin installs; the zsh `PATH` line
  is added when needed; the Dolphin uninstall keeps your other thumbnailers.
- **Dependencies updated:** libheif 1.23.7, aom 3.15.3, libavif 1.4.2. Files are unchanged.
- **Web page and shell:** bash completion quotes file names with spaces; re-choosing the same file
  works; EXIF orientation is kept when metadata is stripped.
- Files from earlier betas, and this one, open as before.

## Install

Linux (x86_64 and arm64) and macOS (universal):

```sh
curl -fsSL https://raw.githubusercontent.com/Thibault-Savenkoff/yaif/v2/install.sh | bash
```

`--system` installs into `/usr/local`, `--no-plugins` skips the viewers, `-y` skips every prompt.
From a downloaded archive, no network: unpack it and run `./install.sh` inside, or
`install.sh --from yaif-<version>-<os>-<arch>.tar.gz`. To remove everything it installed, and
nothing else:

```sh
bash ~/.local/share/yaif/install.sh --uninstall     # add --system or --prefix DIR if you installed with it
```

Windows (64-bit): the `-setup.exe`, or the `.msi` for deployment tools, or the `.zip` for no
installer at all.

**Verify a download** against `SHA256SUMS` (attached, and listed below):

```sh
sha256sum -c SHA256SUMS --ignore-missing
```

Browser: [the web page](https://thibault-savenkoff.github.io/yaif/) still runs v1 until v2 reaches
`main`.

## Known limits

- The Windows installers are **not code-signed**, so SmartScreen shows "unknown publisher", and
  Defender may report `Trojan:Win32/Wacatac.C!ml` — a machine-learning false positive on unsigned
  NSIS installers. Each new build is judged afresh.
- **Windows Photos** and the **iOS Photos** app accept no third-party codec: `.yaif` opens in
  Windows Photo Viewer instead, and shows blank in Photos.
- **macOS has no Finder or Quick Look support** — the CLI works; a native ImageIO plugin is not
  written yet.
- **Nautilus does not generate `.yaif` thumbnails** on GNOME, though Loupe opens the files and
  double-click works.
- No Windows on ARM build yet.

## Reporting

Please open an issue with the file, the command, and `yaif info file.yaif`.
