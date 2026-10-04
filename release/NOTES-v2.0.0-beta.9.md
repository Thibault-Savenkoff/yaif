Ninth beta: **no more coloured fringes around edges in strongly compressed photos.**

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **Lossy photos: colour fringes removed.** At low quality (`-q 50` to `-q 85`), dark text and sharp
  edges could get green, red or blue halos. The decoder now smooths the colour planes along the
  edges of the brightness plane, which removes them. Files are the same size; the default `-q 90` is
  not affected and its files are unchanged.
- **Files written by earlier betas still open**, pixel for pixel as before. Lossy files written
  below `-q 85` by this one need beta.9 or later: an older `yaif` refuses them instead of showing
  them wrong.
- **Building from source uses 2 compile jobs by default** (the Qt/KDE plugins and the HEIC library
  in `install.sh` and `build.sh`), so it no longer runs out of memory on small machines. Faster on a
  big one: `JOBS=8 ./build.sh`.
- **Web page** (once v2 reaches `main`): installable as an app that converts offline, and choosing
  or dropping a `.yaif` file works again.

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
