#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: download and examine public Instagram profiles.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Instagram"

is_ig_name() { [[ $1 =~ ^[A-Za-z0-9._]{1,30}$ ]]; }

# Returns 1 when the user cancels, 2 when the value is invalid.
ask_profile() {
    local value
    value=$(ui_entry "$1 — Instagram username (without @)") || return 1
    value=${value#@}
    value=${value#https://www.instagram.com/}
    value=${value%/}
    if ! is_ig_name "$value"; then
        ui_error "\"$value\" is not a valid Instagram username."
        return 2
    fi
    printf '%s\n' "$value"
}

has() { grep -qx -- "$1" <<< "$2"; }

# firefox_cookies: the most recently used Firefox cookie database. Firefox
# keeps profiles in different places for the .deb, the snap and newer
# releases that follow the XDG layout.
firefox_cookies() {
    local root
    for root in "$HOME/snap/firefox/common/.mozilla/firefox" "$HOME/snap/firefox/common/.config/mozilla/firefox"                 "$HOME/.mozilla/firefox" "$HOME/.config/mozilla/firefox"; do
        [ -d "$root" ] && find "$root" -maxdepth 2 -name cookies.sqlite -printf '%T@ %p
'
    done 2>/dev/null | sort -rn | head -n 1 | cut -d' ' -f2-
}

instaloader_run() {
    local profile=$1 bin opts run args cookies
    bin=$(find_tool instaloader "$ARGOS_BIN_DIR/instaloader") || return 1
    opts=$(ui_checklist "Instaloader — what to download" \
        "posts|Posts (pictures, videos and captions)|on" \
        "reels|Reels|off" \
        "tagged|Posts where the profile is tagged|off" \
        "novideo|Pictures only, skip videos|off" \
        "session|Use my Instagram session from Firefox (needed for stories, highlights, comments, geotags and private profiles you follow)|off" \
        "stories|Stories (needs the session)|off" \
        "highlights|Highlights (needs the session)|off" \
        "comments|Comments (needs the session)|off" \
        "geotags|Geotags (needs the session)|off") || return 0

    run=$(new_run_dir instaloader "$profile") || return 1
    args=("$profile" --dirname-pattern "$run/{profile}" --no-compress-json --sanitize-paths)
    has posts "$opts" || args+=(--no-posts)
    has reels "$opts" && args+=(--reels)
    has tagged "$opts" && args+=(--tagged)
    has novideo "$opts" && args+=(--no-videos)
    if has session "$opts"; then
        # Reads the cookies of the instagram.com login in Firefox: no password
        # ever passes through Argos.
        cookies=$(firefox_cookies)
        if [ -z "$cookies" ]; then
            ui_error "No Firefox profile found. Open Firefox, log in to instagram.com with your research account, then try again."
            return 1
        fi
        args+=(--load-cookies firefox --cookiefile "$cookies")
        has stories "$opts" && args+=(--stories)
        has highlights "$opts" && args+=(--highlights)
        has comments "$opts" && args+=(--comments)
        has geotags "$opts" && args+=(--geotags)
    elif grep -qxE 'stories|highlights|comments|geotags' <<< "$opts"; then
        ui_warn "Stories, highlights, comments and geotags need the Firefox session: they will be skipped."
    fi
    record_version "$run" instaloader "$bin" --version
    run_logged "$run" "Instaloader: $profile" -- env -C "$run" "$bin" "${args[@]}"
    report_outcome "$run" $? Instaloader
    finish_run "$run"
}

toutatis_run() {
    local profile=$1 bin session run
    bin=$(find_tool toutatis "$ARGOS_BIN_DIR/toutatis") || return 1
    session=$(ui_secret "Toutatis — your Instagram sessionid cookie (Firefox: Web Developer Tools > Storage > Cookies)") || return 0
    if [ -z "$session" ]; then
        ui_error "Toutatis needs a session ID."
        return 1
    fi
    ARGOS_SECRETS+=("$session")
    run=$(new_run_dir toutatis "$profile") || return 1
    run_logged "$run" "Toutatis: $profile" -- "$bin" -u "$profile" -s "$session"
    report_outcome "$run" $? Toutatis
    # Toutatis does not print the session ID; scrub the log in case a future
    # version does.
    sed -i "s/$(printf '%s' "$session" | sed 's/[][\/.*^$]/\\&/g')/<redacted>/g" "$run/output.log"
    finish_run "$run"
    [ "$ARGOS_UI" = zenity ] && ui_text_file "$run/output.log"
}

choice=$(ui_choice "Case: $(case_name)
Which tool?" \
    "Instaloader — download a profile (posts, reels, stories ...)" \
    "Toutatis — account details (needs your session ID)") || exit 0

profile=$(ask_profile Instagram) || exit $(($? == 2))
case "$choice" in
    Instaloader*) instaloader_run "$profile" ;;
    Toutatis*) toutatis_run "$profile" ;;
esac
