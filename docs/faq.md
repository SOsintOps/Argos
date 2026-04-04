# Frequently Asked Questions

---

## Installation

**Which operating systems does Argos support?**
Ubuntu 24.04 LTS and Ubuntu Budgie 24.04 LTS. Ubuntu 22.04 LTS and 20.04 LTS are no longer supported due to incompatible dependencies.

**Do I need an internet connection during installation?**
Yes. The script downloads packages via apt, clones repositories from GitHub, and fetches the latest Obsidian release from the GitHub API. A stable connection is required throughout.

**The script stopped partway through. What do I do?**
Check the installation log at `~/Downloads/argos_install_YYYYMMDD_HHMMSS.log`. The exact line number where the failure occurred is recorded. Fix the underlying issue and re-run the script. Most steps are idempotent — already-installed packages will be skipped by apt and already-cloned repositories will be updated via `git pull`.

**Some packages showed `[WARN] failed to install`. Is that a problem?**
It depends on the package. The script lists all failed packages at the end of the run. Core tools (python3, git, curl, ffmpeg) failing would break subsequent steps. Optional tools (kazam, audacity) failing is not critical. Review the log and install any missing critical packages manually with `sudo apt install <package>`.

**Firefox customisation was skipped. Why?**
The script looks for a Firefox profile directory to apply the Argos template. If Firefox has never been opened, the profile does not exist yet. The script attempts to launch Firefox automatically to create it. If that fails (e.g. in a headless session), open Firefox manually, wait for it to load, close it, then re-run the script.

**Do I need to install VirtualBox Guest Additions before running setup.sh?**
Yes. The script does not install them. Guest Additions must be installed beforehand to enable clipboard sharing, drag-and-drop, and dynamic screen resizing. In VirtualBox, go to Devices → Insert Guest Additions CD Image and follow the prompts, then reboot before running `setup.sh`.

**Can I run the script as root?**
No. The script explicitly blocks root execution. Run it as a regular user with sudo privileges.

**Where is the installation log?**
At `~/Downloads/argos_install_YYYYMMDD_HHMMSS.log`. The full path is printed at the start of every run.

---

## OSINT Tools

**Which tool should I use for username searches?**
Three tools are available, each with different coverage:
- **Sherlock** — fast, broad coverage, good starting point
- **Maigret** — deeper coverage, includes Sherlock's sites plus many more
- **Blackbird** — focuses on social platforms, returns structured output

Start with Maigret for thoroughness. Use Sherlock for speed. All three are accessible from the Usernames launcher.

**What is the difference between Instaloader and Toutatis?**
Instaloader downloads public profile data, posts, and metadata from Instagram without authentication. Toutatis requires an Instagram session ID and returns phone numbers and emails linked to an account. Use Instaloader for public data. Use Toutatis when you have a valid session cookie.

**Which tools require an API key or account?**
- **Maltego** — requires a Maltego account (free or commercial)
- **theHarvester** — works without keys but returns more results with API keys for Bing, VirusTotal, and others. Edit `~/Downloads/Programs/theHarvester/api-keys.yaml` to add keys.
- **recon-ng** — modules requiring API keys will prompt you inside the framework. Add keys with `keys add <provider> <key>`.
- **SpiderFoot** — works standalone but supports optional API keys for enriched data sources via the web interface.

**How do I open recon-ng?**
Use the recon-ng desktop shortcut or launcher. The framework opens in a terminal session. Type `help` for available commands. Modules are installed with `marketplace install <module>`.

**theHarvester or EyeWitness setup failed. What do I do?**
Both tools rely on pip dependencies installed into their own virtual environments. If the pip install step failed, navigate to the tool directory and run the install manually:
```bash
~/Downloads/Programs/theHarvester/.venv/bin/pip install -r ~/Downloads/Programs/theHarvester/requirements/base.txt
```
Replace the path accordingly for other tools.

---

## Operational Security

**Should I use my personal identity or personal accounts during OSINT investigations?**
No. Use dedicated, non-attributable accounts and personas for all investigative activity. Never link investigation accounts to your real identity, to each other, or to accounts used for personal activity. Account cross-contamination is one of the most common sources of exposure.

**Is a VPN enough to protect my identity during investigations?**
A VPN masks your IP address from the targets you query, but it does not protect against browser fingerprinting, account linkage, or metadata leakage. For most investigations, a VPN combined with a dedicated VM and a sanitised browser profile provides an adequate baseline. For high-risk targets, add Tor Browser and treat every session as potentially observed.

**Is running Argos inside a VirtualBox VM sufficient for anonymity?**
A VM sandboxes your investigative activity from your host machine, which limits forensic exposure if the VM is ever examined. It does not anonymise your network traffic. Always route traffic through a VPN before your VM connects to the internet. For sensitive work, use a VM on a device that is not associated with your real identity, connected to a network that is not linked to you.

**What is the correct way to use Tor Browser for OSINT?**
Use Tor Browser only for activities where anonymity is the priority. Do not log into any account you have used outside Tor. Do not resize the browser window (it affects fingerprint). Do not enable JavaScript on high-security settings unless absolutely necessary. Be aware that Tor exit nodes are public knowledge — targets with logging in place will see that the request came from Tor, which may itself attract attention.

**How should I store data collected during an investigation?**
Store all case data in encrypted volumes. Use KeePassXC (included) for credentials and sensitive account data. Keep notes in CherryTree or Obsidian with the relevant folder stored on an encrypted partition. Do not store investigation data in cloud services linked to your real identity. Define a retention policy: delete data that is no longer needed using a secure deletion method.

**I accidentally exposed my real IP address to a target. What do I do?**
Stop the investigation from that IP immediately. Document what was exposed, when, and to which target. If the investigation was conducted on behalf of an organisation, report the incident through the appropriate channels. Rotate your infrastructure before resuming.

**Can targets detect that they are being investigated?**
Yes, in some cases. Viewing a LinkedIn profile without privacy mode enabled notifies the subject. Querying WHOIS records, visiting websites, or interacting with social media can leave traces in server logs. Use passive sources where possible (cached data, third-party databases, archived pages) before making direct queries to live targets.
