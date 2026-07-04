#!/usr/bin/env bash
# SpiderFoot Launcher
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS
# SpiderFoot installed via pipx

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

HOST="127.0.0.1"
PORT="5001"

# Explicit path: pipx installs to ~/.local/bin, which is not in PATH for Terminal=false desktop launchers
SPIDERFOOT_BIN="$HOME/.local/bin/spiderfoot"

if [ ! -x "$SPIDERFOOT_BIN" ]; then
    zenity --error --text "SpiderFoot not found at $SPIDERFOOT_BIN\nRe-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

# Start SpiderFoot in the background if not already listening on that port
if ! /usr/bin/pgrep -f "spiderfoot -l" >/dev/null; then
    "$SPIDERFOOT_BIN" -l "${HOST}:${PORT}" &
    sleep 5
fi

xdg-open "http://${HOST}:${PORT}" >/dev/null 2>&1
