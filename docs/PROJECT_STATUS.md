# Argos — Project Status & AI Handoff Document

**Last updated:** 2026-07-04
**Current version:** 2.1.0-beta
**Target platform:** Ubuntu 24.04 LTS (Noble Numbat) + Ubuntu Budgie 24.04 LTS

---

## What This Project Is

Argos is a **bash-based OSINT workstation setup script** for Ubuntu. It:
1. Installs and configures OSINT tools on a fresh Ubuntu 24.04 VM
2. Provides a set of zenity-based GUI launcher scripts for each tool
3. Installs `.desktop` shortcuts to the application menu
4. Customizes Firefox (via an enterprise `policies.json`), wallpaper, and desktop environment

Any Linux username is supported. The `.desktop` files contain `__HOME__` as a placeholder; `setup.sh` substitutes the real `$HOME` at install time via `sed`. The same substitution is applied to `config/policies.json`, which contains local `file://` URLs.
The scripts in `scripts/` are GUI wrappers (zenity dialogs) for OSINT tools.
The files in `shortcuts/` are `.desktop` entries that call those wrappers.

---

## Repository Structure

```
Argos/
├── setup.sh                        # Main install script — run once on a fresh VM
├── config/
│   └── policies.json               # Firefox enterprise policies (privacy, extensions, bookmarks)
├── scripts/                        # GUI launcher scripts (zenity)
│   ├── youtubedl.sh                # yt-dlp video downloader
│   ├── instagram.sh                # Instaloader + Toutatis
│   ├── usernames.sh                # Sherlock + Maigret + Blackbird + User Scanner + Linkook + Socialscan
│   ├── spiderfoot.sh               # SpiderFoot launcher (pipx)
│   ├── domains.sh                  # Amass + theHarvester
│   ├── shodan.sh                   # Shodan CLI wrapper (replaces Elasticsearch-Crawler)
│   ├── eyewitness.sh               # EyeWitness screenshot tool
│   ├── metagoofil.sh               # Metagoofil + optional ExifTool
│   ├── recon-ng.sh                 # recon-ng framework launcher
│   ├── phoneinfoga.sh              # PhoneInfoga web UI launcher
│   └── ffmpeg_interact.sh          # ffmpeg video utilities
├── shortcuts/                      # .desktop files → copied to /usr/share/applications/
├── multimedia/
│   ├── icons/                      # Icons for .desktop shortcuts
│   ├── wallpapers/
│   │   └── background.sh           # Sets wallpaper per desktop session type
│   └── images/
├── templates/                      # OSINT report templates (docx, ctb, txt)
├── test/
│   └── usernames-test.sh           # Checks username tools are installed
└── docs/
    ├── CHANGELOG.md
    ├── VERSION_HISTORY.md
    ├── guidelines.md
    ├── faq.md
    └── PROJECT_STATUS.md           # This file
```

> The `argosfox/` Firefox profile template (zip archive from 2022) is no longer used at
> install time. It was replaced by `config/policies.json` in v2.0.7-beta and the archives
> have been removed from the working tree.

---

## Current Tool Installation Architecture

Python tools are split into two categories to comply with PEP 668 (Python 3.12, Ubuntu 24.04):

### Installed via `pipx` (CLI tools, isolated envs in `~/.local/share/pipx/`)
| Tool | Command |
|------|---------|
| Instaloader | `~/.local/bin/instaloader` |
| Toutatis | `~/.local/bin/toutatis` |
| Maigret | `~/.local/bin/maigret` |
| Sherlock | `~/.local/bin/sherlock` |
| SpiderFoot | `~/.local/bin/spiderfoot` |
| User Scanner | `~/.local/bin/user-scanner` |
| Linkook | `~/.local/bin/linkook` |
| Socialscan | `~/.local/bin/socialscan` |
| Shodan CLI | `~/.local/bin/shodan` |

> **Important**: scripts launched with `Terminal=false` in their `.desktop` file
> must use the **full path** `$HOME/.local/bin/<tool>`, as `~/.bashrc` is NOT sourced
> for non-terminal desktop launches.

