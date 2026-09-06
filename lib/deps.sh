#!/usr/bin/env bash
# gifygrub::check_deps — verify ffmpeg (preferred) or imagemagick (fallback) is available
#
# Sets the global GIFYGRUB_BACKEND to "ffmpeg" or "imagemagick" for use by
# extract.sh, so the rest of the pipeline doesn't need to re-detect it.

GIFYGRUB_BACKEND=""
IMAGEMAGICK_CMD=""
IMAGEMAGICK_IDENTIFY=""

gifygrub::check_deps() {
    if command -v ffmpeg &> /dev/null && command -v ffprobe &> /dev/null; then
        GIFYGRUB_BACKEND="ffmpeg"
        return 0
    fi

    if command -v magick &> /dev/null; then
        GIFYGRUB_BACKEND="imagemagick"
        IMAGEMAGICK_CMD="magick"
        IMAGEMAGICK_IDENTIFY="magick identify"
        echo "warning: ffmpeg/ffprobe not found, falling back to imagemagick (magick)." >&2
        return 0
    fi

    if command -v convert &> /dev/null && command -v identify &> /dev/null; then
        GIFYGRUB_BACKEND="imagemagick"
        IMAGEMAGICK_CMD="convert"
        IMAGEMAGICK_IDENTIFY="identify"
        echo "warning: ffmpeg/ffprobe not found, falling back to imagemagick (convert)." >&2
        return 0
    fi

    echo "error: neither ffmpeg/ffprobe nor imagemagick is installed." >&2
    echo "       install one of them, e.g.:" >&2
    echo "         sudo pacman -S ffmpeg          # Arch/CachyOS" >&2
    echo "         sudo pacman -S imagemagick" >&2
    exit 1
}
