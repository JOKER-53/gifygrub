#!/usr/bin/env bash
# gifygrub::check_deps — verify ffmpeg (preferred) or imagemagick (fallback) is available
#
# Sets the global GIFYGRUB_BACKEND to "ffmpeg" or "imagemagick" for use by
# extract.sh, so the rest of the pipeline doesn't need to re-detect it.

GIFYGRUB_BACKEND=""

gifygrub::check_deps() {
    if command -v ffmpeg &> /dev/null; then
        GIFYGRUB_BACKEND="ffmpeg"
        return 0
    fi

    if command -v convert &> /dev/null; then
        GIFYGRUB_BACKEND="imagemagick"
        echo "warning: ffmpeg not found, falling back to imagemagick." >&2
        return 0
    fi

    echo "error: neither ffmpeg nor imagemagick (convert) is installed." >&2
    echo "       install one of them, e.g.:" >&2
    echo "         sudo pacman -S ffmpeg          # Arch/CachyOS" >&2
    echo "         sudo pacman -S imagemagick" >&2
    exit 1
}