### Installed via `python3 -m venv` (tools with complex dependencies)
| Tool | venv path |
|------|-----------|
| theHarvester | `~/Downloads/Programs/theHarvester/.venv` |
| metagoofil | `~/Downloads/Programs/metagoofil/.venv` |
| recon-ng | `~/Downloads/Programs/recon-ng/.venv` |
| blackbird | `~/Downloads/Programs/blackbird/.venv` |

### Installed as a binary / cloned repo
| Tool | Location |
|------|----------|
| PhoneInfoga | `/usr/local/bin/phoneinfoga` (Go binary) |
| EyeWitness | `~/Downloads/Programs/EyeWitness/` (cloned repo) |
| Exploratores | `~/Documents/Exploratores/` (static HTML/CSS/JS toolkit, entry point `launchme.html`) |

### Installed via `apt` / `snap` (system packages)
`yt-dlp`, `amass` (snap), `ripgrep`, `ffmpeg`, `exiftool`, `httrack`, `tor`, `proxychains4`, `obsidian` (snap), `cherrytree` (snap), `codium`, etc.

---

## Firefox Customisation

Since v2.0.7-beta, Firefox is customised via a single enterprise `config/policies.json`
(based on the [Speculator Project](https://github.com/SOsintOps/Speculator-Project)),
deployed by `setup.sh` to:
- **Snap Firefox**: `/etc/firefox/policies/policies.json`
- **Deb Firefox**: `/usr/lib/firefox/distribution/policies.json`

No profile detection, no zip handling, no Firefox auto-launch is required. The `__HOME__`
placeholder in `policies.json` is substituted with the real `$HOME` at deploy time (the
file contains local `file://` URLs pointing at the Exploratores toolkit).

What it configures: privacy hardening (telemetry, tracking, fingerprinting, WebRTC,
geolocation disabled), permission lockdown, sanitise-on-shutdown, 12 OSINT extensions
auto-installed, managed OSINT bookmark folders, and the Exploratores toolkit set as the
Firefox homepage (not locked, so the user can change it).

Verify with `about:policies` in Firefox after installation.

---

## Known Limitations & Open Issues

### High Priority: Must Fix Before Stable Release

1. **Not fully tested on a real VM at v2.1.0-beta.**
   A full end-to-end test on a fresh Ubuntu 24.04 LTS and Ubuntu Budgie 24.04 LTS VM is
   required before removing the beta label. In particular verify:
   - Firefox picks up `policies.json` (`about:policies`): extensions installed, bookmarks
     toolbar visible, privacy settings locked, Exploratores homepage loads.
   - The new launchers work: `user-scanner`, `linkook`, `socialscan` in `usernames.sh`;
     `phoneinfoga.sh` (web UI on `http://127.0.0.1:5000`); `shodan.sh` (API-key prompt +
     search). **Confirm the `user-scanner` binary name and flags (`-u/-e -f json -o`)
     with a real `user-scanner --help`, as they were taken from upstream docs.**

2. **CherryTree snap package name** — `sudo snap install cherrytree`. Verify this is the
   correct snap name on Ubuntu 24.04. The alternative PPA fallback exists but the PPA may
   not have a Noble (24.04) build.

3. **EyeWitness dependency install may fail on Ubuntu 24.04 (PEP 668).**
   EyeWitness runs its own bundled setup script. `eyewitness.sh` now prefers a `.venv`
   Python if present and falls back to system `python3`, with a clear error dialog on
   failure — but a failing upstream setup still leaves the tool unusable. Verify on VM.

### Medium Priority: Should Fix

4. **No standalone desktop shortcuts for maigret and blackbird.**
   They are reachable via `usernames.sh` but have no dedicated menu entry.

5. **Report templates in `templates/` are from 2020.** Consider updating with current OSINT
   methodology best practices.

6. **CherryTree template (`.ctb`) may need updating** for the current CherryTree version.

### Low Priority: Nice to Have

7. **Add Katana or GoSpider as replacement for Photon.** Both are Go-based, actively
   maintained web crawlers.

8. **No automated functional test suite.** `test/usernames-test.sh` only checks if binaries
   exist; there are no tests that verify tool output, venv integrity, or `.desktop` validity.

9. **Dedicated icons for the newest tools.** `exploratores.desktop`, `phoneinfoga.desktop`,
   and `shodan.desktop` use freedesktop stock icon names (`firefox`, `phone`,
   `network-server`) because no dedicated PNG exists in `multimedia/icons/`.

### Resolved (kept for history)

- ~~**Elasticsearch-Crawler is a dead script.**~~ **Resolved v2.1.0-beta.** Removed and
  replaced by a Shodan CLI wrapper (`shodan.sh`).
- ~~**user-scanner / linkook / socialscan / PhoneInfoga installed but no launcher.**~~
  **Resolved v2.1.0-beta.** All four now have GUI launchers / shortcuts.
- ~~**`amass enum -src` breaks on Amass v4.**~~ **Resolved v2.1.0-beta.** `-src` removed.
- ~~**Blackbird opened an empty output folder.**~~ **Resolved v2.1.0-beta.** Opens the real
  `results/` directory.
- ~~**`setup.sh` could abort on a failed Obsidian/VSCodium download.**~~ **Resolved
  v2.1.0-beta.** Those steps are now guarded with `|| log_warn` / `if/else`.
- ~~**Firefox profile customization may fail silently.**~~ **Resolved v2.0.7-beta.** Replaced
  with `policies.json`.
- ~~**Maltego removed.**~~ Required a paid account and an unreliable download URL. Not
  installed automatically; install manually from https://www.maltego.com/downloads/linux.
- ~~**Google Earth Pro repo broken on Noble.**~~ **Resolved.** Direct `.deb` download used.
- ~~**Wayland compatibility for zenity.**~~ **Resolved.** All launchers export
  `GDK_BACKEND=x11` under Wayland.

---

## Files That Should NOT Be Committed to Git

The `.gitignore` excludes:
- `.claude/`: Claude Code session data
- `.mcp.json`: MCP server configuration
- `CLAUDE.md`: Claude project instructions
- `start.ps1`: AI daemon launcher (Windows)
- `.idea/`: JetBrains IDE config
- `argos_install_*.log`: installation logs
- `node_modules/`: (guard for any tooling that creates it)

---

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| Use `pipx` for CLI Python tools | PEP 668: Ubuntu 24.04 / Python 3.12 blocks system-wide `pip install` |
| Use `venv` per project for tools with `requirements.txt` | Isolation, reproducibility, no global Python env pollution |
| Use `xdg-open` instead of `nautilus` or `firefox` | Works on all desktop environments including Budgie (uses Nemo) |
| Use `__HOME__` placeholder in `.desktop` files and `policies.json` | `setup.sh` substitutes the real `$HOME` at install time via `sed` |
| Use explicit `$HOME/.local/bin/<tool>` for pipx in `Terminal=false` launchers | `~/.bashrc` is not sourced for non-terminal desktop launches |
| `/etc/apt/keyrings/` instead of `apt-key add` | `apt-key` deprecated since Ubuntu 22.04 |
| Firefox `policies.json` instead of a zip profile template | Smaller, no auto-launch, works on snap and deb, no stale 2022 profile data |
| PhoneInfoga / SpiderFoot launched as local web UIs (`serve` + `xdg-open`) | Both expose a browser UI; consistent launcher pattern |
| Guard network-dependent steps with `\|\| log_warn` under `set -euo pipefail` + `ERR` trap | A single failed download must not abort the whole install |

---

## How to Continue This Work

1. **Test v2.1.0-beta on a clean VM.** This is the most important next step. Provision
   Ubuntu Budgie 24.04 LTS in VirtualBox, clone the repo to `~/Downloads/Argos`, run
   `setup.sh`, and verify each tool launches correctly — especially the new launchers and
   the Firefox `policies.json` (see Known Issues #1).

2. **Check the log file.** `setup.sh` writes a full log to `~/Downloads/argos_install_*.log`.
   Review it for failed steps or warnings after a test run.

3. **Confirm the `user-scanner` CLI contract** (binary name and flags) against a real
   install before trusting the `usernames.sh` wrapper.

4. **Remove the BETA label** only after a successful end-to-end test on both Ubuntu 24.04
   and Ubuntu Budgie 24.04.
