# Argos — Project Status & AI Handoff Document

**Last updated:** 2026-04-01
**Current version:** 2.0.0-beta
**Target platform:** Ubuntu 24.04 LTS (Noble Numbat) + Ubuntu Budgie 24.04 LTS

---

## What This Project Is

Argos is a **bash-based OSINT workstation setup script** for Ubuntu. It:
1. Installs and configures OSINT tools on a fresh Ubuntu 24.04 VM
2. Provides a set of zenity-based GUI launcher scripts for each tool
3. Installs `.desktop` shortcuts to the application menu
4. Customizes Firefox, wallpaper, and desktop environment

The intended user sets their Linux username to `osint` before running the setup.
The scripts in `scripts/` are GUI wrappers (zenity dialogs) for OSINT tools.
The files in `shortcuts/` are `.desktop` entries that call those wrappers.

---

## Repository Structure

```
Argos/
├── setup.sh                        # Main install script — run once on a fresh VM
├── scripts/                        # GUI launcher scripts (zenity)
│   ├── youtubedl.sh                # yt-dlp video downloader
│   ├── instagram.sh                # Instaloader + Toutatis
│   ├── usernames.sh                # Sherlock + Maigret + Blackbird
│   ├── spiderfoot.sh               # SpiderFoot launcher (pipx)
│   ├── domains.sh                  # Amass + theHarvester
│   ├── elasticsearch.sh            # Deprecation notice only
│   ├── eyewitness.sh               # EyeWitness screenshot tool
│   ├── metagoofil.sh               # Metagoofil + optional ExifTool
│   ├── recon-ng.sh                 # recon-ng framework launcher
│   └── ffmpeg_interact.sh          # ffmpeg video utilities
├── shortcuts/                      # .desktop files → copied to /usr/share/applications/
├── multimedia/
│   ├── icons/                      # Icons for .desktop shortcuts
│   ├── wallpapers/
│   │   └── background.sh           # Sets wallpaper per desktop session type
│   └── images/
├── argosfox/                       # Firefox profile template (zip)
├── templates/                      # OSINT report templates (docx, ctb, txt)
├── test/
│   └── usernames-test.sh           # Checks username tools are installed
└── docs/
    ├── CHANGELOG.md
    └── PROJECT_STATUS.md           # This file
```

---

## Current Tool Installation Architecture

Python tools are split into two categories to comply with PEP 668 (Python 3.12, Ubuntu 24.04):

### Installed via `pipx` (CLI tools, isolated envs in `~/.local/share/pipx/`)
| Tool | Command |
|------|---------|
| Instaloader | `~/.local/bin/instaloader` |
| Toutatis | `~/.local/bin/toutatis` |
| Maigret | `~/.local/bin/maigret` |
| Holehe | `~/.local/bin/holehe` |
| Sherlock | `~/.local/bin/sherlock` |
| SpiderFoot | `~/.local/bin/spiderfoot` |

> **Important**: scripts launched with `Terminal=false` in their `.desktop` file
> must use the **full path** `$HOME/.local/bin/<tool>`, as `~/.bashrc` is NOT sourced
> for non-terminal desktop launches. Currently fixed in `spiderfoot.sh` and `instagram.sh`.

### Installed via `python3 -m venv` (tools with complex dependencies)
| Tool | venv path |
|------|-----------|
| theHarvester | `~/Downloads/Programs/theHarvester/.venv` |
| metagoofil | `~/Downloads/Programs/metagoofil/.venv` |
| recon-ng | `~/Downloads/Programs/recon-ng/.venv` |
| blackbird | `~/Downloads/Programs/blackbird/.venv` |

### Installed via `apt` (system packages)
`yt-dlp`, `amass` (snap), `ripgrep`, `ffmpeg`, `exiftool`, `httrack`, `tor`, `proxychains4`, etc.

---

## Known Limitations & Open Issues

### High Priority: Must Fix Before Stable Release

1. **Not tested on a real VM yet.**
   The entire codebase was reviewed and rewritten statically. A full end-to-end test
   on a fresh Ubuntu 24.04 LTS and Ubuntu Budgie 24.04 LTS VM is required before
   removing the beta label.

2. **Firefox profile customization may fail silently.**
   `setup.sh` attempts to apply the Argos Firefox profile template. This requires Firefox
   to have been opened at least once to create a default profile. On a clean VM,
   Firefox may never have been opened before running setup. Consider adding a step that
   launches and immediately closes Firefox to trigger profile creation.

3. **Maltego removed.**
   Maltego required a paid account and the automated download URL was unreliable.
   Removed from `setup.sh`. Install manually from https://www.maltego.com/downloads/linux if needed.

4. **Google Earth Pro repo removed; direct .deb used instead.**
   The `http://dl.google.com/linux/earth/deb/` APT repo has no Noble (24.04) index entry
   and causes `apt update` errors. `setup.sh` now downloads the `.deb` directly from
   `https://dl.google.com/linux/direct/google-earth-pro-stable_current_amd64.deb` and
   removes the broken `.list` file added by the post-install script.

### Medium Priority: Should Fix

