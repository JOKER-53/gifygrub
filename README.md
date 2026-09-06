<div align="center">
  <img src="assets/logo.svg" width="140" alt="gifygrub logo" />

  # gifygrub

  **Turn any GIF into a static GRUB2 boot theme.**

  [![License: MIT](https://img.shields.io/badge/License-MIT-a78bfa.svg)](LICENSE.md)
  [![Made for GRUB2](https://img.shields.io/badge/GRUB2-boot--theme-38bdf8.svg)](https://www.gnu.org/software/grub/)
  [![Platform](https://img.shields.io/badge/platform-Linux-f472b6.svg)](#requirements)
</div>

---

## What is gifygrub?

GRUB2 has no native GIF or video decoder — it can only display a sequence of static images, and lacks support for actual frame animation. Getting a custom boot background from a GIF usually means manually extracting frames and selecting the best one.

**gifygrub automates all of that.** Point it at a `.gif`, and it:

1. Checks for `ffmpeg` or `imagemagick`
2. Automatically determines the frame count and selects a target frame (the middle frame by default).
3. Extracts and optionally scales that single frame to create a `background.png`.
4. Generates a GRUB-compatible `theme.txt` configuration.

```bash
gifygrub --input custom_cyberpunk.gif --theme cyber_neon --resolution 1920x1080
```

That's it — one command, static boot screen generated.

## Why it exists

This project is the tooling companion to [grub-themes](https://github.com/KADHIRAVANEG/grub-themes), a GRUB2 theme collection. Building themes by hand kept hitting the same wall: picking frames and generating configuration is tedious. gifygrub exists so nobody has to do that by hand again.

## Requirements

- Linux with GRUB2
- `ffmpeg` + `ffprobe` (preferred) or `imagemagick`
- Root/sudo access for the install step

## Installation

```bash
git clone https://github.com/KADHIRAVANEG/gifygrub.git
cd gifygrub
sudo ./install.sh
```

## Usage

```bash
gifygrub --input <path-to-gif> --theme <theme-name> [--frame N] [--resolution WxH]
```

| Flag | Description |
|---|---|
| `--input` | Path to the source `.gif` (required) |
| `--theme` | Name for the generated theme (required) |
| `--frame` | Use frame N (1-indexed) as the background instead of the auto-picked middle frame |
| `--resolution` | Target resolution (e.g., 1920x1080). If omitted, the GIF's original resolution is used |

## Limitations

GRUB's `gfxmenu` render loop is not a real animation timer — it's tied to the boot countdown tick. 
- True 30fps playback is **not achievable**.
- gifygrub generates a **static background** from the GIF rather than attempting to trick GRUB into a flipbook effect, which bloats the boot partition.

## Related project

[grub-themes](https://github.com/KADHIRAVANEG/grub-themes) — a curated GRUB2 theme collection. Themes generated with gifygrub are welcome as submissions there.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md), [PULL_REQUEST.md](.github/PULL_REQUEST.md), and our [bug report template](.github/ISSUE_TEMPLATE/bugreport.md).

## Security

See [SECURITY.md](SECURITY.md) for how to report vulnerabilities.

## License

MIT — see [LICENSE.md](LICENSE.md).
