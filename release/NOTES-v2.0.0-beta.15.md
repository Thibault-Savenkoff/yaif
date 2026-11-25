Fifteenth beta: **Finder thumbnails on macOS**, a safer `encode`, and cleaner Windows and uninstall layouts.

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **Finder shows `.yaif` thumbnails on macOS.** `install.sh` now offers to build a small Quick Look
  extension (a few seconds, signed ad hoc, installed in `~/Applications`; it needs the Xcode command line
  tools). Checked on an Apple Silicon Mac. Uninstalling removes it.
- **`yaif encode photo.cr3 photo.dng` is refused** instead of writing a `.yaif` file under a `.dng` name.
  The message points to `yaif convert` and `yaif decode`.
- **Windows zip**: the sample `.yaif` files are in a `samples` folder, as in the setup and the MSI (so also
  after `install.ps1`). An install over beta.14 or earlier keeps its old copies at the install root.
- **`install.sh --uninstall`** also removes its own folders once they are empty.
- **ImHex**: `imhex/yaif.hexpat` is a pattern that colours and names every part of a `.yaif` file
  (signature, chunks, header, coded regions).
- The Lisaac compiler that was republished under the same version was checked: identical output.
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
- **macOS Preview** has no `.yaif` support (no ImageIO plugin); Finder shows thumbnails.
- **Nautilus does not generate `.yaif` thumbnails** on GNOME, though Loupe opens the files and
  double-click works.
- No Windows on ARM build yet.

## Reporting

Please open an issue with the file, the command, and `yaif info file.yaif`.
