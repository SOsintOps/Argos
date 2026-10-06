#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos launcher: recon-ng console, with a workspace named after the case.

set -uo pipefail
# shellcheck source=lib/argos.sh
. "$(dirname "$(readlink -f "$0")")/lib/argos.sh"
ARGOS_UI="tty"
argos_init "recon-ng"

RECONNG_DIR="$ARGOS_TOOLS_DIR/recon-ng"
py=$(find_tool recon-ng-python "$RECONNG_DIR/.venv/bin/python") || exit 1

workspace=$(safe_name "$(case_name)")
printf 'recon-ng workspace: %s (same name as the active Argos case)\n' "$workspace"
printf 'Tip: "marketplace install all" adds the modules; "help" lists the commands.\n\n'
cd "$RECONNG_DIR" || exit 1
exec "$py" recon-ng -w "$workspace" --no-analytics
