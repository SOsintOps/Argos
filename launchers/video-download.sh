#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: download online video or audio with its metadata (yt-dlp).

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Video Download"

has() { grep -qx -- "$1" <<< "$2"; }

bin=$(find_tool yt-dlp "$ARGOS_BIN_DIR/yt-dlp") || exit 1

url=$(ui_entry "Case: $(case_name)
Address of the video, post or playlist") || exit 0
if ! is_url "$url"; then
    ui_error "\"$url\" is not an http(s) address."
    exit 1
fi

mode=$(ui_choice "What do you want to save?" \
    "Video with audio, best quality" \
    "Audio only (MP3)" \
    "Metadata only, no media") || exit 0

opts=$(ui_checklist "Also save" \
    "info|Technical metadata (JSON)|on" \
    "description|Description text|on" \
    "thumbnail|Thumbnail image|on" \
    "subs|Subtitles and captions, all languages|on" \
    "comments|Comments (can be slow)|off" \
    "playlist|The whole playlist, not just this item|off" \
    "session|Use my Firefox session (when the site asks to sign in or to confirm you are not a bot)|off") || exit 0

run=$(new_run_dir yt-dlp "$(sed -E 's#^https?://##; s#[/?].*##' <<< "$url")") || exit 1
printf 'Source URL: %s\n' "$url" >> "$run/command.txt"

args=("$url" --paths "$run" --output "%(uploader,channel|unknown)s_%(upload_date|nodate)s_%(title).80B [%(id)s].%(ext)s"
      --no-overwrites --newline --ignore-errors)
case "$mode" in
    Audio*) args+=(--extract-audio --audio-format mp3 --audio-quality 0) ;;
    Metadata*) args+=(--skip-download) ;;
    *) args+=(--format "bv*+ba/b" --merge-output-format mp4) ;;
esac
has info "$opts" && args+=(--write-info-json)
has description "$opts" && args+=(--write-description)
has thumbnail "$opts" && args+=(--write-thumbnail)
has subs "$opts" && args+=(--write-subs --write-auto-subs --sub-langs all)
has comments "$opts" && args+=(--write-comments)
if has playlist "$opts"; then args+=(--yes-playlist); else args+=(--no-playlist); fi
if has session "$opts"; then
    cookies=$(firefox_profile_cookies)
    if [ -z "$cookies" ]; then
        ui_error "No Firefox profile found. Open Firefox and sign in to the site with your research account, then try again."
        exit 1
    fi
    # yt-dlp takes the profile folder, not the cookie file.
    args+=(--cookies-from-browser "firefox:$(dirname "$cookies")")
fi

record_version "$run" yt-dlp "$bin" --version
run_logged "$run" "yt-dlp: $url" -- "$bin" "${args[@]}"
report_outcome "$run" $? yt-dlp
finish_run "$run"
