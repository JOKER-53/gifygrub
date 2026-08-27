<div align="center">
  <img src="assets/logo.svg" width="140" alt="gifygrub logo" />

  # gifygrub

  **Turn any GIF into a curated static GRUB2 boot theme — no manual frame slicing.**

  [![License: MIT](https://img.shields.io/badge/License-MIT-a78bfa.svg)](LICENSE.md)
  [![Made for GRUB2](https://img.shields.io/badge/GRUB2-boot--theme-38bdf8.svg)](https://www.gnu.org/software/grub/)
  [![Platform](https://img.shields.io/badge/platform-Linux-f472b6.svg)](#requirements)
</div>

---

## What is gifygrub?

GRUB2 has no native GIF or video decoder, and — importantly — **no mechanism to animate a sequence of images at all**. GRUB's theme engine only supports static backgrounds and fixed 9-slice UI chrome; the only per-tick redraw hook is a 1Hz countdown timer, not a general animation clock. (We verified this directly against GRUB's C source — see [How it works](#how-it-works) below.)

So instead of promising animation GRUB can't deliver, **gifygrub extracts every frame of your GIF and helps you pick the best one as a static, high-quality boot background** — no more manually scrubbing through a GIF frame-by-frame or slicing images by hand.

```bash
gifygrub --input custom_cyberpunk.gif --theme cyber_neon
```

That extracts frames, auto-picks a representative one (the middle frame, by default), generates `theme.txt`, and installs it. Prefer a different frame? Preview with `--no-install` first, then pass `--frame N`.

## How it works

1. Checks for `ffmpeg` / `imagemagick`
2. Extracts the GIF into sequential `frame_*.png` assets (downscaled + palette-quantized to keep boot-partition footprint small)
3. Picks a representative frame (middle frame by default, or your `--frame N` choice)
4. Generates a static `desktop-image` theme.txt block
5. Installs the theme to `/boot/grub/themes/` and runs `update-grub`

**Why not animate?** We looked. GRUB2's `*_style` pixmap patterns (used for progress bars, menu boxes, etc.) load a fixed set of 9 named slices (`nw, n, ne, w, c, e, sw, s, se`) — not a frame sequence — and the only redraw timer that exists is tied to the boot countdown at ~1Hz, stopping the moment a key is pressed. There's no path to smooth GIF playback in stock GRUB without patching GRUB itself (a native C module — out of scope for this tool, see [Related project ideas](#related-project-ideas)).

## Why it exists

This project is the tooling companion to [grub-themes](https://github.com/KADHIRAVANEG/grub-themes), a GRUB2 theme collection. Turning a GIF into a usable, well-cropped static boot background by hand is tedious — gifygrub automates the extraction and selection so you get a good frame without scrubbing through a video player and manually exporting stills.

## Requirements

- Linux with GRUB2 (tested on CachyOS)
- `ffmpeg` or `imagemagick`
- Root/sudo access for the install step (writes to `/boot/grub/`)

## Installation

```bash
git clone https://github.com/KADHIRAVANEG/gifygrub.git
cd gifygrub
chmod +x bin/gifygrub
```

## Usage

```bash
gifygrub --input <path-to-gif> --theme <theme-name> [--fps N] [--frame N] [--no-install]
```

| Flag | Description | Default |
|---|---|---|
| `--input` | Path to the source `.gif` | required |
| `--theme` | Name for the generated theme | required |
| `--fps` | Frame extraction density — more candidate frames to choose from, not playback speed | `5` |
| `--frame` | Use frame N (1-indexed) instead of the auto-picked middle frame | auto (middle frame) |
| `--no-install` | Generate frames + `theme.txt` without installing to `/boot/grub/` | off |

**Tip:** run with `--no-install` first, look through the generated `frame_*.png` files, then re-run with `--frame N` for the one you like best.

## Related project ideas

True frame-by-frame animation would require a native GRUB module (`gif.mod`) hooking into GRUB's video pipeline directly — a real systems-programming project, not a shell script. That's a possible future/separate effort, not something gifygrub attempts.

## Related project

[grub-themes](https://github.com/KADHIRAVANEG/grub-themes) — a curated GRUB2 theme collection. Themes generated with gifygrub are welcome as submissions there.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md), [PULL_REQUEST.md](.github/PULL_REQUEST.md), and our [bug report template](.github/ISSUE_TEMPLATE/bugreport.md).

## Security

See [SECURITY.md](SECURITY.md) for how to report vulnerabilities.

## License

MIT — see [LICENSE.md](LICENSE.md).
