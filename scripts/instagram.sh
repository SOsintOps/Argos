#!/usr/bin/env bash
# Instagram OSINT Menu Script
# Instalooter removed (abandoned). Available tools: Instaloader, Toutatis
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

opt1="Instaloader"
opt2="Toutatis"

# Explicit paths: pipx installs to ~/.local/bin, which is not in PATH for Terminal=false desktop launchers
INSTALOADER_BIN="$HOME/.local/bin/instaloader"
TOUTATIS_BIN="$HOME/.local/bin/toutatis"

timestamp=$(date +%Y-%m-%d_%H%M)

socialmenu=$(zenity --list \
    --title "Instagram: Select Tool" \
    --text "What do you want to do?" \
    --width=400 --height=200 \
    --radiolist \
    --column "Select" --column "Option" \
    TRUE "$opt1" FALSE "$opt2" \
    2> >(grep -v 'GtkDialog' >&2))

case $socialmenu in

    "$opt1") # Instaloader
        if [ ! -x "$INSTALOADER_BIN" ]; then
            zenity --error --text "Instaloader not found. Re-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        handle=$(zenity --entry --title "Instaloader" --text "Enter Instagram username" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$handle" ]; then
            mkdir -p "$HOME/Documents/instaloader/$timestamp-$handle"
            cd "$HOME/Documents/instaloader/$timestamp-$handle" || exit 1
            # 2>&1 required: instaloader writes to stderr, not stdout
            "$INSTALOADER_BIN" "$handle" 2>&1 \
                | zenity --progress --pulsate --no-cancel --auto-close \
                    --title="Instaloader" \
                    --text="Downloading profile: $handle" 2> >(grep -v 'GtkDialog' >&2)
            xdg-open "$HOME/Documents/instaloader/$timestamp-$handle/" >/dev/null 2>&1
        else
            zenity --error --text "No handle entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

    "$opt2") # Toutatis
        if [ ! -x "$TOUTATIS_BIN" ]; then
            zenity --error --text "Toutatis not found. Re-run setup.sh." 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        handle=$(zenity --entry --title "Toutatis" --text "Enter TARGET Instagram username" 2> >(grep -v 'GtkDialog' >&2))
        session=$(zenity --entry --title "Toutatis" --text "Enter your Instagram Session ID" 2> >(grep -v 'GtkDialog' >&2))
        if [ -n "$handle" ] && [ -n "$session" ]; then
            "$TOUTATIS_BIN" -u "$handle" -s "$session"
            read -rsp $'Press ENTER to continue...\n'
        else
            zenity --error --text "Missing parameters, exiting" 2> >(grep -v 'GtkDialog' >&2)
            exit 1
        fi
        ;;

esac
