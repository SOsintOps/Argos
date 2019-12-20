#!/usr/bin/env bash
timestamp=$(date +%Y-%m-%d:%H:%M)
url=$(zenity --entry --title "Video Downloader" --text "Enter target URL" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
if [ -n "$url" ]; then
	youtube-dl "$url" -o ~/Videos/"$timestamp%(title)s.%(ext)s" -i --all-subs| zenity --progress --pulsate --no-cancel --auto-close --title="Video Downloader" --text="Video being saved to ~/Videos/" 2> >(grep -v 'GtkDialog' >&2)
	sleep 2
	nautilus ~/Videos/ >/dev/null 2>&1
else
	zenity --error --text "Missing URL, exiting"
   	exit
fi 

