#!/usr/bin/env bash
# Video Downloader — uses yt-dlp (replaces youtube-dl)
# Compatible with: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

timestamp=$(date +%Y-%m-%d_%H%M)
url=$(zenity --entry --title "Video Downloader" --text "Enter video URL" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))

if [ -n "$url" ]; then
    mkdir -p "$HOME/Videos"
    /usr/bin/yt-dlp "$url" \
        -o "$HOME/Videos/${timestamp}_%(title)s.%(ext)s" \
        -i --all-subs \
        | zenity --progress --pulsate --no-cancel --auto-close \
            --title="Video Downloader" \
            --text="Video saved in ~/Videos/" 2> >(grep -v 'GtkDialog' >&2)
    sleep 2
    xdg-open "$HOME/Videos/" >/dev/null 2>&1
else
    zenity --error --text "URL missing, exiting" 2> >(grep -v 'GtkDialog' >&2)
    exit 1
fi
