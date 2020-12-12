#!/usr/bin/env bash
##Updates Script

sudo apt-get update
sudo apt-get upgrade
sudo -H pip install --upgrade youtube-dl
sudo pip install instalooter -U
sudo pip3 install Instaloader -U
sudo pip3 install Twint -U
cd ~/Downloads/Programs/EyeWitness
git pull https://github.com/ChrisTruncer/EyeWitness.git
cd ~/Downloads/Programs/Sublist3r
git pull https://github.com/aboul3la/Sublist3r.git
cd ~/Downloads/Programs/Photon
git pull https://github.com/s0md3v/Photon.git
sudo snap refresh

