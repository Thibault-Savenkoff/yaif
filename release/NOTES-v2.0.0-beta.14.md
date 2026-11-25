Fourteenth beta: **Windows fixes**: Tab completion, `install.ps1`, and Explorer thumbnails without administrator rights.

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **`yaif<Tab>` offers only `yaif.exe`.** The two PowerShell helper scripts (tab completion and its
  profile line) were next to `yaif.exe`, so PowerShell listed them as commands. They now live in a
  `scripts` folder of the install (setup, MSI, zip and `install.ps1`); an install over an earlier beta
  moves them.
- **`install.ps1` works again**: it failed with "is not in SHA256SUMS" because PowerShell read the checksum
  file as bytes. It also registers the Explorer thumbnail codec **for your account only**, so it needs no
  administrator rights at all.
- **The `-setup.exe` does the same in "only for me" mode**: the viewer codec is registered for your account
  instead of failing without administrator rights. "All users" is unchanged (and, as before, an
  administrator account sees the UAC prompt when the setup starts).
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
