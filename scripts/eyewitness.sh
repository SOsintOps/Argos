#!/usr/bin/env bash
##EyeWitness Script

	#define choices
	opt1="Single URL"
	opt2="Multiple URLs (File)"
	eyewitness=$(zenity  --list  --title "EyeWitness" --text "Do you have Single or multiple URLs?" --width=400 --height=200 --radiolist  --column "Choose" --column "Option" TRUE "$opt1" FALSE "$opt2" 2> >(grep -v 'GtkDialog' >&2))
	case $eyewitness in
	$opt1 ) #Single
		domain=$(zenity --entry --title "EyeWitness" --text "Enter target URL (ex: https://www.google.com)" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
		if [ -n "$domain" ]; then
		cd /home/osint/Downloads/Programs/EyeWitness
		./EyeWitness.py --web --single "$domain" -d ~/Documents/EyeWitness/
		else
		zenity --error --text "No URL entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
		exit
		fi;;
	$opt2 ) #Multiple
		eyewitness_file=$(zenity --file-selection --title "URL List" --text "Select File of URLs" 2> >(grep -v 'GtkDialog' >&2))
		if [ -n "$eyewitness_file" ]; then
		cd /home/osint/Downloads/Programs/EyeWitness
		./EyeWitness.py --web -f "$eyewitness_file" -d ~/Documents/EyeWitness/ 
		else
		zenity --error --text "No file found, exiting" 2> >(grep -v 'GtkDialog' >&2)
		exit
		fi
	esac

