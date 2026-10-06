#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Drive real zenity dialogs on a private virtual display and check what the
# Argos library gets back. Needs: zenity xvfb xdotool x11-utils.
# Usage: tests/gui/smoke.sh   (screenshots go to $SHOTS, default /tmp/argos-gui)

set -uo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SHOTS=${SHOTS:-/tmp/argos-gui}
mkdir -p "$SHOTS"
export GDK_BACKEND=x11 NO_AT_BRIDGE=1 ARGOS_UI=zenity ARGOS_NO_OPEN=1
export ARGOS_CASES_ROOT="$SHOTS/cases" ARGOS_CONFIG_DIR="$SHOTS/config"
unset WAYLAND_DISPLAY
export DISPLAY=:97
Xvfb :97 -screen 0 1280x900x24 >/dev/null 2>&1 &
XVFB=$!
trap 'kill $XVFB 2>/dev/null' EXIT
sleep 2

# shellcheck source=launchers/lib/argos.sh
. "$REPO/launchers/lib/argos.sh"
argos_init "Argos GUI test"
failures=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected [$3], got [$2]"; failures=$((failures + 1)); fi; }

wait_win() {
    local w _
    for _ in $(seq 1 50); do
        w=$(xdotool search --onlyvisible --name "$1" 2>/dev/null | tail -1)
        if [ -n "$w" ]; then sleep 1; echo "$w"; return 0; fi
        sleep 0.3
    done
    return 1
}
click() { xdotool mousemove --window "$1" "$2" "$3" click 1; sleep 0.6; }
height() { xwininfo -id "$1" | awk '/Height/{print $2}'; }
snap() { command -v magick >/dev/null && magick import -window "$1" "$SHOTS/$2.png" 2>/dev/null; true; }
# Row N (1-based) of a zenity list with a one-line prompt; first row at y=155.
row_y() { echo $((155 + 30 * ($1 - 1))); }

# 1. One choice out of three: all rows visible, the clicked one returned.
ui_choice "Pick" "One" "Two" "Three" > "$SHOTS/1.out" &
pid=$!
w=$(wait_win "Argos GUI test"); snap "$w" 1-choice
click "$w" 44 "$(row_y 3)"; click "$w" 348 $(($(height "$w") - 52)); wait "$pid"
check "choice returns the clicked option" "$(cat "$SHOTS/1.out")" "Three"

# 2. Checklist: the hidden keys come back, not the labels.
ui_checklist "Pick" "a|Alpha|on" "b|Bravo|on" "c|Charlie|off" > "$SHOTS/2.out" &
pid=$!
w=$(wait_win "Argos GUI test"); snap "$w" 2-checklist
click "$w" 44 "$(row_y 2)"; click "$w" 44 "$(row_y 3)"; click "$w" 408 $(($(height "$w") - 52)); wait "$pid"
check "checklist returns the selected keys" "$(tr '\n' ' ' < "$SHOTS/2.out")" "a c "

# 3. Cancel in the progress window stops the tool and its children.
dir=$(new_run_dir demo target)
# The inner script gets its folder as $0, so single quotes are intended.
# shellcheck disable=SC2016
run_logged "$dir" "Demo" -- sh -c 'sleep 300 & echo $! > "$0/child.pid"; wait' "$dir" &
pid=$!
w=$(wait_win "Argos GUI test"); sleep 2; snap "$w" 3-progress
click "$w" 308 177
wait "$pid"
check "cancel returns 130" "$?" "130"
kill -0 "$(cat "$dir/child.pid")" 2>/dev/null && child=alive || child=stopped
check "cancel stops child processes" "$child" "stopped"

echo "$failures failure(s); screenshots in $SHOTS"
[ "$failures" -eq 0 ]
