#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: check that every tool used by the launchers starts.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "Argos Check"

export PYTHONWARNINGS="ignore::UserWarning"
T=$ARGOS_TOOLS_DIR
report=$(mktemp)
failures=0

# probe NAME COMMAND...: run COMMAND and record its first version-like line.
probe() {
    local name=$1 out
    shift
    if [ ! -x "$1" ] && ! command -v "$1" >/dev/null 2>&1; then
        printf '%-14s MISSING\n' "$name" >> "$report"
        failures=$((failures + 1))
        return
    fi
    if out=$(timeout 60 "$@" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -m1 -E '[0-9]+\.[0-9]+'); [ -n "$out" ]; then
        printf '%-14s ok       %s\n' "$name" "$(cut -c1-60 <<< "$out")" >> "$report"
    else
        printf '%-14s ERROR    (does not start; run it in a terminal to see why)\n' "$name" >> "$report"
        failures=$((failures + 1))
    fi
}

# probe_runs NAME COMMAND...: for tools without a version option.
probe_runs() {
    local name=$1
    shift
    if timeout 60 "$@" >/dev/null 2>&1; then
        printf '%-14s ok       (starts)\n' "$name" >> "$report"
    else
        printf '%-14s ERROR    (missing or does not start)\n' "$name" >> "$report"
        failures=$((failures + 1))
    fi
}

printf 'Argos %s — tool check, %s\n\n' "$ARGOS_VERSION" "$(date)" > "$report"
probe sherlock      "$ARGOS_BIN_DIR/sherlock" --version
probe maigret       "$ARGOS_BIN_DIR/maigret" --version
probe_runs blackbird env -C "$T/blackbird" "$T/blackbird/.venv/bin/python" blackbird.py -h
probe user-scanner  "$ARGOS_BIN_DIR/user-scanner" --version
probe linkook       "$ARGOS_BIN_DIR/linkook" --version
probe socialscan    "$ARGOS_BIN_DIR/socialscan" --version
probe instaloader   "$ARGOS_BIN_DIR/instaloader" --version
probe_runs toutatis "$ARGOS_BIN_DIR/toutatis" -h
probe theHarvester  "$ARGOS_BIN_DIR/theHarvester" -h
probe amass         "$ARGOS_BIN_DIR/amass" -version
probe eyewitness    "$T/EyeWitness/eyewitness-venv/bin/python" -c "import selenium; print('selenium', selenium.__version__)"
probe metagoofil    "$T/metagoofil/.venv/bin/python" "$T/metagoofil/metagoofil.py" -h
probe exiftool      exiftool -ver
probe yt-dlp        "$ARGOS_BIN_DIR/yt-dlp" --version
probe ffmpeg        ffmpeg -version
probe shodan        "$ARGOS_BIN_DIR/shodan" version
probe spiderfoot    "$T/spiderfoot/.venv/bin/python" "$T/spiderfoot/sf.py" --help
probe phoneinfoga   "$ARGOS_BIN_DIR/phoneinfoga" version
probe recon-ng      "$T/recon-ng/.venv/bin/python" "$T/recon-ng/recon-ng" --version
probe httrack       httrack --version

printf '\n%s problem(s) found.\n' "$failures" >> "$report"
if [ "$ARGOS_UI" = zenity ]; then ui_text_file "$report"; else cat "$report"; fi
rm -f "$report"
[ "$failures" -eq 0 ]
