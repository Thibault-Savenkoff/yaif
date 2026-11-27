Seventeenth beta: **the `yaif` command speaks 18 languages**.

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **`yaif` messages in your language.** Help, errors, progress and the "Done" line follow your system
  language: French, Spanish, German, Italian, Portuguese (Brazil and Portugal), Dutch, Russian,
  Polish, Turkish, Japanese, Korean, Chinese (Simplified and Traditional), Hindi, Indonesian,
  Vietnamese and Ukrainian. Numbers follow the language too (`25 271 octets, 127,9 %`). Set
  `YAIF_LANG=en` (or any code above) to force one; anything else falls back to English.
  Only French has been read by a human; the others are unreviewed translations, and corrections
  are welcome. Arabic is written but not enabled: terminals do not shape it yet.
- Not translated on purpose: `yaif --version`, option and chunk names, the technical output of
  `yaif info`, and the install scripts (English for now).
- Internal: a compiler warning about the `rgba` name is gone.
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
