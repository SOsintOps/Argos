#!/usr/bin/env bash
# Shodan CLI Launcher
# Replaces the deprecated Elasticsearch-Crawler.
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS
# Shodan installed via pipx

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

# Explicit path: pipx installs to ~/.local/bin, which is not in PATH for Terminal=false launchers
SHODAN_BIN="$HOME/.local/bin/shodan"

if [ ! -x "$SHODAN_BIN" ]; then
    zenity --error --text "Shodan CLI not found at $SHODAN_BIN\nRe-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

# Ensure the API key is configured (shodan info fails if not initialised)
if ! "$SHODAN_BIN" info &>/dev/null; then
    key=$(zenity --entry --title "Shodan" --text "Enter your Shodan API key (from https://account.shodan.io)" --hide-text 2> >(grep -v 'GtkDialog' >&2))
    if [ -z "$key" ]; then
        zenity --error --text "No API key entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
        exit 1
    fi
    if ! "$SHODAN_BIN" init "$key" &>/dev/null; then
        zenity --error --text "Shodan initialisation failed. Check the API key and try again." 2> >(grep -v 'GtkDialog' >&2)
        exit 1
    fi
fi

query=$(zenity --entry --title "Shodan Search" --text "Enter a Shodan search query\n(e.g. product:Elasticsearch, apache country:IT)" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
if [ -z "$query" ]; then
    zenity --error --text "Query missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi

timestamp=$(date +%Y-%m-%d_%H%M)
mkdir -p "$HOME/Documents/shodan"
OUTFILE="$HOME/Documents/shodan/${timestamp}_$(echo "$query" | tr -c 'a-zA-Z0-9' '_').txt"

# tee writes the results to the file AND feeds the progress dialog; redirecting
# stdout straight to the file would leave zenity with no input (it would close at once).
"$SHODAN_BIN" search --fields ip_str,port,org,hostnames "$query" 2>&1 \
    | tee "$OUTFILE" \
    | zenity --progress --pulsate --no-cancel --auto-close \
        --title="Shodan" \
        --text="Searching: $query" 2> >(grep -v 'GtkDialog' >&2)

if [ -s "$OUTFILE" ]; then
    zenity --text-info --title "Shodan results: $query" --filename "$OUTFILE" --width=700 --height=500 2> >(grep -v 'GtkDialog' >&2)
    xdg-open "$HOME/Documents/shodan/" >/dev/null 2>&1
else
    zenity --warning --text "No results (or the query consumed no credits)." 2> >(grep -v 'GtkDialog' >&2)
fi
