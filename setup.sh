#!/bin/bash


OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

echo -e "$OKBLUE          _                   _           _              _            _        "
echo -e "$OKBLUE         / /\                /\ \        /\ \           /\ \         / /\      "
echo -e "$OKBLUE        / /  \              /  \ \      /  \ \         /  \ \       / /  \     "
echo -e "$OKBLUE       / / /\ \            / /\ \ \    / /\ \_\       / /\ \ \     / / /\ \__  "
echo -e "$OKBLUE      / / /\ \ \          / / /\ \_\  / / /\/_/      / / /\ \ \   / / /\ \___\ "
echo -e "$OKBLUE    / / /  \ \ \        / / /_/ / / / / / ______   / / /  \ \_\  \ \ \ \/___/ "
echo -e "$OKBLUE    / / /___/ /\ \      / / /__\/ / / / / /\_____\ / / /   / / /   \ \ \       "
echo -e "$OKBLUE   / / /_____/ /\ \    / / /_____/ / / /  \/____ // / /   / / /_    \ \ \      "
echo -e "$OKBLUE  / /_________/\ \ \  / / /\ \ \  / / /_____/ / // / /___/ / //_/\__/ / /      "
echo -e "$OKBLUE / / /_       __\ \_\/ / /  \ \ \/ / /______\/ // / /____\/ / \ \/___/ /       "
echo -e "$OKBLUE \_\___\     /____/_/\/_/    \_\/\/___________/ \/_________/   \_____\/        "
echo "    "
echo -e "$RESET"
echo -e "$OKRED +----=[Osint Ops]=----+ $RESET"


echo '#######################################################################'
echo '#                         Let me update your OS                       #'
echo '#######################################################################'

sudo apt -y update && sudo apt -y upgrade
sudo snap refresh

# Optional Virtualbox tools
# sudo add-apt-repository multiverse
# sudo apt install virtualbox-guest-dkms virtualbox-guest-x11
# sudo adduser osint vboxsf
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "


echo '#######################################################################'
echo '#                            A few scripts                           #'
echo '#######################################################################'

