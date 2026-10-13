# Frequently Asked Questions (FAQ)

Frequently asked questions about Argos — installation, cases and evidence, the OSINT tools, analysis and reporting, and operational security.

## Table of Contents

* [Installation](#installation)
    * [Which operating systems does Argos support?](#which-operating-systems-does-argos-support)
    * [Ubuntu 26.04 ships Python 3.14. Does that matter?](#ubuntu-2604-ships-python-314-does-that-matter)
    * [Where do I clone the repository?](#where-do-i-clone-the-repository)
    * [The installer reported errors. What do I do?](#the-installer-reported-errors-what-do-i-do)
    * [How do I know that every tool works?](#how-do-i-know-that-every-tool-works)
    * [How do I update Argos?](#how-do-i-update-argos)
    * [Do I need to install VirtualBox Guest Additions first?](#do-i-need-to-install-virtualbox-guest-additions-first)
    * [Can I run the installer as root?](#can-i-run-the-installer-as-root)
* [Cases and Evidence](#cases-and-evidence)
    * [Where are my results?](#where-are-my-results)
    * [What is in a run folder?](#what-is-in-a-run-folder)
    * [Can I stop a long search?](#can-i-stop-a-long-search)
    * [Can I use the launchers over SSH or without a desktop?](#can-i-use-the-launchers-over-ssh-or-without-a-desktop)
* [OSINT Tools](#osint-tools)
    * [Which tool should I use for username searches?](#which-tool-should-i-use-for-username-searches)
    * [What is the difference between Instaloader and Toutatis?](#what-is-the-difference-between-instaloader-and-toutatis)
    * [Why did Amass find so few subdomains?](#why-did-amass-find-so-few-subdomains)
    * [Which tools need an API key or account?](#which-tools-need-an-api-key-or-account)
    * [YouTube says "Sign in to confirm you're not a bot". What do I do?](#youtube-says-sign-in-to-confirm-youre-not-a-bot-what-do-i-do)
    * [How do I open recon-ng?](#how-do-i-open-recon-ng)
* [Analysis and Reporting](#analysis-and-reporting)
    * [Where is the analysis method explained?](#where-is-the-analysis-method-explained)
    * [Which report template should I use?](#which-report-template-should-i-use)
    * [How do I grade a source?](#how-do-i-grade-a-source)
    * [How do I say how sure I am?](#how-do-i-say-how-sure-i-am)
    * [Is a Maigret or Sherlock hit a finding?](#is-a-maigret-or-sherlock-hit-a-finding)
    * [Are there other SOsintOps projects that work with Argos?](#are-there-other-sosintops-projects-that-work-with-argos)
* [Operational Security](#operational-security)
    * [Should I use my personal identity or personal accounts during OSINT investigations?](#should-i-use-my-personal-identity-or-personal-accounts-during-osint-investigations)
    * [Is a VPN enough to protect my identity during investigations?](#is-a-vpn-enough-to-protect-my-identity-during-investigations)
    * [Is running Argos inside a VirtualBox VM sufficient for anonymity?](#is-running-argos-inside-a-virtualbox-vm-sufficient-for-anonymity)
    * [What is the correct way to use Tor Browser for OSINT?](#what-is-the-correct-way-to-use-tor-browser-for-osint)
    * [How should I store data collected during an investigation?](#how-should-i-store-data-collected-during-an-investigation)
    * [I accidentally exposed my real IP address to a target. What do I do?](#i-accidentally-exposed-my-real-ip-address-to-a-target-what-do-i-do)
    * [Can targets detect that they are being investigated?](#can-targets-detect-that-they-are-being-investigated)

---

## Installation

### Which operating systems does Argos support?
Ubuntu Budgie 24.04 LTS and 26.04 LTS. On other releases of the Ubuntu family the installer warns and continues; on other distributions it stops.

### Ubuntu 26.04 ships Python 3.14. Does that matter?
No. The Python tools run in their own environments created by uv with Python 3.12 (theHarvester with 3.14, which it requires), so they behave the same on Ubuntu Budgie 24.04 and 26.04 LTS.

### Where do I clone the repository?
Anywhere. Version 3 no longer requires `~/Downloads/Argos`: run `./setup.sh` from the folder you cloned.

### The installer reported errors. What do I do?
Read the summary at the end of the run and the log at `~/Downloads/argos_install_<date>.log`. A failing step does not stop the others. Fix the cause (often a network hiccup) and run only that step again, for example `./setup.sh amass`. `./setup.sh --list` shows the step names.

### How do I know that every tool works?
Open **Argos Check** from the menu. It starts every tool and lists those that are missing or fail to start.

### How do I update Argos?
`git pull` in the repository, then `./setup.sh launchers templates` for the launchers and the report templates, or `./setup.sh python-tools theharvester amass` to update the tools as well.

### Do I need to install VirtualBox Guest Additions first?
Yes. Argos does not install them. In VirtualBox use Devices → Insert Guest Additions CD Image, follow the prompts and reboot before running `setup.sh`.

### Can I run the installer as root?
No. Run it as a normal user with sudo rights; it asks for the password only for the steps that install system packages.

---

## Cases and Evidence

### Where are my results?
In `~/Documents/Argos/cases/<case>/<tool>/<UTC time>_<target>/`. Choose the case with **Argos Case**; without one, results go to `unsorted`.

### What is in a run folder?
`command.txt` (Argos version, case, target, operator, tool version, exact command, UTC start and end, exit code), `output.log` (everything the tool printed), the tool's own files, and `SHA256SUMS`. Verify the hashes with `sha256sum -c SHA256SUMS` inside the folder.

### Can I stop a long search?
Yes. Press Cancel in the progress window: the tool and everything it started are stopped, and the partial results stay in the run folder with exit code 130.

### Can I use the launchers over SSH or without a desktop?
Yes. Without a graphical session the launchers ask their questions in the terminal. `ARGOS_UI=tty` forces this mode.

---

## OSINT Tools

### Which tool should I use for username searches?
Start with Maigret for depth (3000+ sites, HTML and PDF reports) or Sherlock for speed. Blackbird and User Scanner also accept email addresses. Linkook follows the accounts linked from a profile. Socialscan tells whether a username or email is in use. "All username tools" runs them one after the other.

### What is the difference between Instaloader and Toutatis?
Instaloader downloads a profile: posts, reels, tagged posts, and, with the session of your Firefox research account, stories, highlights, comments and geotags. Toutatis returns account details and needs a session ID, which Argos never writes to the evidence files.

### Why did Amass find so few subdomains?
Amass v5 relies on API keys for most passive sources. Without keys, use brute force (on by default) or add keys to `~/.config/amass/datasources.yaml`. theHarvester's free sources are a good first step.

### Which tools need an API key or account?
- **Shodan**: an API key, asked the first time you open the launcher.
- **Amass** and **theHarvester**: optional keys for more sources (`~/.config/amass/datasources.yaml`, `~/.theHarvester/api-keys.yaml`).
- **recon-ng**: per-module keys, added inside the console with `keys add <name> <key>`.
- **SpiderFoot**: optional keys in its web interface settings.
- **Telegram check**: a Telegram account (use a research account) and an API ID and hash from https://my.telegram.org/apps; asked in the terminal the first time. To study a chat you have exported from Telegram Desktop instead, [TGchat-analytics](https://github.com/SOsintOps/TGchat-analytics), the SOsintOps fork of chat-analytics, builds statistical reports from the HTML export, Chinese, Japanese, Korean and Russian chats included; it is not installed by Argos.
- **Maltego**: an account; it is not installed by Argos.

### YouTube says "Sign in to confirm you're not a bot". What do I do?
Sign in to YouTube in Firefox with your research account, then tick "Use my Firefox session" in **Video Download**. Some sites (YouTube, Vimeo) also block addresses of data centres and some VPNs whatever you do; try another network.

### How do I open recon-ng?
From the menu: it opens a terminal with a workspace named after the active case. Install modules with `marketplace install all`.

---

## Analysis and Reporting

### Where is the analysis method explained?
In the [analysis guidelines](guidelines.md), which cover what is specific to Argos, and in the [Intelligence Field Notes](https://github.com/SOsintOps/intelligence-field-notes), the notes on analytic standards, OSINT method, estimative language, source evaluation and report writing shared by all the SOsintOps tools. A copy is in [`docs/field-notes`](field-notes/README.md) and the installer clones the notes into `~/Documents/Resources` for offline reading, next to Ygor Maximo's [awesome-intelligence-writing](https://github.com/mxm0z/awesome-intelligence-writing) list (SOsintOps keeps a [fork](https://github.com/SOsintOps/awesome-intelligence-writing)).

### Which report template should I use?
See [Writing the report with Argos](report-writing.md): full report, executive summary, plain Markdown report, subject profile, event assessment, threat notice, case cover sheet and investigations policy, with what each is for. The full and plain reports keep the key judgements apart from the findings, as the field notes ask.

### How do I grade a source?
With the [UNODC](https://www.unodc.org/documents/organized-crime/Law-Enforcement/Criminal_Intelligence_for_Analysts.pdf) 4 x 4 system printed in every template: the source A, B, C or X, the information 1 to 4, written together as `B2`. The platform is not the source: grade the person or body that produced the information. See [Source Evaluation](field-notes/source-evaluation.md). Templates made before 3.1.2-beta used the 6 x 6 scale; run `./setup.sh templates` to get the new ones.

### How do I say how sure I am?
Use one of the [ICD 203](https://www.dni.gov/files/documents/ICD/ICD-203.pdf) likelihood terms printed in the templates (almost no chance, very unlikely, unlikely, roughly even chance, likely, very likely, almost certain) for events, and High, Moderate or Low confidence for your judgements, never both in the same sentence. Facts in the findings table take neither. See [Estimative Language](field-notes/estimative-language.md).

### Is a Maigret or Sherlock hit a finding?
No. It is a lead: a site answered for that username. Open the profile, capture it, and decide with stated confidence whether it belongs to your subject. The same holds for every tool that returns matches or scores.

### Are there other SOsintOps projects that work with Argos?
Yes:
- [Speculator](https://github.com/SOsintOps/Speculator-Project) is the sister workstation for Debian 13, with the same templates.
- [Wukong](https://github.com/SOsintOps/Wukong) is the China-focused spin-off of Speculator.
- [Quaesitor](https://github.com/SOsintOps/quaesitor), the case graph, is installed by Argos.
- [Exploratores](https://github.com/SOsintOps/Exploratores), the browser toolkit, is Firefox's home page; [Claudii Exploratores](https://github.com/SOsintOps/claudii-exploratores) offers its catalogue as an agent skill and an MCP server for Claude (alpha).

For particular cases:
- [Elementary CTI](https://github.com/SOsintOps/elementary-CTI) tracks ransomware victims and actors.
- [Aethelburg](https://github.com/SOsintOps/Aethelburg-project) analyses UK company registers for shell companies.
- [TelEgrapherX](https://github.com/SOsintOps/TelEgrapherX) collects Telegram groups and channels.
- [Acta Diurna](https://github.com/SOsintOps/acta-diurna) monitors Italian law-enforcement news.
- [Il Conclave](https://github.com/SOsintOps/il-conclave), a Claude Code skill in Italian, puts a question through forced analytic procedures (ACH, premortem, steelman) before you commit to a key judgement.

[Codex Machinae](https://github.com/SOsintOps/codex-machinae) is the playbook the projects are built with.

---

## Operational Security

### Should I use my personal identity or personal accounts during OSINT investigations?
No. Use dedicated, non-attributable accounts and personas for all investigative activity. Never link investigation accounts to your real identity, to each other, or to accounts used for personal activity. Account cross-contamination is one of the most common sources of exposure.

### Is a VPN enough to protect my identity during investigations?
A VPN masks your IP address from the targets you query, but it does not protect against browser fingerprinting, account linkage, or metadata leakage. For most investigations, a VPN combined with a dedicated VM and a sanitised browser profile provides an adequate baseline. For high-risk targets, add Tor Browser and treat every session as potentially observed.

### Is running Argos inside a VirtualBox VM sufficient for anonymity?
A VM sandboxes your investigative activity from your host machine, which limits forensic exposure if the VM is ever examined. It does not anonymise your network traffic. Always route traffic through a VPN before your VM connects to the internet. For sensitive work, use a VM on a device that is not associated with your real identity, connected to a network that is not linked to you.

### What is the correct way to use Tor Browser for OSINT?
Use Tor Browser only for activities where anonymity is the priority. Do not log into any account you have used outside Tor. Do not resize the browser window (it affects fingerprint). Do not enable JavaScript on high-security settings unless absolutely necessary. Be aware that Tor exit nodes are public knowledge — targets with logging in place will see that the request came from Tor, which may itself attract attention.

### How should I store data collected during an investigation?
Store all case data in encrypted volumes. Use KeePassXC (included) for credentials and sensitive account data. Keep notes in CherryTree or Obsidian with the relevant folder stored on an encrypted partition. Do not store investigation data in cloud services linked to your real identity. Define a retention policy: delete data that is no longer needed using a secure deletion method.

### I accidentally exposed my real IP address to a target. What do I do?
Stop the investigation from that IP immediately. Document what was exposed, when, and to which target. If the investigation was conducted on behalf of an organisation, report the incident through the appropriate channels. Rotate your infrastructure before resuming.

### Can targets detect that they are being investigated?
Yes, in some cases. Viewing a LinkedIn profile without privacy mode enabled notifies the subject. Querying WHOIS records, visiting websites, or interacting with social media can leave traces in server logs. Use passive sources where possible (cached data, third-party databases, archived pages) before making direct queries to live targets.
