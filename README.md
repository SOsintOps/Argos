# ARGOS
<img align="right" width="215" src="multimedia/images/scribblenauts-argos.png" alt="Argos mascot">

[![Checks](https://github.com/SOsintOps/Argos/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/SOsintOps/Argos/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ubuntu 24.04 LTS](https://img.shields.io/badge/Ubuntu-24.04%20LTS-E95420?logo=ubuntu&logoColor=white)](https://releases.ubuntu.com/noble/)

Argos turns a clean Ubuntu 24.04 LTS virtual machine into an OSINT workstation:
it installs the tools, adds a menu entry for each task, and saves every result
in a case folder with the command used, the full output and SHA-256 hashes.

> **3.0.0-beta.** Version 3 is a complete rewrite. The launchers are covered by
> automated tests; the full installation on a fresh VM is being validated
> before the stable release. Please report problems in the issues.

<br clear="all">

## Contents
- [What Argos does](#what-argos-does)
- [Requirements](#requirements)
- [Installation](#installation)
- [Working with cases](#working-with-cases)
- [Launchers](#launchers)
- [Other tools installed](#other-tools-installed)
- [Privacy and OPSEC](#privacy-and-opsec)
- [Report templates](#report-templates)
- [Development and tests](#development-and-tests)
- [Resources](#resources) · [Credits](#credits) · [Licence](#licence)
- [Architecture](docs/ARCHITECTURE.md) · [FAQ](docs/faq.md) · [Analysis guidelines](docs/guidelines.md) · [Version history](docs/VERSION_HISTORY.md)

---

## What Argos does

- **One menu entry per investigative task**: usernames and emails, Instagram,
  domains, web screenshots, public documents and metadata, video download and
  analysis, Shodan, SpiderFoot, phone numbers, recon-ng, website copies.
- **Cases**: choose a case once, and every result lands in
  `~/Documents/Argos/cases/<case>/`.
- **Evidence you can defend**: each run folder holds `command.txt` (exact
  command, tool version, UTC start/end, exit code), `output.log` (everything
  the tool printed) and `SHA256SUMS` (hash of every file produced).
- **Up-to-date tools**: Amass v5, theHarvester 5, current Maigret with PDF
  reports, SpiderFoot from source, Shodan CLI that actually starts, binaries
  downloaded from the official releases with their checksums verified.
- **Works on the desktop and in a terminal**: dialogs on the desktop, plain
  prompts over SSH; a running tool can be cancelled from its progress window.

## Requirements

- Ubuntu **24.04 LTS** or Ubuntu Budgie **24.04 LTS**, preferably a dedicated
  virtual machine for each investigation.
- A user with `sudo` rights (do not run the installer as root).
- System language: English.
- Internet access during the installation.
- VirtualBox users: install the Guest Additions first; Argos does not.

## Installation

```bash
sudo apt install -y git
git clone https://github.com/SOsintOps/Argos.git
cd Argos
./setup.sh
```

The installer can be run from any folder. It logs everything to
`~/Downloads/argos_install_<date>.log`, carries on when a single tool fails,
and lists all problems in a summary at the end. Reboot when it finishes.

Then open **Argos Check** from the menu: it starts every tool and reports
anything that is missing or broken.

Run only some steps, for example to update the launchers after a `git pull`:

```bash
./setup.sh --list          # show the steps
./setup.sh launchers       # reinstall launchers, icons and menu entries
./setup.sh python-tools amass theharvester   # update those tools
```

## Working with cases

1. Open **Argos Case** and create a case (for example `2026-017-fraud`).
   The case folder starts with `notes/` (research log and CherryTree
   notebook), `reports/`, `manual-captures/` and `deliverables/`.
2. Use any launcher: results go to
   `~/Documents/Argos/cases/2026-017-fraud/<tool>/<UTC time>_<target>/`.
3. Quote the run folder and the SHA-256 in your report's source table.

Without a case, results go to the case `unsorted`.

## Launchers

| Menu entry | Tools | What it adds |
|---|---|---|
| Argos Case | — | create, switch and open cases |
| Usernames & Emails | Sherlock, Maigret, Blackbird, User Scanner, Linkook, Socialscan | report formats, scope, email search, start from a profile URL, all tools in one go |
| Instagram | Instaloader, Toutatis | posts, reels, tagged posts; stories, highlights, comments and geotags with your Firefox session |
| Domains | theHarvester 5, Amass v5 | free sources by default; brute force, altered names, optional active checks |
| Web Screenshots | EyeWitness | one URL, a URL list, or the web services of an Nmap/Nessus XML report |
| Documents & Metadata | metagoofil, ExifTool | document types, metadata CSV, names and software found in the documents; also for a folder you already have |
| Video Download | yt-dlp | video, audio or metadata only; description, thumbnail, subtitles, comments, playlists |
| Video Tools | ffmpeg, ffprobe, ExifTool | technical report, MP4 conversion, frames, motion-only summary, audio, rotation, clip cut, contact sheet |
| Shodan | Shodan CLI | search saved as JSON and CSV, host history, domain records, free result counts |
| SpiderFoot | SpiderFoot | web interface, or a passive/footprint/investigate scan saved in the case |
| PhoneInfoga | PhoneInfoga | single number scan saved in the case, or the web interface |
| recon-ng | recon-ng | console with a workspace named after the case |
| Website Mirror | HTTrack | offline copy of a site, depth control, robots.txt respected by default |
| Exploratores | [Exploratores](https://github.com/SOsintOps/Exploratores) | browser-based OSINT toolkit, also Firefox's home page |
| X (Twitter) | — | opens x.com |
| Argos Check | — | checks that every tool starts |

## Other tools installed

Audacity, CherryTree, Google Earth Pro, Kazam, KeePassXC, MediaInfo, Obsidian
(with [OSINT templates](https://github.com/WebBreacher/obsidian-osint-templates)),
OpenShot, ripgrep, Tor Browser, proxychains, VLC, VSCodium, 7-Zip, and the
[threat intelligence](https://github.com/pstirparo/threatintel-resources) and
[intelligence writing](https://github.com/mxm0z/awesome-intelligence-writing)
reading lists in `~/Documents/Resources`. Firefox gets enterprise policies for
privacy, OSINT extensions and bookmarks.

Maltego is not installed (it needs an account); install it manually if you use it.

## Privacy and OPSEC

- Options that send your target to a third-party service (Blackbird AI,
  Hudson Rock breach lookups) are **off by default** and ask for confirmation
  each time, naming the service.
- Options that can alert the target (User Scanner "loud" checks, Amass active
  checks) show a warning first.
- API keys and session IDs are never written to `command.txt`.
- Instaloader uses the session of your Firefox research account: Argos never
  asks for, or stores, an Instagram password.

## Report templates

`~/Templates` receives report templates written for Argos: full report,
executive summary, subject profile, event assessment, threat notice, case
cover sheet with chain of custody, online investigations policy, a plain
Markdown report, a research log (CSV), scratch notes and a CherryTree case
notebook. Their source table links each finding to an Argos run folder and
its SHA-256. The `.docx` files are generated by `templates/src/build_templates.py`.

## Development and tests

```bash
shellcheck -x -P launchers setup.sh launchers/*.sh launchers/lib/argos.sh
bats tests/
```

The tests run the launchers in terminal mode against test doubles of every
tool: no network, a few seconds. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Resources

- [OSINT Ops website](https://osintops.com/en/)
- [The Argos Project: an OSINT-ready VM in minutes](https://osintops.com/en/the-argos-project/)
- [Argos is back, and it's not alone!](https://osintops.com/en/argos-refresh-speculator-incoming/)
- [OSINT Daily News](https://t.me/Osintlatestnews)
- [Open Source Intelligence Techniques](https://inteltechniques.com/book1.html) by Michael Bazzell
- [Deep Dive: Exploring the Real-world Value of Open Source Intelligence](https://www.wiley.com/en-us/Deep+Dive%3A+Exploring+the+Real+world+Value+of+Open+Source+Intelligence-p-9781119933243) by Rae Baker

## Credits

- Argos started from Skykn0t's OSINT_VM_Setup script and the workstation
  approach described by Michael Bazzell. Version 3 is a new implementation:
  its code, launchers, icons and templates were written from scratch.
- [oh6hay](https://github.com/oh6hay) for the name.
- The authors of every tool Argos installs: their licences apply to their tools.
- Media credits: [multimedia/CREDITS.md](multimedia/CREDITS.md).

## Licence

Argos is released under the [MIT licence](LICENSE). Versions up to 2.1.1-beta
were distributed under CC BY-NC-SA 4.0 and remain available under that licence
in the repository history.
