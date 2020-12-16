#!/bin/bash
echo '#######################################################################'
echo '#                             Twint                                   #'
echo '#######################################################################'

cd ~/Downloads/Programs
git clone https://github.com/twintproject/twint.git
cd twint
sudo -H pip3 install twint
sudo -H pip3 install -r requirements.txt