#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: examine and transform a video file (ffmpeg, ffprobe, ExifTool).

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Video Tools"

ffmpeg=$(find_tool ffmpeg) || exit 1

src=$(ui_file "Video file to work on") || exit 0
name=$(basename "$src")
stem=${name%.*}

choice=$(ui_choice "Case: $(case_name)
File: $name
What do you want to do?" \
    "Play it" \
    "Technical report (streams, codecs, dates, GPS and other metadata)" \
    "Convert to MP4 (H.264 + AAC, plays everywhere)" \
    "Extract still frames" \
    "Keep only the moments with movement" \
    "Extract the audio track" \
    "Rotate" \
    "Cut a clip" \
    "Contact sheet (grid of thumbnails in one image)") || exit 0

if [[ $choice == Play* ]]; then
    ffplay=$(find_tool ffplay) || exit 1
    "$ffplay" -hide_banner -autoexit "$src" >/dev/null 2>&1
    exit 0
fi

run=$(new_run_dir video-tools "$name") || exit 1
{
    printf 'Source file: %s\n' "$src"
    printf 'Source SHA-256: %s\n' "$(sha256sum "$src" | cut -d' ' -f1)"
    printf 'Operation: %s\n' "$choice"
} >> "$run/command.txt"
ff=("$ffmpeg" -hide_banner -nostdin -y -i "$src")

case "$choice" in
    Technical*)
        ffprobe=$(find_tool ffprobe) || exit 1
        # Arguments reach the inner script as positional parameters.
        # shellcheck disable=SC2016
        run_logged "$run" "Reading $name" -- sh -c '"$1" -v error -show_format -show_streams -of json "$2" > "$3/ffprobe.json" && exiftool -a -G1 -s "$2" > "$3/exiftool.txt"' \
            argos "$ffprobe" "$src" "$run"
        ;;
    Convert*)
        run_logged "$run" "Converting $name" -- "${ff[@]}" -c:v libx264 -preset medium -crf 20 \
            -c:a aac -b:a 160k -movflags +faststart "$run/${stem}.mp4"
        ;;
    Extract\ still*)
        how=$(ui_choice "Which frames?" \
            "One frame every second" "One frame every 5 seconds" \
            "Only when the scene changes" "Every frame (many files)") || exit 0
        case "$how" in
            *"every second") filter="fps=1" ;;
            *"5 seconds") filter="fps=1/5" ;;
            Only*) filter="select='gt(scene,0.3)'" ;;
            *) filter="null" ;;
        esac
        mkdir -p "$run/frames"
        run_logged "$run" "Extracting frames from $name" -- "${ff[@]}" -vf "$filter" -fps_mode vfr \
            "$run/frames/${stem}_%05d.png"
        ;;
    Keep*)
        level=$(ui_choice "How much must change between frames to keep them?" \
            "Very little (quiet scenes, e.g. a parked car camera)" \
            "A moderate amount" \
            "A lot (busy scenes)") || exit 0
        case "$level" in Very*) threshold=0.002 ;; A\ moderate*) threshold=0.004 ;; *) threshold=0.01 ;; esac
        printf 'Scene-change threshold: %s\n' "$threshold" >> "$run/command.txt"
        run_logged "$run" "Condensing $name" -- "${ff[@]}" \
            -vf "select='gt(scene,$threshold)',setpts=N/(FRAME_RATE*TB)" -an \
            -c:v libx264 -crf 20 "$run/${stem}_movement.mp4"
        ;;
    Extract\ the*)
        format=$(ui_choice "Audio format" "MP3 (small)" "WAV (lossless, for analysis)") || exit 0
        if [[ $format == MP3* ]]; then
            run_logged "$run" "Extracting audio" -- "${ff[@]}" -vn -c:a libmp3lame -q:a 2 "$run/${stem}.mp3"
        else
            run_logged "$run" "Extracting audio" -- "${ff[@]}" -vn -c:a pcm_s16le "$run/${stem}.wav"
        fi
        ;;
    Rotate*)
        turn=$(ui_choice "Rotation" "90° clockwise" "90° counter-clockwise" "180°") || exit 0
        case "$turn" in 90°\ clockwise) filter="transpose=1" ;; 90°*) filter="transpose=2" ;; *) filter="hflip,vflip" ;; esac
        run_logged "$run" "Rotating $name" -- "${ff[@]}" -vf "$filter" -c:v libx264 -crf 20 -c:a copy \
            "$run/${stem}_rotated.mp4"
        ;;
    Cut*)
        start=$(ui_entry "Start time (seconds, or HH:MM:SS)" 0) || exit 0
        length=$(ui_entry "Length (seconds, or HH:MM:SS)" 30) || exit 0
        if [[ ! $start =~ ^[0-9:.]+$ || ! $length =~ ^[0-9:.]+$ ]]; then
            ui_error "Times must be seconds or HH:MM:SS."
            exit 1
        fi
        # Stream copy: no re-encoding, the clip keeps the original quality.
        run_logged "$run" "Cutting $name" -- "$ffmpeg" -hide_banner -nostdin -y -ss "$start" -i "$src" \
            -t "$length" -c copy "$run/${stem}_clip_${start//:/-}.${name##*.}"
        ;;
    Contact*)
        every=$(ui_entry "One thumbnail every how many seconds?" 10) || exit 0
        case "$every" in ''|*[!0-9]*) every=10 ;; esac
        run_logged "$run" "Building the contact sheet" -- "${ff[@]}" \
            -vf "fps=1/$every,scale=320:-1,tile=6x6" -frames:v 1 "$run/${stem}_contact_sheet.png"
        ;;
esac
report_outcome "$run" $? ffmpeg
finish_run "$run"
