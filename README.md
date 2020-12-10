# ARGOS
<img align="right" width="86" height="150" src="https://github.com/SOsintOps/Argos/blob/master/wallpaper/scribblenauts-argos.png">

This script will automatically set up an open source intelligence (OSINT) workstation starting from a clean Ubuntu* 20.4 Virtual Machine/Workstation.\
Best practices recommend using a new VM for each OSInt investigation.\
There are several ready-made VMs available on the Internet. I wanted to study how to customise my own workstation following what Michael Bazzell suggest in his own book, [Open Source Intelligence Techniques - 7th Edition (2019)](https://inteltechniques.com/book1.html), about creating your own custom VM.\
This script will setup the workstation by installing mostly of the scripts suggested by Michael, plus the other tools he supplies on his website.


## REQUIREMENTS
To install and run Argos, you need:
- an Ubuntu* 20.4 virtual machine/workstation
- set your user on "**osint**"

This script implies that you rely on VmWare for virtualization. Just in case, I included a commented out portion of code which will install virtual box tools. 

**N.B.** This script has been tested on a [Ubuntu Budgie](https://ubuntubudgie.org/) 20.10 VM.

## TOOLS

### OSInt
- [Amass](https://github.com/OWASP/Amass)
- [twint](https://github.com/twintproject/twint)
- [instaloader](https://instaloader.github.io/)
- [InstaLooter](https://github.com/althonos/InstaLooter)
- [HTTrack](https://www.httrack.com/)
- [MediaInfo](https://mediaarea.net/en/MediaInfo/Download/Ubuntu)
- [ExifTool](https://github.com/pandastream/libimage-exiftool-perl-9.27)
- [EyeWitness](https://github.com/ChrisTruncer/EyeWitness)
- [sublist3r](https://github.com/aboul3la/Sublist3r)
- [Photon](https://github.com/s0md3v/Photon)
- [Metagoofil](https://github.com/opsdisk/metagoofil)
- [recon-ng](https://github.com/lanmaster53/recon-ng)
- [sherlock](https://github.com/sherlock-project/sherlock)
- [spiderfoot](https://github.com/smicallef/spiderfoot)
- [Elasticsearch-Crawler](https://github.com/AmIJesse/Elasticsearch-Crawler)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [holehe](https://github.com/megadose/holehe)
- [kali-anonstealth](https://github.com/Und3rf10w/kali-anonsurf)
- and more!

### General Purpose tools
- [vlc](https://www.videolan.org/vlc/index.html)
- [wget](https://www.gnu.org/software/wget/)
- [cherrytree](https://www.giuspen.com/cherrytree/)
- [Atom](https://atom.io/)
- [KeepassXC](https://keepassxc.org/)
- [Kazam](https://launchpad.net/kazam)
- [Audacity](https://www.audacityteam.org/)
- and more!


## INSTALLING & RUNNING
1) Open the Terminal app

2) Make sure that the [GIT command](https://linuxize.com/post/how-to-install-git-on-ubuntu-20-04/) is available in your VM:
    ```bash
    sudo apt install git
    ```
3) type:
    ```bash
    cd ~/Downloads/
    ```
4) Clone this repository in the ```/Download/``` directory: 
    ```bash
    git clone https://github.com/SOsintOps/Argos
    ```

5) Go to ```/Argos/``` and make the setup script executable:
    ```bash
    cd ~/Downloads/Argos/
    sudo chmod +x setup.sh
    ```
6) Within the ```setup.sh``` replace [PASSWORD](https://inteltechniques.com/osintbook/)  with the current website's password

7) Run the file:
    ```bash
    ./setup.sh
    ```

## TO DO
- Setup an OSInt custom Browser.
- Edit .bash_profile
- Add more functionality to the existing bash shortcuts, such as predefined spiderfoot searches or RiskIQ CLI. 
- VMware tools installation.
- set up  of extra tools: maltego, pycharm, sherlock's clones, etc.
- set osint report templates as libreoffice's templates.
- customise the user profile.

## RESOURCES
- [Open Source Intelligence Techniques - 7th Edition (2019) - Michael Bazzell](https://inteltechniques.com/book1.html)
- [Step by step setup guide](https://inteltechniques.com/osintbook/linux.20.txt) (well... you will need a password to download it!)
- [Open-Source Intelligence Video Training](https://www.inteltechniques.net/courses/open-source-intelligence)
- [OSInt Daily News](https://osintops.com/en/)

## ACKNOWLEDGEMENTS
- This is a fork of the [OSINT_VM_Setup script](https://github.com/Skykn0t/OSINT_VM_Setup) by [Skykn0t](https://github.com/Skykn0t).\
- Credit to [oh6hay](https://github.com/oh6hay) for suggesting the script's name!

## LICENSES
All the licenses mentioned in Bazzell's book apply and are located in this repository in "license.txt"
