# OsintUbU (temp name)
This is a fork of the [OSINT_VM_Setup script](https://github.com/Skykn0t/OSINT_VM_Setup) by [Skykn0t](https://github.com/Skykn0t).
It automatically setup  an osint desktop from a clean Ubuntu* 20.4 Virtual Machine. 
Based on the https://inteltechniques.com/osintbook/

## Summary:
Every OSINT investigation should use a clean VM.
Thankfully, Michael Bazzell and David Westcott have outlined an excellent method for setting up a VM as well as many helpful tools.
This script will setup the VM by installing all the tools recommended by Bazzell, plus the automated bash scripts he supplies on websites.
Bazzel's book uses virtual box, but I personally use VmWare, so will include a commented out portion of code which will install vmware tools. 

## Requirements:
For the tool to work, please ensure you are running an Ubuntu 20.4 virtual machine. Also, your username has to be "OSINT" for the bash shortcuts to work.

## Usage:
1) Ensure you are in your terminal and located at the ```/Desktop/```.

2) Copy this repository link, and clone it to the desktop with 

    ```bash
    git clone https://github.com/SOsintOps/OSINT_VM_Setup/
    ```

3) go to the ```/OSINT_VM_Setup/``` and make the setup script executible:

    ```bash
    sudo chmod +x setup.sh
    ```

4) Run the install command:

    ```bash
    ./setup.sh
    ```


## Future Plans:
- Add bookmarks file for FireFox, then import it.
- Edit .bash_profile
- Add more functionality to the existing bash shortcuts, such as predefined spiderfoot searches or RiskIQ CLI. 
- VMware tools installation
- set up  of extra tools: maltego, pycharm, cherrytree, sherlock's clones, Holehe, etc.
- set osint report templates as libreoffice's templates
- customise the user profile

## Resources:
- [Open Source Intelligence Techniques - 7th Edition (2019) - Michael Bazzell](https://inteltechniques.com/book1.html)
- [Step by step setup guide](https://inteltechniques.com/osintbook/linux.20.txt) (well... you will need a password to download it!)
- [Open-Source Intelligence Video Training](https://www.inteltechniques.net/courses/open-source-intelligence)
- [OSInt Daily News](https://osintops.com/en/)



## License:
All the licenses mentioned in Bazzell's book apply and are located in this repository in "license.txt" 
