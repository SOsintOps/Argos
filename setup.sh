#!/bin/bash
# Most of this script is supplied by Michael Bazzel, so credit where credit is due.

sudo apt-get -y update
sudo apt-get -y update

# Requirements for installing tools

requirements=("python3"
                "python-setuptools"
                "jq"                    
                "python3-pip"
                "python-pip"
                "git"
                "xargs"
                "curl"
                "wget")

for requirements in $requirements; do
    echo "Installing $(requirements)..."
    sudo apt-get install -y $(requirements)
done

#ToDo: Move user.js file to proper directory ~/.mozilla/ http://kb.mozillazine.org/Profile_folder

#Install scripts and launchers

sudo snap install vlc
sudo apt-get install -y ffmpeg
sudo apt-get install -y python3-pip
sudo -H pip3 install --upgrade youtube_dl
sudo apt install -y curl

#pls change [PASSWORD] with the password protected https://inteltechniques.com/osintbooksecure/vm-files.zip file
cd ~/Desktop && curl -u osint:[PASSWORD] -O https://inteltechniques.com/osintbooksecure/vm-files.zip
unzip vm-files.zip -d /home/osint/Desktop/
mkdir ~/Documents/scripts
mkdir ~/Documents/icons
cd ~/Desktop/vm-files/scripts
sudo cp * ~/Documents/scripts
cd ~/Desktop/vm-files/icons
cp * ~/Documents/icons
cd ~/Desktop/vm-files/shortcuts
sudo cp * /usr/share/applications/
Delete the 'vm-files' file and folder from Desktop if desired
cd ~/Downloads
mkdir Programs
cd Programs
sudo -H pip3 install Instalooter
sudo -H pip3 install Instaloader
sudo apt install -y git

# Twint
git clone https://github.com/twintproject/twint.git
cd twint
sudo -H pip3 install twint
sudo -H pip3 install -r requirements.txt
cd ~/Downloads/Programs

# EyeWitness
git clone https://github.com/ChrisTruncer/EyeWitness.git
cd EyeWitness/Python/setup
sudo -H ./setup.sh
cd ~/Documents/scripts
sed -i "s/Programs\/EyeWitness/Programs\/EyeWitness\/Python/g" eyewitness.sh
cd ~/Downloads/Programs
# Amass
sudo snap install amass
# sublist3r
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r && sudo -H pip3 install -r requirements.txt
cd ~/Downloads/Programs
#Photon
git clone https://github.com/s0md3v/Photon.git
cd Photon && sudo -H pip3 install -r requirements.txt
cd ~/Downloads/Programs
# The Harvester
git clone https://github.com/laramies/theHarvester.git
cd theHarvester
git checkout 8b88a66
sudo -H pip3 install -r requirements.txt
cd ~/Downloads/Programs
# Other assorted tools
sudo python3 -m pip install pipenv
sudo apt-get install -y mediainfo-gui
sudo apt install -y libimage-exiftool-perl
sudo apt-get install -y webhttrack
sudo wget -O google-earth64.deb http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
sudo dpkg -i google-earth64.deb
sudo apt-get -f install; sudo rm google-earth64.deb
sudo snap install keepassxc
sudo apt install -y kazam

# Modify scripts
cd ~/Documents/scripts/
sed -i "s/python3\.6/python3/g" domains.sh
sed -i "s/python\ sublist3r/python3\ sublist3r/g" domains.sh
sed -i "s/pip\ install/pip3\ install/g" updates.sh
sed -i "s/sudo\ pip3/sudo\ \-H\ pip3/g" updates.sh
pip3 install --upgrade pip
cd ~/Downloads/Programs

# Metagoofil
git clone https://github.com/opsdisk/metagoofil.git
cd metagoofil
sudo -H pip3 install -r requirements.txt
cd ~/Downloads/Programs

# recon-ng
git clone https://github.com/lanmaster53/recon-ng.git
cd recon-ng
sudo -H pip3 install -r REQUIREMENTS
cd ~/Downloads/Programs

# sherlock
git clone https://github.com/sherlock-project/sherlock.git
cd sherlock
python3 -m pip install -r requirements.txt
cd ~/Documents/scripts/
sed -i 's/Programs\/sherlock/Programs\/sherlock\/sherlock/g' sherlock.sh
cd ~/Downloads/Programs

# # recon-ng
git clone https://github.com/smicallef/spiderfoot.git
cd spiderfoot
sudo -H pip3 install -r requirements.txt
cd ~/Documents/scripts
sed -i '/^sudo/ d' spiderfoot.sh
sed -i '/^firefox/ d' spiderfoot.sh
echo "cd ~/Downloads/Programs/spiderfoot" >> spiderfoot.sh
echo "python3 sf.py -l 127.0.0.1:5001 &" >> spiderfoot.sh
echo "sleep 5" >> spiderfoot.sh
echo "firefox http://127.0.0.1:5001" >> spiderfoot.sh
cd ~/Downloads/Programs

# Elasticsearch-Crawler
git clone https://github.com/AmIJesse/Elasticsearch-Crawler.git
cd Elasticsearch-Crawler
sudo -H pip3 install nested-lookup
sudo -H pip3 install internetarchive
cd ~/Downloads/Programs
sudo chmod +x udate_osint_tools.sh



#ToDo: VMware tools installation
#ToDo: set up installation of extra programs: maltego, pycharm, cherrytree, the brothers of sherlock, Holehe
#ToDo: set osint report templates for libreoffice
#ToDo: set choice in the user profile script of your interest
