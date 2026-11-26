Sixteenth beta: **the Windows zip installs itself**, and **ImHex gets the YAIF pattern** from the installers.

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **Windows zip: `install.bat`.** Unzip, double-click it, choose *me only* (no administrator rights: PATH,
  Tab completion, Explorer thumbnails for your account) or *all users* (asks for administrator rights:
  `C:\Program Files\YAIF`, machine PATH, the codec for every account, Tab completion for every account at
  its next logon). Refusing the administrator prompt installs nothing. `uninstall.bat`, or Settings >
  Apps, removes it. `install.ps1` does the same from the unzipped folder, and still installs the latest
  release when piped to `iex`.
- **ImHex pattern installed for you.** `install.sh` (Linux Flatpak or native, macOS) and the Windows
  `install.bat` copy `yaif.hexpat` into ImHex's patterns folder when ImHex is there; `install.sh
  --uninstall` removes it.
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
