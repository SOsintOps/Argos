#!/bin/bash
# Most of this script is supplied by Michael Bazzel, so credit where credit is due.

sudo apt update
sudo apt -y upgrade
sudo snap refresh
sudo apt update --fix-missing
sudo apt --fix-broken install
sudo -H python3 -m pip install pip -U
sudo -H python3 -m pip install youtube-dl -U
sudo -H python3 -m pip install instalooter -U
sudo -H python3 -m pip install Instaloader -U
sudo -H python3 -m pip install nested-lookup -U
sudo -H python3 -m pip install pipenv -U
sudo -H python3 -m pip install internetarchive -U
sudo -H python3 -m pip install waybackpy -U
cd ~/Downloads/Programs/EyeWitness
git pull https://github.com/ChrisTruncer/EyeWitness.git
cd Python/setup && sudo -H ./setup.sh
cd ~/Downloads/Programs/Sublist3r
git pull https://github.com/aboul3la/Sublist3r.git
sudo -H python3 -m pip install -r requirements.txt
cd ~/Downloads/Programs/Photon
git pull https://github.com/s0md3v/Photon.git
sudo sudo -H python3 -m pip install -r requirements.txt
cd ~/Downloads/Programs/theHarvester
git pull https://github.com/laramies/theHarvester.git
sudo -H python3 -m pip install -r requirements.txt
cd ~/Downloads/Programs/sherlock
git pull https://github.com/sherlock-project/sherlock.git
sudo -H python3 -m pip install -r requirements.txt
cd ~/Downloads/Programs/metagoofil
git pull https://github.com/opsdisk/metagoofil.git
sudo -H python3 -m pip install -r requirements.txt
cd ~/Downloads/Programs/recon-ng
git pull https://github.com/lanmaster53/recon-ng.git
sudo -H python3 -m pip install -r REQUIREMENTS
cd ~/Downloads/Programs/spiderfoot
git pull https://github.com/smicallef/spiderfoot.git
sudo -H python3 -m pip install -r requirements.txt
cd ~/Downloads/Programs/Elasticsearch-Crawler
git pull https://github.com/AmIJesse/Elasticsearch-Crawler.git
sudo apt autoremove -y