mkdir ~/Documents/scripts && cp ~/Downloads/Argos/scripts/*.sh ~/Documents/scripts
sudo chmod +x ~/Documents/scripts/*.sh

mkdir ~/Pictures/icons && cp ~/Downloads/Argos/multimedia/icons/* ~/Pictures/icons

sudo cp ~/Downloads/Argos/shortcuts/*.desktop /usr/share/applications/

# this command will copy all the OSINT templates to the Templates Directory. I may need to delete o move to another directory all the Templates directory's default templates
cp -r ~/Downloads/Argos/templates/* ~/Templates

# setting the 'quiet priest' background image
cp ~/Downloads/Argos/multimedia/wallpapers/* ~/Pictures && sudo chmod +x ~/Downloads/Argos/multimedia/wallpapers/background.sh && ~/Downloads/Argos/multimedia/wallpapers/background.sh
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "



echo '#######################################################################'
echo '#      Requirements for installing tools, scripts and launchers       #'
echo '#######################################################################'
sudo apt install -y vlc
sudo apt install -y python3
sudo apt install -y python-setuptools
sudo apt install -y jq
sudo apt install -y python3-pip
sudo apt install -y git
sudo apt install -y curl
sudo apt install -y wget
sudo apt install -y curl
sudo apt install -y webhttrack
sudo apt install -y ffmpeg
sudo apt install -y mediainfo-gui
sudo apt install -y libimage-exiftool-perl
sudo apt install -y subversion
sudo -H pip3 install --upgrade youtube_dl
sudo -H pip3 install Instalooter
sudo -H pip3 install Instaloader
sudo -H pip3 install toutatis
sudo python3 -m pip install pipenv
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "


echo '#######################################################################'
echo '#                          Customizing Firefox                        #'
echo '#######################################################################'

# firefox &
# sleep 30
pkill -f firefox
# rm -rfv ~/snap/firefox/common/.mozilla/firefox/*.default
cd ~/Downloads/Argos/argosfox/
zip -F argos-ff-template.zip --out argos-ff-template2.zip
unzip argos-ff-template2.zip
cp -R ~/Downloads/Argos/argosfox/argos-ff-template/* ~/snap/firefox/common/.mozilla/firefox/*.default
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                           Obsidian                                  #'
echo '#######################################################################'
cd ~/Downloads
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v0.14.6/obsidian_0.14.6_amd64.snap
sudo snap install --dangerous obsidian_0.14.6_amd64.snap
sudo rm obsidian_0.14.6_amd64.snap
git clone https://github.com/WebBreacher/obsidian-osint-templates ~/Documents/obsidian-osint-templates #template osint di obsidian
git clone https://github.com/theNerdInTheHighCastle/Obsidian ~/Documents/obsidian-criptovalute #template osint di obsidian
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                             Amass                                   #'
echo '#######################################################################'
sudo snap install amass
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                          EyeWitness                                 #'
echo '#######################################################################'

git clone https://github.com/FortyNorthSecurity/EyeWitness.git ~/Downloads/Programs/EyeWitness
sudo -H ~/Downloads/Programs/EyeWitness/Python/setup/setup.sh
cd ~/Documents/scripts
sed -i "s/Programs\/EyeWitness/Programs\/EyeWitness\/Python/g" eyewitness.sh
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                           sublist3r                                 #'
echo '#######################################################################'

git clone https://github.com/aboul3la/Sublist3r.git ~/Downloads/Programs/Sublist3r
sudo -H pip3 install -r ~/Downloads/Programs/Sublist3r/requirements.txt
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                              Photon                                 #'
echo '#######################################################################'

git clone https://github.com/s0md3v/Photon.git ~/Downloads/Programs/Photon
sudo -H pip3 install -r ~/Downloads/Programs/Photon/requirements.txt
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                       The Harvester                                 #'
echo '#######################################################################'

git clone https://github.com/laramies/theHarvester.git ~/Downloads/Programs/theHarvester
cd ~/Downloads/Programs/theHarvester
sudo -H pip3 install -r requirements/base.txt
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                           Metagoofil                                #'
echo '#######################################################################'

git clone https://github.com/opsdisk/metagoofil.git ~/Downloads/Programs/metagoofil
sudo -H pip3 install -r ~/Downloads/Programs/metagoofil/requirements.txt
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                              recon-ng                               #'
echo '#######################################################################'

git clone https://github.com/lanmaster53/recon-ng.git ~/Downloads/Programs/recon-ng
cd ~/Downloads/Programs/recon-ng
sudo -H pip3 install -r REQUIREMENTS
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                              sherlock                               #'
echo '#######################################################################'

git clone https://github.com/sherlock-project/sherlock.git ~/Downloads/Programs/sherlock
python3 -m pip install -r ~/Downloads/Programs/sherlock/requirements.txt
cd ~/Documents/scripts/
sed -i 's/Programs\/sherlock/Programs\/sherlock\/sherlock/g' sherlock.sh
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                            spiderfoot                               #'
echo '#######################################################################'

git clone https://github.com/smicallef/spiderfoot.git ~/Downloads/Programs/spiderfoot
sudo -H pip3 install -r ~/Downloads/Programs/spiderfoot/requirements.txt
cd ~/Documents/scripts
sed -i '/^sudo/ d' spiderfoot.sh
sed -i '/^firefox/ d' spiderfoot.sh
echo "cd ~/Downloads/Programs/spiderfoot" >> spiderfoot.sh
echo "python3 sf.py -l 127.0.0.1:5001 &" >> spiderfoot.sh
echo "sleep 5" >> spiderfoot.sh
echo "firefox http://127.0.0.1:5001" >> spiderfoot.sh
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                             W3b0s1nt                                #'
echo '#######################################################################'

git clone https://github.com/C3n7ral051nt4g3ncy/webosint.git ~/Downloads/Programs/webosint
cd ~/Downloads/Programs/webosint
sudo -H pip3 install -r requirements.txt
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                             blackbird                               #'
echo '#######################################################################'

git clone https://github.com/p1ngul1n0/blackbird.git ~/Downloads/Programs/blackbird
cd ~/Downloads/Programs/blackbird
sudo -H pip3 install -r requirements.txt
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                     Elasticsearch-Crawler                           #'
echo '#######################################################################'

git clone https://github.com/AmIJesse/Elasticsearch-Crawler.git ~/Downloads/Programs/Elasticsearch-Crawler
cd ~/Downloads/Programs/Elasticsearch-Crawler
sudo -H pip3 install nested-lookup
sudo -H pip3 install internetarchive
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                               Ripgrep                               #'
echo '#######################################################################'

cd ~/Downloads/
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
sudo dpkg -i ripgrep_11.0.2_amd64.deb
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                                holehe                               #'
echo '#######################################################################'

git clone https://github.com/megadose/holehe.git ~/Downloads/Programs/holehe
cd ~/Downloads/Programs/holehe && sudo python3 setup.py install
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                              anonsurf                               #'
echo '#######################################################################'

git clone https://github.com/Und3rf10w/kali-anonsurf.git ~/Downloads/Programs/kali-anonsurf
cd ~/Downloads/Programs/kali-anonsurf && sudo ./installer.sh
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                        Moriarty-Project                             #'
echo '#######################################################################'

git clone https://github.com/AzizKpln/Moriarty-Project ~/Downloads/Programs/Moriarty-Project
cd ~/Downloads/Programs/Moriarty-Project && chmod 755 install.sh && bash install.sh
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                               maigret                               #'
echo '#######################################################################'

git clone https://github.com/soxoj/maigret ~/Downloads/Programs/maigret
pip3 install ~/Downloads/Programs/maigret/.
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                           Google Earth                              #'
echo '#######################################################################'

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo wget -O google-earth64.deb http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
sudo dpkg -i google-earth64.deb && sudo apt -f install && sudo rm google-earth64.deb
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                               Maltego                               #'
echo '#######################################################################'

wget -O maltego.deb https://maltego-downloads.s3.us-east-2.amazonaws.com/linux/Maltego.v4.3.0.deb
sudo dpkg -i maltego.deb && sudo apt -f install && rm maltego.deb
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "
echo '#######################################################################'
echo '#                       Customising scripts                           #'
echo '#######################################################################'
cd ~/Documents/scripts/
sed -i "s/python3\.6/python3/g" domains.sh
sed -i "s/python\ sublist3r/python3\ sublist3r/g" domains.sh
# sed -i "s/pip\ install/pip3\ install/g" updates.sh
# sed -i "s/sudo\ pip3/sudo\ \-H\ pip3/g" updates.sh
sudo pip3 install --upgrade pip
cd ~/Downloads/Programs
echo -e "$OKGREEN +----=[DOOONE!!!]=----+ $RESET"
echo "    "

echo '#######################################################################'
echo '#                       General Purpose tools                         #'
echo '#######################################################################'
sudo add-apt-repository -y ppa:giuspen/ppa && sudo apt install -y cherrytree
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add - && sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list' && sudo apt update && sudo apt install -y atom
sudo apt install -y keepassxc
sudo apt install -y torbrowser-launcher
sudo apt install -y kazam
sudo apt install -y audacity
sudo apt install -y openjdk-11-jre
sudo apt install -y ripgrep
sudo apt install -y p7zip unrar
sudo apt install -y openshot
sudo apt install -y open-vm-tools
#sudo apt install -y ubuntu-restricted-extras
git clone https://github.com/pstirparo/threatintel-resources ~/Documents/threatintel-resources
git clone https://github.com/mxm0z/awesome-intelligence-writing ~/Documents/awesome-intelligence-writing
sudo apt autoremove -y
echo -e "$OKRED +----=[Si vis pacem, para bellum]=----+ $RESET"
echo "    "
read -rsp $'Press enter to reboot...\n'
sudo reboot now
