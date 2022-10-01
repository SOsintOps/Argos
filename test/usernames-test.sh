#!/usr/bin/env bash
##usernames Menu Script

url=$(zenity --entry --title "Sherlock" --text "Enter target Username" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
#define choices
opt1="Sherlock"
opt2="Maigret - WIP"
opt3="Moriarty - WIP"

#timestamp=$(date +%Y-%m-%d:%H:%M)

socialmenu=$(zenity  --list  --title "Usernames:Choose Tool" --text "What do you want to do?" --width=400 --height=200 --radiolist  --column "Choose" --column "Option" TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" 2> >(grep -v 'GtkDialog' >&2))

case $socialmenu in

$opt1 ) #Sherlock

if [ -n "$url" ]; then
	cd ~/Downloads/Programs/sherlock/ || exit
	python3 sherlock.py "$url" --csv -o ~/Documents/"$url".csv | zenity --progress --pulsate --no-cancel --auto-close --title="Sherlock Downloader" --text="Report being saved to ~/Documents/" 2> >(grep -v 'GtkDialog' >&2)
	sleep 2
	nautilus ~/Documents/ >/dev/null 2>&1
else
	zenity --error --text "Missing Username, exiting"
   	exit
fi

;;

esac
