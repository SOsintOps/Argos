#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: EditSimple, a video editor to explain a fact or show
# evidence (subject tracking, zoom, pixelation, slides), exported to MP4.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
argos_init "EditSimple"

EDITSIMPLE_DIR="$ARGOS_TOOLS_DIR/editsimple"

if [ ! -f "$EDITSIMPLE_DIR/EditSimple.py" ]; then
    ui_error "EditSimple is not installed. Run: setup.sh editsimple"
    exit 1
fi
py=$(find_tool editsimple-python "$EDITSIMPLE_DIR/.venv/bin/python") || exit 1

# A video or project passed by the menu or the file manager is opened at once.
cd "$EDITSIMPLE_DIR" && setsid "$py" EditSimple.py "$@" > /dev/null 2>&1 < /dev/null &
