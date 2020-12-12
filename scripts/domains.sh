#!/usr/bin/env bash
##Domain Interact Menu Script

#define choices
opt1="Amass"
opt2="Sublist3r"
opt3="Photon"
opt4="TheHarvester"

timestamp=$(date +%Y-%m-%d:%H:%M)
fqdnregex="\b((xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b"

domainmenu=$(zenity  --list  --title "Domain Tool" --text "What do you want to do?" --width=400 --height=300 --radiolist  --column "Choose" --column "Option" TRUE "$opt1" FALSE "$opt2" FALSE "$opt3" FALSE "$opt4" 2> >(grep -v 'GtkDialog' >&2)) 

case $domainmenu in
	$opt1 ) #Amass
		domain=$(zenity --entry --title "Amass" --text "Enter target domain name" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
		if [ ! -z "$domain" ]; then
			#verify legit domain
			if [[ $domain =~ $fqdnregex ]]; then
				#Run Tool
				mkdir /home/osint/Documents/Amass/
				amass intel -whois -ip -src -d $domain  -o /home/osint/Documents/Amass/$timestamp-$domain.1.txt 
				amass enum -src -brute -d $domain -o /home/osint/Documents/Amass/$timestamp-$domain.2.txt -d $domain
				sleep 3
				nautilus "/home/osint/Documents/Amass/" >/dev/null 2>&1
				exit
			else
				zenity --error --text "Doesn't appear to be a legitimate domain, exiting!" 2> >(grep -v 'GtkDialog' >&2)
				exit
 			fi
		fi;;
			$opt2 ) #Sublist3r
		domain=$(zenity --entry --title "Sublist3r" --text "Enter target domain name" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
		if [ ! -z "$domain" ]; then
			#verify legit domain
			if [[ $domain =~ $fqdnregex ]]; then
				#Run Tool
				mkdir /home/osint/Documents/Sublist3r/
				cd /home/osint/Downloads/Programs/Sublist3r
				python sublist3r.py -d $domain -o /home/osint/Documents/Sublist3r/sublist3r_$domain.txt
			else
				zenity --error --text "Doesn't appear to be a legitimate domain, exiting!" 2> >(grep -v 'GtkDialog' >&2)
				exit
 			fi
		fi;;
			$opt3 ) #Photon
		domain=$(zenity --entry --title "Photon" --text "Enter target domain name" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
		if [ ! -z "$domain" ]; then
			#verify legit domain
			if [[ $domain =~ $fqdnregex ]]; then
				#Run Tool
				mkdir /home/osint/Documents/Photon/
				cd /home/osint/Downloads/Programs/Photon/
				python3 photon.py -u $domain -l 3 -t 100 -o /home/osint/Documents/Photon/$timestamp-$domain
				sleep 3
				nautilus "/home/osint/Documents/Photon/$timestamp-$domain" >/dev/null 2>&1
				exit
			else
				zenity --error --text "Doesn't appear to be a legitimate domain, exiting!" 2> >(grep -v 'GtkDialog' >&2)
				exit
 			fi
		fi;;
			$opt4 ) #TheHarvester
		domain=$(zenity --entry --title "TheHarvester" --text "Enter target domain name" --entry-text "" 2> >(grep -v 'GtkDialog' >&2))
		if [ ! -z "$domain" ]; then
			#verify legit domain
			if [[ $domain =~ $fqdnregex ]]; then
				#Run Tool
				mkdir /home/osint/Documents/theHarvester/
				python3.6 /home/osint/Downloads/Programs/theHarvester/theHarvester.py -d $domain -b baidu,bing,google,yahoo,censys,virustotal -f /home/osint/Documents/theHarvester/$timestamp-$domain.html
				if [ -f /home/osint/Documents/theHarvester/$timestamp-$domain.html  ]; then
					firefox /home/osint/Documents/theHarvester/$timestamp-$domain.html	
				fi	
			else
				zenity --error --text "Doesn't appear to be a legitimate domain, exiting!" 2> >(grep -v 'GtkDialog' >&2)
				exit
 			fi
		fi;;
esac
