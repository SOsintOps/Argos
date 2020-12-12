#!/usr/bin/env bash
url=$(zenity --entry --title "Sherlock" --text "Enter target Username" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
if [ -n "$url" ]; then
	cd ~/Downloads/Programs/sherlock/
	python3 sherlock.py "$url" --csv -o ~/Documents/"$url".csv | zenity --progress --pulsate --no-cancel --auto-close --title="Sherlock Downloader" --text="Report being saved to ~/Documents/" 2> >(grep -v 'GtkDialog' >&2)
	sleep 2
	nautilus ~/Documents/ >/dev/null 2>&1
else
	zenity --error --text "Missing Username, exiting"
   	exit
fi 

