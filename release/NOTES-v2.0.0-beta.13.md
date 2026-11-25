Thirteenth beta: **a Windows installer in 20 languages, an `install.ps1`, LibRaw 0.22.3 and a few fixes.**

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **The Windows `-setup.exe` speaks your language**: English, French, Spanish, German, Italian,
  Portuguese (Brazil and Portugal), Dutch, Russian, Polish, Turkish, Japanese, Korean, Chinese
  (simplified and traditional), Arabic, Hindi, Indonesian, Vietnamese and Ukrainian, following the
  Windows display language. The translations of our own texts were not reviewed by native speakers:
  tell us what reads badly.
- **`install.ps1`, a per-user install for Windows without administrator rights**:
  `irm https://raw.githubusercontent.com/Thibault-Savenkoff/yaif/v2/install.ps1 | iex`. It checks the
  download's SHA-256, puts `yaif` on your PATH, sets up tab completion and adds an entry to
  Settings > Apps. It does not register the Explorer thumbnail codec (that needs administrator): use the
  `-setup.exe` for it.
- **LibRaw 0.22.3** (camera RAW), also built into the Windows package.
- **TIFF and DNG output keeps the camera maker notes** of Canon, Sony, Panasonic and similar files
  (their internal offsets were left pointing at the wrong place).
- **Qt viewers** (Gwenview and others): an animated `.yaif` loops, and a still image no longer repeats
  itself.
- **Web page** (once v2 reaches `main`): "Save image" keeps the EXIF in PNG and JPEG.
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
installer at all, or `install.ps1` (above) for your account only.

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
