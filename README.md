<div align="center">
  <img src="assets/logo.svg" width="140" alt="gifygrub logo" />

  # gifygrub

  **Turn any GIF into an animated GRUB2 boot theme — no manual frame slicing.**

  [![License: MIT](https://img.shields.io/badge/License-MIT-a78bfa.svg)](LICENSE.md)
  [![Made for GRUB2](https://img.shields.io/badge/GRUB2-boot--theme-38bdf8.svg)](https://www.gnu.org/software/grub/)
  [![Platform](https://img.shields.io/badge/platform-Linux-f472b6.svg)](#requirements)
</div>

---

## What is gifygrub?

GRUB2 has no native GIF or video decoder — it can only display a sequence of static images. Getting a "boot animation" today means manually extracting frames, writing raw `theme.txt` image blocks, and hand-tuning delays.

**gifygrub automates all of that.** Point it at a `.gif`, and it:

1. Checks for `ffmpeg` / `imagemagick`
2. Extracts the GIF into sequential `frame_*.png` assets
3. Computes a GRUB-realistic frame delay (GRUB's render loop can't hit true video framerates — gifygrub caps and warns accordingly)
4. Generates the `+ image { file = "frame_*.png" }` block in `theme.txt`
5. Installs the theme to `/boot/grub/themes/` and runs `update-grub`

```bash
gifygrub --input custom_cyberpunk.gif --theme cyber_neon --fps 8
```

That's it — one command, animated boot screen.

## Why it exists

This project is the tooling companion to [grub-themes](https://github.com/KADHIRAVANEG/grub-themes), a GRUB2 theme collection. Building themes by hand kept hitting the same wall: turning a GIF into GRUB-compatible frames is tedious and error-prone. gifygrub exists so nobody has to do that by hand again.

## Requirements

- Linux with GRUB2 (tested on CachyOS)
- `ffmpeg` or `imagemagick`
- Root/sudo access for the install step (writes to `/boot/grub/`)

## Installation

```bash
git clone https://github.com/KADHIRAVANEG/gifygrub.git
cd gifygrub
./install.sh
```

## Usage

```bash
gifygrub --input <path-to-gif> --theme <theme-name> [--fps N] [--no-install]
```

| Flag | Description | Default |
|---|---|---|
| `--input` | Path to the source `.gif` | required |
| `--theme` | Name for the generated theme | required |
| `--fps` | Target frame rate (capped ~5–10fps — see [Limitations](#limitations)) | `5` |
| `--no-install` | Generate frames + `theme.txt` without installing to `/boot/grub/` | off |

## Limitations

GRUB's `gfxmenu` render loop is not a real animation timer — it's tied to the boot countdown tick, not a video-style frame clock. This means:

- True 30fps playback is **not achievable**; gifygrub caps suggested fps and warns above realistic thresholds
- Every frame is stored as an uncompressed PNG in the boot partition — long/high-fps clips bloat the ESP fast
- Results are a **flipbook effect**, not smooth video

See [the project wiki](../../wiki) for details on how GRUB's frame-cycling actually works under the hood.

## Related project

[grub-themes](https://github.com/KADHIRAVANEG/grub-themes) — a curated GRUB2 theme collection. Themes generated with gifygrub are welcome as submissions there.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md), [PULL_REQUEST.md](.github/PULL_REQUEST.md), and our [bug report template](.github/ISSUE_TEMPLATE/bugreport.md).

## Security

See [SECURITY.md](SECURITY.md) for how to report vulnerabilities.

## License

MIT — see [LICENSE.md](LICENSE.md).
