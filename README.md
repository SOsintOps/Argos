
<div align="right">
  <details>
    <summary >🌐 Language</summary>
    <div>
      <div align="center">
        <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=en">English</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=zh-CN">简体中文</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=zh-TW">繁體中文</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=ja">日本語</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=ko">한국어</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=hi">हिन्दी</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=th">ไทย</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=fr">Français</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=de">Deutsch</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=es">Español</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=it">Italiano</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=ru">Русский</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=pt">Português</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=nl">Nederlands</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=pl">Polski</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=ar">العربية</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=fa">فارسی</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=tr">Türkçe</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=vi">Tiếng Việt</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=id">Bahasa Indonesia</a>
        | <a href="https://openaitx.github.io/view.html?user=SOsintOps&project=Argos&lang=as">অসমীয়া</
      </div>
    </div>
  </details>
</div>

# ARGOS — Beta
<img align="right" width="215" src="https://github.com/SOsintOps/Argos/blob/master/multimedia/images/scribblenauts-argos.png">

[![ShellCheck](https://github.com/SOsintOps/Argos/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/SOsintOps/Argos/actions/workflows/shellcheck.yml)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![Ubuntu 24.04 LTS](https://img.shields.io/badge/Ubuntu-24.04%20LTS-E95420?logo=ubuntu&logoColor=white)](https://releases.ubuntu.com/noble/)

> **WARNING: BETA VERSION**
> This script has been updated for Ubuntu 24.04 LTS and Ubuntu Budgie 24.04 LTS.
> It is under active testing. Always run it on a clean VM before using it in production.
> Report any problems by opening an issue.

Argos automatically configures an open-source OSINT workstation from a clean Ubuntu 24.04 LTS virtual machine.

Best practice recommends using a dedicated VM for each OSINT investigation.
This script follows the methods described by Michael Bazzell in [Open Source Intelligence Techniques](https://inteltechniques.com/book1.html).

<br clear="all">

## Contents
- [Requirements](#requirements)
- [Tools](#tools)
- [Installation](#installation)
- [Installation Log](#installation-log)
- [To Do](#to-do)
- [Resources](#resources)
- [Credits](#credits)
- [Licences](#licences)
- [Version History](docs/VERSION_HISTORY.md)
- [OSINT Analysis Guidelines](docs/guidelines.md)
- [FAQ](docs/faq.md)

---

## Requirements

- Ubuntu **24.04 LTS** or **Ubuntu Budgie 24.04 LTS** (VM or workstation)
- Any Linux username (the previous requirement to use `osint` has been removed)
- System language: **English**
- Active internet connection during installation
- **VirtualBox Guest Additions already installed** — the script does not install them. Install Guest Additions before running `setup.sh` to enable clipboard sharing, drag-and-drop, and fullscreen support.

> The script is optimised for VirtualBox. Code for VMware Tools is available in the comments.

**Tested on:**
- Ubuntu Budgie 24.04 LTS (VM)
- Ubuntu 24.04 LTS (VM)

**No longer supported:**
- Ubuntu 22.04 LTS (some dependencies are incompatible)
- Ubuntu 20.04 LTS

---

## Tools

### OSINT

| Tool | Status | Notes |
|------|--------|-------|
| [Amass](https://github.com/owasp-amass/amass) | Active | Subdomain enumeration |
| [blackbird](https://github.com/p1ngul1n0/blackbird) | Active | Username and email search across 600+ platforms |
| [ExifTool](https://exiftool.org/) | Active | Metadata from documents and images |
| [Exploratores](https://github.com/SOsintOps/Exploratores) | Active | Browser-based OSINT toolkit (search tools, PII redactor, IBAN analysis, CyberChef) |
| [EyeWitness](https://github.com/FortyNorthSecurity/EyeWitness) | Active | Website screenshots |
| [HTTrack](https://www.httrack.com/) | Active | Web crawling and mirroring |
| [Instaloader](https://instaloader.github.io/) | Active | Instagram OSINT |
| [linkook](https://github.com/JackJuly/linkook) | Active | Linked social accounts and emails from username |
| [maigret](https://github.com/soxoj/maigret) | Active | Username search across 3000+ sites |
| [Maltego](https://www.maltego.com/) | Manual | Link analysis; not auto-installed (requires paid account), install manually if needed |
| [MediaInfo](https://mediaarea.net/en/MediaInfo) | Active | Media metadata analysis |
| [Metagoofil](https://github.com/opsdisk/metagoofil) | Active | Metadata from public documents |
| [PhoneInfoga](https://github.com/sundowndev/phoneinfoga) | Stable | Phone number intelligence (stable, unmaintained) |
| [recon-ng](https://github.com/lanmaster53/recon-ng) | Limited | Modular OSINT framework; maintenance reduced |
| [Sherlock](https://github.com/sherlock-project/sherlock) | Active | Username search across 400+ sites |
| [Shodan CLI](https://cli.shodan.io/) | Active | Internet-exposed host search (requires API key) |
| [socialscan](https://github.com/iojw/socialscan) | Active | Accurate email and username availability checks |
| [SpiderFoot](https://github.com/smicallef/spiderfoot) | Active | OSINT automation (200+ modules) |
| [The Harvester](https://github.com/laramies/theHarvester) | Active | Email and domain recon |
| [Toutatis](https://github.com/megadose/toutatis) | Limited | Requires Instagram session ID |
| [user-scanner](https://github.com/kaifcodec/user-scanner) | Active | Email and username OSINT, 195+ scan vectors |
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | Active | Video downloader (replaces youtube-dl) |

**Removed tools (abandoned or discontinued):**
- ~~Instalooter~~: use Instaloader
- ~~Sublist3r~~: use Amass
- ~~Photon~~: use Katana or GoSpider
- ~~youtube-dl~~: replaced by yt-dlp
- ~~Moriarty-Project~~: replaced by PhoneInfoga
- ~~Elasticsearch-Crawler~~: use Shodan CLI
- ~~Atom Editor~~ (discontinued December 2022): replaced by VSCodium
- ~~holehe~~: abandoned, replaced by user-scanner

### General Tools

| Tool | Status |
|------|--------|
| [Audacity](https://www.audacityteam.org/) | Active |
| [CherryTree](https://www.giuspen.com/cherrytree/) | Active |
| [Google Earth Pro](https://www.google.com/earth/versions/#earth-pro) | Active |
| [Kazam](https://launchpad.net/kazam) | Active |
| [KeePassXC](https://keepassxc.org/) | Active |
| [Obsidian](https://obsidian.md/) | Active (latest version fetched dynamically) |
| [OpenShot](https://www.openshot.org/) | Active |
| [Ripgrep](https://github.com/BurntSushi/ripgrep) | Active |
| [Threat Intelligence Resources](https://github.com/pstirparo/threatintel-resources) | Active |
| [Tor Browser](https://www.torproject.org/) | Active |
| [VLC](https://www.videolan.org/vlc/) | Active |
| [VSCodium](https://vscodium.com/) | Active (replaces Atom) |

---

## Installation

1. Open a terminal.

2. Install Git if it is not already present:
    ```bash
    sudo apt install -y git
    ```

3. Clone the repository into the `Downloads` directory:
    ```bash
    git clone https://github.com/SOsintOps/Argos ~/Downloads/Argos
    ```

4. Make the script executable:
    ```bash
    chmod +x ~/Downloads/Argos/setup.sh
    ```

5. Run the script:
    ```bash
    ~/Downloads/Argos/setup.sh
    ```

    > Firefox does not need to be closed or opened manually. The script deploys an enterprise `policies.json` (privacy hardening, OSINT extensions, managed bookmarks) to the Firefox distribution directory; it is applied automatically on the next Firefox launch. Firefox opens the local Exploratores toolkit as its homepage.

---

## Installation Log

The script automatically generates a log file in the Downloads directory:

```
~/Downloads/argos_install_YYYYMMDD_HHMMSS.log
```

The log contains the full installation output with timestamps. If an error occurs, the exact line number is recorded in the log.

---

## To Do

- Add Katana or GoSpider as a replacement for Photon
- Update LibreOffice report templates for OSINT investigations
- Complete end-to-end testing on Ubuntu Budgie 24.04 LTS VM
- Add shortcuts for maigret standalone and blackbird standalone

---

## Resources

- [OSIntOps website](https://osintops.com/en/)
- [The Argos Project: an OSINT-ready VM in minutes](https://osintops.com/en/the-argos-project/)
- [Argos is back, and it's not alone!](https://osintops.com/en/argos-refresh-speculator-incoming/)
- [OSInt Daily News](https://t.me/Osintlatestnews)
- [Open Source Intelligence Techniques by Michael Bazzell](https://inteltechniques.com/book1.html)
- [Deep Dive: Exploring the Real-world Value of Open Source Intelligence by Rae Baker](https://www.wiley.com/en-us/Deep+Dive%3A+Exploring+the+Real+world+Value+of+Open+Source+Intelligence-p-9781119933243)

---

## Credits

- Skykn0t for the original OSINT_VM_Setup script
- [oh6hay](https://github.com/oh6hay) for the script name
- [pinkevilpimp](https://github.com/pinkevilpimp) for the wallpaper script

---

## Licences

See the licence files included in the repository.
