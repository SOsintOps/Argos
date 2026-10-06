#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Set the Argos wallpaper on the current desktop session.
# Usage: set-wallpaper.sh IMAGE

set -uo pipefail

image=${1:-}
if [ ! -f "$image" ]; then
    echo "set-wallpaper: image not found: $image" >&2
    exit 1
fi
uri="file://$image"
desktop=${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}

case "${desktop,,}" in
    *gnome*|*ubuntu*|*budgie*|*unity*)
        gsettings set org.gnome.desktop.background picture-uri "$uri"
        gsettings set org.gnome.desktop.background picture-uri-dark "$uri" 2>/dev/null
        gsettings set org.gnome.desktop.background picture-options zoom
        ;;
    *mate*)
        gsettings set org.mate.background picture-filename "$image"
        ;;
    *xfce*)
        # One property per monitor and workspace: set them all.
        xfconf-query -c xfce4-desktop -l | grep '/last-image$' | while read -r prop; do
            xfconf-query -c xfce4-desktop -p "$prop" -s "$image"
        done
        ;;
    *kde*|*plasma*)
        echo "set-wallpaper: on KDE Plasma set $image from Desktop and Wallpaper settings." >&2
        exit 2
        ;;
    *)
        if command -v feh >/dev/null 2>&1; then
            feh --bg-fill "$image"
        else
            echo "set-wallpaper: desktop \"$desktop\" not supported." >&2
            exit 2
        fi
        ;;
esac
