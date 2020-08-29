# OSINT_VM_Setup
Automatically setup a clean Ubuntu 20.4 Virtual Machine. From https://inteltechniques.com/osintbook/

## Summary:
Every OSINT investigation should use a clean VM. Thankfully, Michael Bazzell and David Westcott have outlined an excellent method for setting up a VM as well as many helpful tools. This script will setup the VM by installing all the tools recommended by Bazzell, plus the automated bash scripts he supplies on websites. Bazzel's book uses virtual box, but I personally use VmWare, so will include a commented out portion of code which will install vmware tools. 

## Requirements:
For the tool to work, please ensure you are running an Ubuntu 20.4 virtual machine. Also, your username has to be "OSINT" for the bash shortcuts to work.


## Future Plans:
- Add bookmarks file for FireFox, then import it.

- Edit .bash_profile

- Add more functionality to the existing bash shortcuts, such as predefined spiderfoot searches or RiskIQ CLI. 


## Resources:
- [Open Source Intelligence Techniques - 7th Edition (2019) - Michael Bazzell](https://inteltechniques.com/book1.html)

- [Step by step setup guide](https://inteltechniques.com/osintbook/linux.txt)

## License:
All the licenses mentioned in Bazzell's book apply and are located in this repository in "license.txt" 