5. **No desktop shortcuts for holehe, maigret standalone, blackbird standalone.**
   These tools are only accessible via `usernames.sh` (maigret, blackbird) or have
   no UI wrapper at all (holehe). Consider adding shortcuts or integrating into
   existing menus.

6. ~~**`usernames.sh` does not use explicit path for `sherlock` and `maigret`.**~~
   **Fixed 2026-04-01.** Both tools now use `$HOME/.local/bin/sherlock` and
   `$HOME/.local/bin/maigret` explicitly in `usernames.sh`.

7. ~~**`domains.sh` menu shows theHarvester progress via zenity pipe,
   but theHarvester writes progress to stderr.**~~
   **Fixed 2026-04-01.** Added `2>&1` before the zenity pipe in `domains.sh` line 57.

8. **`cherrytree` snap package name may differ.**
   `sudo snap install cherrytree`. Verify this is the correct snap name on Ubuntu 24.04.
   The alternative PPA fallback exists but the PPA may not have a Noble (24.04) build.

9. **Wayland compatibility for zenity.**
   On Ubuntu 24.04 with Wayland sessions, zenity dialogs may require
   `--display=:0` or `DISPLAY=:0` prefix. Not currently handled.

### Low Priority: Nice to Have

10. **Replace Elasticsearch-Crawler with a functional alternative.**
    The script currently only shows a deprecation warning. Adding Shodan CLI
    (`pip install shodan`) with a basic UI wrapper would preserve the functionality.

11. **Add PhoneInfoga as replacement for Moriarty-Project.**
    PhoneInfoga (`sundowndev/phoneinfoga`) is actively maintained, available as
    a Go binary, and covers phone OSINT. No new `.desktop` shortcut exists for it.

12. **Add Katana or GoSpider as replacement for Photon.**
    Both are Go-based, actively maintained web crawlers.
    Installation would be via Go binary download, not pip.

13. **Report templates in `templates/` are from 2020.**
    The `.docx` files (`FullReportTemplate2020.docx`, etc.) are 6 years old.
    Consider updating with current OSINT methodology best practices.

14. **CherryTree template (`.ctb`) may need updating.**
    `templates/CherryOsintTemplateMaster.ctb` was created for an older version
    of CherryTree. The current version uses `.ctb` (SQLite) format; verify compatibility.

15. **No automated test suite.**
    `test/usernames-test.sh` only checks if binaries exist. There are no functional
    tests that verify tool output, venv integrity, or `.desktop` file validity.
    Consider adding a `test/` suite that runs after setup to validate the installation.

16. **argosfox Firefox template may be outdated.**
    `argosfox/argos-ff-template.zip` contains Firefox extensions and settings from ~2022.
    Extensions that were recommended for OSINT may have been updated, deprecated,
    or removed from the Firefox Add-ons store.

---

## Files That Should NOT Be Committed to Git

The `.gitignore` already excludes:
- `.claude/`: Claude Code session data
- `.claude-flow/`: Claude Flow daemon config
- `.mcp.json`: MCP server configuration
- `CLAUDE.md`: Claude project instructions
- `start.ps1`: AI daemon launcher (Windows)
- `.idea/`: JetBrains IDE config
- `argos_install_*.log`: installation logs

---

## Architecture Decisions Made in v2.0.0-beta

| Decision | Rationale |
|----------|-----------|
| Use `pipx` for CLI Python tools | PEP 668: Ubuntu 24.04 / Python 3.12 blocks system-wide `pip install` |
| Use `venv` per project for tools with `requirements.txt` | Isolation, reproducibility, no global Python env pollution |
| Use `xdg-open` instead of `nautilus` or `firefox` | Works on all desktop environments including Budgie (uses Nemo) |
| Use `$HOME` instead of `/home/osint/` in scripts | Robustness; `.desktop` files source still contain `/home/osint/` but `setup.sh` substitutes the real `$HOME` at install time via `sed` |
| Use explicit `$HOME/.local/bin/<tool>` for pipx in `Terminal=false` launchers | `~/.bashrc` is not sourced for non-terminal desktop launches |
| `/etc/apt/keyrings/` instead of `apt-key add` | `apt-key` deprecated since Ubuntu 22.04 |
| Global variable `$DOCS_DIR` in `metagoofil.sh` instead of `echo` + `$()` | Command substitution `$()` captures ALL stdout, and metagoofil output was corrupting the path variable |

---

## How to Continue This Work

1. **Test on a clean VM.** This is the most important next step.
   Provision Ubuntu Budgie 24.04 LTS in VirtualBox, clone the repo to `~/Downloads/Argos`,
   run `setup.sh`, and verify each tool launches correctly.

2. **Check the log file.** `setup.sh` writes a full log to `~/Downloads/argos_install_*.log`.
   Review it for any failed steps or warnings after a test run.

3. **Fix issues found during testing.** Focus on the Maltego download,
   the Firefox first-run issue, and zenity Wayland compatibility.

4. **Implement medium-priority items.** Focus on the `domains.sh` stderr pipe fix
   and the explicit PATH for sherlock/maigret in `usernames.sh`.

5. **Remove the BETA label.** Only remove it after a successful end-to-end test on both
   Ubuntu 24.04 and Ubuntu Budgie 24.04.
