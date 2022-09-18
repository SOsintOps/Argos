#!/usr/bin/env bash
##Instagram Menu Script

#define choices
opt1="instalooter"
opt2="instaloader"
opt3="Toutatis"

timestamp=$(date +%Y-%m-%d:%H:%M)

socialmenu=$(zenity  --list  --title "Instagram:Choose Tool" --text "What do you want to do?" --width=400 --height=200 --radiolist  --column "Choose" --column "Option" TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" 2> >(grep -v 'GtkDialog' >&2))

case $socialmenu in

	$opt1 ) #instalooter
	handle=$(zenity --entry --title "Instalooter" --text "Enter Instagram User ID" 2> >(grep -v 'GtkDialog' >&2))

	  if [ -n "$handle" ]; then

		if [ ! -d "/home/osint/Documents/instalooter/$timestamp-$handle/" ]; then

	           mkdir /home/osint/Documents/instalooter/$timestamp-$handle/
 		fi

	  instalooter user $handle /home/osint/Documents/instalooter/$timestamp-$handle/ -v -m -d -e 2>/dev/null | zenity --progress --pulsate --no-cancel --auto-close --title="Instalooter" --text="Grabbing all photos for: $handle" 2> >(grep -v 'GtkDialog' >&2)

	  nautilus /home/osint/Documents/instalooter/$timestamp-$handle/ >/dev/null 2>&1

	  else
	  	zenity --error --text "No handle entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
    		exit
	  fi

	;;
	
	$opt2) #Instaloader
	mkdir ~/Documents/instaloader
	cd ~/Documents/instaloader
	handle=$(zenity --entry --title "Instaloader" --text "Enter Instagram User ID" 2> >(grep -v 'GtkDialog' >&2))
	instaloader $handle
	nautilus /home/osint/Documents/instaloader/$handle/ >/dev/null 2>&1
	;;
	
	$opt3) #Toutatis
  	handle=$(zenity --entry --title "Toutatis" --text "Enter TARGET Instagram User ID")
    	session=$(zenity --entry --title "Session" --text "Enter YOUR Session ID")
    	toutatis -u $handle -s $session
    	read -rsp $'Press enter to continue...\n'
    	exit
	;;


esac
