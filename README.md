#![screenshot](https://github.com/SOsintOps/Argos/blob/master/wallpaper/banner%20-%20be-quiet-priest-sculpture-in-venlo_by_raffael_herrmann.jpg)

# ARGOS
<img align="right" width="86" height="150" src="https://github.com/SOsintOps/Argos/blob/master/wallpaper/scribblenauts-argos.png">

This script will automatically set up an OSInt workstation starting from a clean Ubuntu* 20.4 Virtual Machine/Workstation.\
It's based on the [Open Source Intelligence Techniques - 7th Edition (2019)](https://inteltechniques.com/book1.html).\
This is a fork of the [OSINT_VM_Setup script](https://github.com/Skykn0t/OSINT_VM_Setup) by [Skykn0t](https://github.com/Skykn0t).\
Credit to [oh6hay](https://github.com/oh6hay) for suggesting the script's name!


## Summary:
Best practices recommend using a new VM for each OSInt investigation.\
There are several ready-made VMs available on the Internet.\
Michael Bazzell and David Westcott proposed a procedure to create your own custom VM. This script will setup the VM by installing all the tools recommended by Bazzell, plus the automated bash scripts he supplies on websites.\
This script implies that you rely on VmWare for virtualization. Just in case, I include a commented out portion of code which will install virtual box tools. 


## Requirements:
Please ensure that:
- You are running an Ubuntu* 20.4 virtual machine.
- Your user has to be "**osint**" for the bash shortcuts to work.


## How to install:
1) Open the Terminal app

2) type:
    ```bash
    cd ~/Downloads/
    ```
3) Make sure that the GIT command is avaible in your sistem:
    ```bash
    sudo apt install git
    ```
4) Clone this repository to the desktop: 
    ```bash
    git clone https://github.com/SOsintOps/Argos
    ```

5) Go to ```/Argos/``` and make the setup script executable:
    ```bash
    cd ~/Downloads/Argos/
    sudo chmod +x setup.sh
    ```
6) Within the ```setup.sh``` replace [PASSWORD] with the current website's password

7) Run the file:
    ```bash
    ./setup.sh
    ```


## TO DO:
- Add bookmarks file for FireFox, then import it.
- Edit .bash_profile
- Add more functionality to the existing bash shortcuts, such as predefined spiderfoot searches or RiskIQ CLI. 
- VMware tools installation.
- set up  of extra tools: maltego, pycharm, cherrytree, sherlock's clones, Holehe, etc.
- set osint report templates as libreoffice's templates.
- customise the user profile.

## Resources:
- [Open Source Intelligence Techniques - 7th Edition (2019) - Michael Bazzell](https://inteltechniques.com/book1.html)
- [Step by step setup guide](https://inteltechniques.com/osintbook/linux.20.txt) (well... you will need a password to download it!)
- [Open-Source Intelligence Video Training](https://www.inteltechniques.net/courses/open-source-intelligence)
- [OSInt Daily News](https://osintops.com/en/)



## License:
All the licenses mentioned in Bazzell's book apply and are located in this repository in "license.txt" 
