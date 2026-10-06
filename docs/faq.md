# Frequently Asked Questions

---

## Installation

**Which operating systems does Argos support?**
Ubuntu and Ubuntu Budgie 24.04 LTS and 26.04 LTS. On other Ubuntu releases the installer warns and continues; on other distributions it stops.

**Ubuntu 26.04 ships Python 3.14. Does that matter?**
No. The Python tools run in their own environments created by uv with Python 3.12 (theHarvester with 3.14, which it requires), so they behave the same on 24.04 and 26.04.

**Where do I clone the repository?**
Anywhere. Version 3 no longer requires `~/Downloads/Argos`: run `./setup.sh` from the folder you cloned.

**The installer reported errors. What do I do?**
Read the summary at the end of the run and the log at `~/Downloads/argos_install_<date>.log`. A failing step does not stop the others. Fix the cause (often a network hiccup) and run only that step again, for example `./setup.sh amass`. `./setup.sh --list` shows the step names.

**How do I know that every tool works?**
Open **Argos Check** from the menu. It starts every tool and lists those that are missing or fail to start.

**How do I update Argos?**
`git pull` in the repository, then `./setup.sh launchers` for the launchers and templates, or `./setup.sh python-tools theharvester amass` to update the tools as well.

**Do I need to install VirtualBox Guest Additions first?**
Yes. Argos does not install them. In VirtualBox use Devices → Insert Guest Additions CD Image, follow the prompts and reboot before running `setup.sh`.

**Can I run the installer as root?**
No. Run it as a normal user with sudo rights; it asks for the password only for the steps that install system packages.

---

## Cases and evidence

**Where are my results?**
In `~/Documents/Argos/cases/<case>/<tool>/<UTC time>_<target>/`. Choose the case with **Argos Case**; without one, results go to `unsorted`.

**What is in a run folder?**
`command.txt` (case, target, operator, tool version, exact command, UTC start and end, exit code), `output.log` (everything the tool printed), the tool's own files, and `SHA256SUMS`. Verify the hashes with `sha256sum -c SHA256SUMS` inside the folder.

**Can I stop a long search?**
Yes. Press Cancel in the progress window: the tool and everything it started are stopped, and the partial results stay in the run folder with exit code 130.

**Can I use the launchers over SSH or without a desktop?**
Yes. Without a graphical session the launchers ask their questions in the terminal. `ARGOS_UI=tty` forces this mode.

---

## OSINT tools

**Which tool should I use for username searches?**
Start with Maigret for depth (3000+ sites, HTML and PDF reports) or Sherlock for speed. Blackbird and User Scanner also accept email addresses. Linkook follows the accounts linked from a profile. Socialscan tells whether a username or email is in use. "All username tools" runs them one after the other.

**What is the difference between Instaloader and Toutatis?**
Instaloader downloads a profile: posts, reels, tagged posts, and, with the session of your Firefox research account, stories, highlights, comments and geotags. Toutatis returns account details and needs a session ID, which Argos never writes to the evidence files.

**Why did Amass find so few subdomains?**
Amass v5 relies on API keys for most passive sources. Without keys, use brute force (on by default) or add keys to `~/.config/amass/datasources.yaml`. theHarvester's free sources are a good first step.

**Which tools need an API key or account?**
- **Shodan**: an API key, asked the first time you open the launcher.
- **Amass** and **theHarvester**: optional keys for more sources (`~/.config/amass/datasources.yaml`, `~/.theHarvester/api-keys.yaml`).
- **recon-ng**: per-module keys, added inside the console with `keys add <name> <key>`.
- **SpiderFoot**: optional keys in its web interface settings.
- **Maltego**: an account; it is not installed by Argos.

**YouTube says "Sign in to confirm you're not a bot". What do I do?**
Sign in to YouTube in Firefox with your research account, then tick "Use my Firefox session" in **Video Download**. Some sites (YouTube, Vimeo) also block addresses of data centres and some VPNs whatever you do; try another network.

**How do I open recon-ng?**
From the menu: it opens a terminal with a workspace named after the active case. Install modules with `marketplace install all`.

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
