Eighteenth beta: **the install scripts speak 18 languages too, and Nautilus shows thumbnails**.

Still a **beta**: `.yaif` files written by this build are not guaranteed to be readable by v2.0.0
final, and **v1 and v2 files are not compatible** either way.

## What changed

- **`install.sh`, `build.sh` and `install.ps1` in your language.** Questions, progress and errors follow
  your system language (same 18 languages as the `yaif` command: French, Spanish, German, Italian,
  Portuguese, Dutch, Russian, Polish, Turkish, Japanese, Korean, Chinese, Hindi, Indonesian,
  Vietnamese, Ukrainian). `YAIF_LANG=en` (or another code) forces one. The answer to a question is
  still `y`; on Windows the choices are still the letters `M` and `A`. On Linux and macOS a UTF-8
  locale is needed, otherwise the scripts stay in English.
- **Windows `install.bat`** no longer asks in English first: it starts `install.ps1`, which asks
  "me only or all users" in the Windows display language.
- **GNOME / Nautilus thumbnails now work** (Files shows `.yaif` previews). Nautilus generates them in a
  sandbox that only sees `/usr`, where the `.yaif` file type was not registered; the glycin step of
  `install.sh` now registers it system-wide. To fix an existing install without reinstalling:
  `sudo cp plugins/mime/yaif.xml /usr/share/mime/packages/ && sudo update-mime-database /usr/share/mime`,
  then `rm -rf ~/.cache/thumbnails/fail; nautilus -q`.
- Only French has been read by a human; the others are unreviewed translations, corrections welcome.
- Not translated on purpose: `yaif --version`, option names, command lines shown to copy.
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
- No Windows on ARM build yet.

## Reporting

Please open an issue with the file, the command, and `yaif info file.yaif`.
