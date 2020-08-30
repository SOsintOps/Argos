#!/bin/bash
# Most of this script is supplied by Michael Bazzel, so credit where credit is due.

sudo apt-get update
sudo apt-get upgrade
sudo snap refresh
pip3 install --upgrade pip
sudo /usr/bin/python3 -m pip install --upgrade pip
sudo -H pip3 install --upgrade youtube-dl
sudo -H pip3 install instalooter -U
sudo -H pip3 install Instaloader -U
sudo -H pip3 install Twint -U
cd ~/Downloads/Programs/EyeWitness
git pull https://github.com/ChrisTruncer/EyeWitness.git
cd ~/Downloads/Programs/Sublist3r
git pull https://github.com/aboul3la/Sublist3r.git
cd ~/Downloads/Programs/Photon
git pull https://github.com/s0md3v/Photon.git
cd ~/Downloads/Programs/metagoofil
git pull https://github.com/opsdisk/metagoofil.git
cd ~/Downloads/Programs/recon-ng
git pull https://github.com/lanmaster53/recon-ng.git
cd ~/Downloads/Programs/sherlock
git pull https://github.com/sherlock-project/sherlock.git
cd ~/Downloads/Programs/spiderfoot
git pull https://github.com/smicallef/spiderfoot.git
cd ~/Downloads/Programs/Elasticsearch-Crawler
git pull https://github.com/AmIJesse/Elasticsearch-Crawler.git