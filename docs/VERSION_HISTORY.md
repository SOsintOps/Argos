# Argos — Version History

This page summarises each release at a high level.
For the full technical changelog see [CHANGELOG.md](CHANGELOG.md).

---

## v2.0.4-beta — 2026-04-04

Patch release focused on installation correctness and user experience.

### Highlights

**VirtualBox Guest Additions removed from installer.**
`virtualbox-guest-utils` and `virtualbox-guest-x11` have been removed from the apt install list. The dpkg config file prompt on `virtualbox-guest-x11` blocked non-interactive installation. Guest Additions must now be installed manually before running `setup.sh`. The README Requirements section documents this as a prerequisite.

**Tony Stark easter egg quips.**
A `log_quip()` function adds 10 contextual one-liners to the installation log, styled as Tony Stark commentary. They appear at key milestones: startup, OS update, dependency install, Python tools, Firefox, Obsidian, theHarvester, Google Earth, and completion.

**Closing motto updated.**
The final banner motto has been changed from *Si vis pacem, para bellum* to *Audi, vide, tace* — a more fitting motto for an OSINT workstation.

---

## v2.0.3-beta — 2026-04-04

Patch release focused on installation resilience. No new tools added.

### Highlights

**Resilient apt installation.**
The 31-package apt install block has been replaced with a per-package wrapper function. If any individual package is unavailable or fails, the script logs a warning, records the package name, and continues. A summary of all failed packages is printed at the end of the run, before the reboot prompt.

**pip install fallbacks.**
The four venv-based tools (theHarvester, metagoofil, recon-ng, blackbird) now each have a `|| log_warn` fallback on their `pip install` call. A broken `requirements.txt` or upstream dependency conflict no longer kills the rest of the installation.

**Obsidian snap fallback added.**
The `snap install --dangerous` call for Obsidian previously had no error handling. It now logs a warning and continues if snap fails, consistent with the amass and cherrytree installs.

**Known failure points documented.**
A comment block near the top of `setup.sh` lists six categories of expected failure with explanations: VirtualBox packages on non-VirtualBox hosts, snapd in restricted environments, `torbrowser-launcher` repository issues, network-dependent steps, Firefox auto-launch in headless sessions, and EyeWitness bundled pip dependencies.

---

## v2.0.2-beta — 2026-04-04

Patch release fixing two package issues and translating all script messages to English.

### Highlights

**`openshot` corrected to `openshot-qt`.**
The `openshot` package does not exist on Ubuntu 24.04 Noble. The apt install block would abort immediately when this package was not found. The correct package name is `openshot-qt`.

**`zip` added to dependencies.**
The Firefox customisation step uses `zip -F` to repair the profile archive, but `zip` was not listed as a dependency. On minimal Ubuntu installs where `zip` is not pre-installed this would cause a silent failure.

**All script messages translated to English.**
User-facing messages, log output and inline comments were a mix of Italian and English. All text is now in English for consistency.

---

## v2.0.1-beta — 2026-04-01

Patch release focused on robustness, portability, and Wayland compatibility.
No new tools added.

### Highlights

**Any Linux username now works.**
The previous requirement to set the Linux username to `osint` has been removed.
`setup.sh` now replaces the hardcoded `/home/osint/` paths in the `.desktop` shortcut files with the real home directory at install time. Nothing else changes.

**Wayland sessions are now supported.**
All 10 zenity-based tool launchers detect a Wayland session automatically and switch to the X11 backend via XWayland. No user configuration is required. The fix is a no-op on X11 sessions.

**Firefox profile setup is now fully automatic.**
On a clean VM where Firefox has never been opened, `setup.sh` would silently skip the profile customisation step. The script now launches and closes Firefox automatically to create the default profile before applying the Argos template.

**Installation log moved to `~/Downloads/`.**
The log file is now written to `~/Downloads/argos_install_YYYYMMDD_HHMMSS.log` instead of the home directory root.

### Bug fixes

| File | Issue | Fix |
|------|-------|-----|
| `domains.sh` | theHarvester progress bar was blank (stderr not piped to zenity) | Added `2>&1` before pipe |
| `usernames.sh` | `sherlock` and `maigret` relied on PATH from `.bashrc` | Changed to explicit `$HOME/.local/bin/` paths |
| `youtubedl.sh` | `yt-dlp` not found in `Terminal=false` launch context | Changed to `/usr/bin/yt-dlp` |
| `spiderfoot.sh` | `pgrep` not found in `Terminal=false` launch context | Changed to `/usr/bin/pgrep` |
| `ffmpeg_interact.sh` | `ffmpeg`/`ffplay` not found in `Terminal=false` launch context | Changed to explicit `/usr/bin/` paths via variables |
| All scripts | zenity dialogs invisible on Wayland | Added `GDK_BACKEND=x11` guard |

---

## v2.0.0-beta — 2026-03-31

Major rewrite targeting Ubuntu 24.04 LTS (Noble Numbat) and Ubuntu Budgie 24.04 LTS.

> **Breaking change**: Ubuntu 22.04 LTS and 20.04 LTS are no longer supported.

### Highlights

**Python tool isolation (PEP 668 compliance).**
Ubuntu 24.04 uses Python 3.12, which blocks system-wide `pip install`. All Python CLI tools now install via `pipx` (isolated environments in `~/.local/share/pipx/`). Tools with complex dependencies (theHarvester, metagoofil, recon-ng, blackbird) use per-project `venv` directories under `~/Downloads/Programs/`.

**Abandoned tools removed.**
The following tools were removed because they are no longer maintained:

| Removed | Replacement |
|---------|-------------|
| youtube-dl | yt-dlp |
| Instalooter | Instaloader |
| Sublist3r | Amass |
| Photon | — (Katana/GoSpider planned) |
| Moriarty-Project | — (PhoneInfoga planned) |
| Elasticsearch-Crawler | Shodan CLI |
| Atom Editor | VSCodium |

**New tools added.**
yt-dlp, holehe, maigret, blackbird, VSCodium, Obsidian (version fetched dynamically from GitHub API).

**`setup.sh` completely rewritten.**
- `set -euo pipefail` + `trap ERR`: script halts on any error and prints the line number
- Structured logging with `log_ok`, `log_warn`, `log_error`, `log_step`
- Root user check
- Full output captured to a log file via `tee`
- Dynamic Firefox profile detection (supports both snap and .deb installs)
- `/etc/apt/keyrings/` method for GPG keys (replaces deprecated `apt-key add`)

**All hardcoded `/home/osint/` paths removed from scripts.**
All files in `scripts/` now use `$HOME`.

---

## v1.x — 2022

- Added Toutatis to `instagram.sh`
- Renamed `sherlock.sh` to `usernames.sh`
- Icon paths moved from `/documents/` to `/Pictures/`
- Renamed `sherlock.desktop` to `usernames.desktop`
