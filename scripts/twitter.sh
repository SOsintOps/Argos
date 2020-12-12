#!/usr/bin/env bash
##Twitter Menu Script

#define choices
opt1="Download User's Tweets"
opt2="Download User's Followers"
opt3="Download User's Following"
opt4="Download User's Favorites"
opt5="Search a Keyword"

timestamp=$(date +%Y-%m-%d:%H:%M)

socialmenu=$(zenity  --list  --title "Twitter Tool" --text "What do you want to do?" --width=400 --height=300 --radiolist  --column "Choose" --column "Option" TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" FALSE "$opt4" FALSE "$opt5" 2> >(grep -v 'GtkDialog' >&2)) 

case $socialmenu in
			
	$opt1 ) 
	handle=$(zenity --entry --title "Download Tweets from User" --text "Enter Twitter Username" 2> >(grep -v 'GtkDialog' >&2))
	  if [ -n "$handle" ]; then
		if [ ! -d "/home/osint/Documents/$timestamp-$handle/" ]; then
	           mkdir /home/osint/Documents/$timestamp-$handle/
 		fi
	  twint -u $handle -o /home/osint/Documents/$timestamp-$handle/$handle.csv --csv 2>/dev/null | zenity --progress --pulsate --no-cancel --auto-close --title="Twint" --text="Downloading Tweets from: $handle" 2> >(grep -v 'GtkDialog' >&2)
	  nautilus /home/osint/Documents/$timestamp-$handle/ >/dev/null 2>&1
	  else
	  	zenity --error --text "No handle entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
    		exit
	  fi;;
	$opt2 ) 
	handle=$(zenity --entry --title "Download Followers for User" --text "Enter Twitter Username" 2> >(grep -v 'GtkDialog' >&2))
	  if [ -n "$handle" ]; then
		if [ ! -d "/home/osint/Documents/$timestamp-$handle/" ]; then
     	           mkdir /home/osint/Documents/$timestamp-$handle/
 		fi
	  twint -u $handle --followers -o /home/osint/Documents/$timestamp-$handle/$handle-followers.csv --csv 2>/dev/null | zenity --progress --pulsate --no-cancel --auto-close --title="Twint" --text="Downloading Followers of: $handle" 2> >(grep -v 'GtkDialog' >&2)
	  nautilus /home/osint/Documents/$timestamp-$handle/ >/dev/null 2>&1
	  else
	  	zenity --error --text "No handle entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
    		exit
	  fi;;
	$opt3 ) 
	handle=$(zenity --entry --title "Download Profiles Followed by User" --text "Enter Twitter Username" 2> >(grep -v 'GtkDialog' >&2))
	  if [ -n "$handle" ]; then
		if [ ! -d "/home/osint/Documents/$timestamp-$handle/" ]; then
     	             mkdir /home/osint/Documents/$timestamp-$handle/
 		fi
	  twint -u $handle --following -o /home/osint/Documents/$timestamp-$handle/$handle-following.csv --csv 2>/dev/null | zenity --progress --pulsate --no-cancel --auto-close --title="Twint" --text="Downloading Follows of: $handle" 2> >(grep -v 'GtkDialog' >&2)
	  nautilus /home/osint/Documents/$timestamp-$handle/ >/dev/null 2>&1
	  else
	  	zenity --error --text "No handle entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
    		exit
	  fi;;
	$opt4 ) 
	handle=$(zenity --entry --title "Download Favorites from User" --text "Enter Twitter Username" 2> >(grep -v 'GtkDialog' >&2))
	  if [ -n "$handle" ]; then
		if [ ! -d "/home/osint/Documents/$timestamp-$handle/" ]; then
  	           mkdir /home/osint/Documents/$timestamp-$handle/
 		fi
	  twint -u $handle --favorites -o /home/osint/Documents/$timestamp-$handle/$handle-favorites.csv --csv 2>/dev/null | zenity --progress --pulsate --no-cancel --auto-close --title="Twint" --text="Downloading Favorites from: $handle" 2> >(grep -v 'GtkDialog' >&2)
	  nautilus /home/osint/Documents/$timestamp-$handle/ >/dev/null 2>&1
	  else
	  	zenity --error --text "No handle entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
    		exit
	  fi;;
	$opt5 ) 
	handle=$(zenity --entry --title "Search a Keyword" --text "Enter Keyword" 2> >(grep -v 'GtkDialog' >&2))
	  if [ -n "$handle" ]; then
		if [ ! -d "/home/osint/Documents/$timestamp-$handle/" ]; then
	           mkdir /home/osint/Documents/$timestamp-$handle/
 		fi
	  twint -s $handle -o /home/osint/Documents/$timestamp-$handle/$handle-keyword.csv --csv 2>/dev/null | zenity --progress --pulsate --no-cancel --auto-close --title="Twint" --text="Downloading Search Results of: $handle" 2> >(grep -v 'GtkDialog' >&2)
	  nautilus /home/osint/Documents/$timestamp-$handle/ >/dev/null 2>&1
	  else
	  	zenity --error --text "No handle entered, exiting" 2> >(grep -v 'GtkDialog' >&2)
    		exit
	  fi
esac
