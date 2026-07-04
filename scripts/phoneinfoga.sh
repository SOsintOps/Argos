#!/usr/bin/env bash
# PhoneInfoga Launcher
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS
# PhoneInfoga installed as a Go binary in /usr/local/bin

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

HOST="127.0.0.1"
PORT="5000"
PHONEINFOGA_BIN="/usr/local/bin/phoneinfoga"

if [ ! -x "$PHONEINFOGA_BIN" ]; then
    zenity --error --text "PhoneInfoga not found at $PHONEINFOGA_BIN\nRe-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

# Start the PhoneInfoga web UI in the background if not already running
if ! /usr/bin/pgrep -f "phoneinfoga serve" >/dev/null; then
    "$PHONEINFOGA_BIN" serve -p "$PORT" &
    sleep 3
fi

xdg-open "http://${HOST}:${PORT}" >/dev/null 2>&1
