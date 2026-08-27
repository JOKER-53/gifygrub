#!/usr/bin/env bash
# gifygrub::extract_frames INPUT_GIF WORKDIR FPS
#
# Extracts INPUT_GIF into sequential frame_*.png files inside WORKDIR,
# using whichever backend gifygrub::check_deps selected (GIFYGRUB_BACKEND).

gifygrub::extract_frames() {
    local input="$1"
    local workdir="$2"
    local fps="$3"

    case "$GIFYGRUB_BACKEND" in
        ffmpeg)
            gifygrub::_extract_ffmpeg "$input" "$workdir" "$fps"
            ;;
        imagemagick)
            gifygrub::_extract_imagemagick "$input" "$workdir" "$fps"
            ;;
        *)
            echo "error: no extraction backend selected (call gifygrub::check_deps first)" >&2
            exit 1
            ;;
    esac

    local frame_count
    frame_count="$(find "$workdir" -maxdepth 1 -name 'frame_*.png' | wc -l)"

    if (( frame_count == 0 )); then
        echo "error: frame extraction produced 0 frames" >&2
        exit 1
    fi

    local total_size
    total_size="$(du -sh "$workdir" 2>/dev/null | cut -f1)"

    echo "    extracted ${frame_count} frames (backend: ${GIFYGRUB_BACKEND}, ~${total_size} total)"

    # 20MB is a rough soft ceiling — many ESPs are small, and a single
    # theme eating a large chunk of it is worth flagging loudly.
    local size_kb
    size_kb="$(du -sk "$workdir" 2>/dev/null | cut -f1)"
    if (( size_kb > 20480 )); then
        echo "warning: generated theme is ~${total_size} — this may be too large for a small ESP/boot partition." >&2
        echo "warning: consider a lower --fps or a shorter/lower-res source GIF." >&2
    fi
}

gifygrub::_extract_ffmpeg() {
    local input="$1"
    local workdir="$2"
    local fps="$3"

    # Cap width at 640px — GRUB renders at boot-screen resolution, not
    # desktop resolution, so source-quality frames are wasted space.
    # format=pal8 quantizes to an 8-bit palette (matches the GIF's own
    # native color depth) which compresses far better than 24-bit PNG
    # for gradient/photographic content.
    ffmpeg -v error -y \
        -i "$input" \
        -vf "fps=${fps},scale='min(640,iw)':-2,format=pal8" \
        -compression_level 9 \
        "${workdir}/frame_%04d.png"
}

gifygrub::_extract_imagemagick() {
    local input="$1"
    local workdir="$2"
    local fps="$3"

    # imagemagick's `convert` extracts every native GIF frame; it doesn't
    # resample to a target fps the way ffmpeg does, so we extract natively
    # then thin the frame set down to approximate the requested fps.
    # Cap width at 640px and quantize to 256 colors for the same
    # boot-partition-size reasons as the ffmpeg path above.
    convert "$input" -resize '640x>' -colors 256 "${workdir}/raw_%04d.png"

    local native_count
    native_count="$(find "$workdir" -maxdepth 1 -name 'raw_*.png' | wc -l)"

    # Assume a typical GIF plays at ~10fps natively; keep every Nth frame
    # to approximate the requested fps without needing to parse per-frame
    # delay values here.
    local native_fps=10
    local step=$(( native_fps / fps ))
    (( step < 1 )) && step=1

    local i=0
    local out_index=1
    for f in "${workdir}"/raw_*.png; do
        if (( i % step == 0 )); then
            printf -v out_name "frame_%04d.png" "$out_index"
            mv "$f" "${workdir}/${out_name}"
            (( out_index++ ))
        else
            rm -f "$f"
        fi
        (( i++ ))
    done

    (void=$native_count) # native_count only used for the thinning ratio above
}
