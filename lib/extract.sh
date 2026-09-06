#!/usr/bin/env bash
# gifygrub::extract_frame INPUT_GIF WORKDIR FRAME_INDEX RESOLUTION
#
# Extracts a single frame from INPUT_GIF into WORKDIR/background.png.

gifygrub::get_frame_count() {
    local input="$1"
    local count=0

    case "$GIFYGRUB_BACKEND" in
        ffmpeg)
            # -count_packets is fast, but sometimes nb_read_packets fails if stream has no index.
            count=$(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 "$input" | tr -d '\r\n')
            if [[ -z "$count" || "$count" == "N/A" ]]; then
                # Fallback to slower frame counting
                count=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 "$input" | tr -d '\r\n')
            fi
            ;;
        imagemagick)
            count=$($IMAGEMAGICK_IDENTIFY -format "%n\n" "$input" | head -n1)
            ;;
    esac

    if ! [[ "$count" =~ ^[0-9]+$ ]] || (( count == 0 )); then
        echo "error: could not determine frame count of $input" >&2
        exit 1
    fi
    echo "$count"
}

gifygrub::extract_frame() {
    local input="$1"
    local workdir="$2"
    local frame_index="$3"
    local resolution="$4"

    local output="${workdir}/background.png"

    case "$GIFYGRUB_BACKEND" in
        ffmpeg)
            gifygrub::_extract_ffmpeg "$input" "$output" "$frame_index" "$resolution"
            ;;
        imagemagick)
            gifygrub::_extract_imagemagick "$input" "$output" "$frame_index" "$resolution"
            ;;
    esac

    if [[ ! -f "$output" ]]; then
        echo "error: frame extraction failed" >&2
        exit 1
    fi

    local size_kb
    size_kb="$(du -sk "$output" 2>/dev/null | cut -f1)"
    echo "    extracted frame ${frame_index} (backend: ${GIFYGRUB_BACKEND}, ~${size_kb}KB)"

    if (( size_kb > 20480 )); then
        echo "warning: generated theme background is ~${size_kb}KB — this may be too large for a small ESP/boot partition." >&2
    fi
}

gifygrub::_extract_ffmpeg() {
    local input="$1"
    local output="$2"
    local frame_index="$3"
    local resolution="$4"

    # Scale filter part. If resolution is empty, no scaling.
    local vf_scale=""
    if [[ -n "$resolution" ]]; then
        local res_colon="${resolution/x/:}"
        vf_scale="scale=${res_colon}:force_original_aspect_ratio=decrease,pad=${res_colon}:(ow-iw)/2:(oh-ih)/2,"
    fi
    # Use select filter to get the exact frame. ffmpeg indices are 0-based.
    # We expect frame_index to be 1-based from the user logic, so subtract 1.
    local ffmpeg_idx=$(( frame_index - 1 ))
    
    ffmpeg -v error -y \
        -i "$input" \
        -vf "${vf_scale}select='eq(n\,${ffmpeg_idx})',format=pal8" \
        -vframes 1 \
        -compression_level 9 \
        "$output"
}

gifygrub::_extract_imagemagick() {
    local input="$1"
    local output="$2"
    local frame_index="$3"
    local resolution="$4"

    local im_idx=$(( frame_index - 1 ))
    local cmd=( $IMAGEMAGICK_CMD "${input}[${im_idx}]" )
    
    if [[ -n "$resolution" ]]; then
        cmd+=( -resize "${resolution}>" -background black -gravity center -extent "$resolution" )
    fi
    
    cmd+=( -colors 256 "$output" )
    
    "${cmd[@]}"
}
