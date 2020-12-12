#!/usr/bin/env bash
##Metagoofil Menu Script
#define choices
opt1="Metagoofil-Only"
opt2="Metagoofil+Exiftool"
timestamp=$(date +%Y-%m-%d:%H:%M)
fqdnregex="\b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b"
domainmenu=$(zenity  --list  --title "Choose Tool" --text "What do you want to do?" --width=400 --height=400 --radiolist  --column "Choose" --column "Option" TRUE "$opt1" FALSE "$opt2" 2> >(grep -v 'GtkDialog' >&2)) 
case $domainmenu in
	$opt1 ) #Metagoofil-Only
		domain=$(zenity --entry --title "Metagoofil-Only" --text "Enter target domain name" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
		if [ ! -z "$domain" ]; then
			#verify legit domain
			if [[ $domain =~ $fqdnregex ]]; then
				#Run Tool
				mkdir /home/osint/Documents/Metagoofil
				mkdir /home/osint/Documents/Metagoofil/"$timestamp"_docs_"$domain"
				mkdir /home/osint/Documents/Metagoofil/"$timestamp"_results_"$domain"
				sleep 1
				python3 /home/osint/Downloads/Programs/metagoofil/metagoofil.py -d $domain -w -t pdf,doc,xls,ppt,docx,xlsx,pptx -o "/home/osint/Documents/Metagoofil/"$timestamp"_docs_"$domain""
				sleep 1
				nautilus "/home/osint/Documents/Metagoofil/" >/dev/null 2>&1
				exit
				fi
			else
				zenity --error --text "Doesn't appear to be a legitimate domain, exiting!" 2> >(grep -v 'GtkDialog' >&2)
				exit
		fi
;;
	$opt2 ) #Metagoofil+Exiftool
		domain=$(zenity --entry --title "Metagoofil+Exiftool" --text "Enter target domain name" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
		if [ ! -z "$domain" ]; then
			#verify legit domain
			if [[ $domain =~ $fqdnregex ]]; then
				#Run Tool
				mkdir /home/osint/Documents/Metagoofil
				mkdir /home/osint/Documents/Metagoofil/"$timestamp"_docs_"$domain"
				mkdir /home/osint/Documents/Metagoofil/"$timestamp"_results_"$domain"
				sleep 1
				python3 /home/osint/Downloads/Programs/metagoofil/metagoofil.py -d $domain -w -t pdf,doc,xls,ppt,docx,xlsx,pptx -o "/home/osint/Documents/Metagoofil/"$timestamp"_docs_"$domain""
				sleep 1
				if [[ $(find "/home/osint/Documents/Metagoofil/"$timestamp"_docs_"$domain"" -maxdepth 1 -type f) ]]; then
					find "/home/osint/Documents/Metagoofil/"$timestamp"_docs_"$domain"" -maxdepth 1 -type f | exiftool /home/osint/Documents/Metagoofil/"$timestamp"_docs_"$domain"/* -csv > ~/Documents/Metagoofil/"$timestamp"_results_"$domain"/Report.csv
				nautilus "/home/osint/Documents/Metagoofil" >/dev/null 2>&1
				exit
				else
					echo "No files found for parsing, exiting"
					exit
				fi
			else
				zenity --error --text "Doesn't appear to be a legitimate domain, exiting!" 2> >(grep -v 'GtkDialog' >&2)
				exit
 		fi
		fi
;;
esac
