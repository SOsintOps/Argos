# Changelog

All notable changes to Argos are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [2.0.1-beta] — 2026-04-01

Patch release focused on robustness, portability, and Wayland compatibility.
No new tools added. All changes are backwards-compatible.

### Fixed

#### setup.sh
- Firefox profile customisation failed silently on a clean VM where Firefox had never been opened. `setup.sh` now launches Firefox automatically, waits 15 seconds for the default profile to be written, then closes it before applying the Argos template.
- `.desktop` shortcut files contained hardcoded `/home/osint/` paths. `setup.sh` now replaces them with the real `$HOME` at install time using `sed`. Any Linux username now works.

#### scripts/domains.sh
- theHarvester writes progress to stderr. The output was silently dropped before reaching the zenity progress bar. Added `2>&1` before the pipe.

#### scripts/usernames.sh
- `sherlock` and `maigret` were called without explicit paths. Changed to `$HOME/.local/bin/sherlock` and `$HOME/.local/bin/maigret` to ensure they are found in all launch contexts, including `Terminal=true` sessions where `.bashrc` may not be fully loaded.

#### scripts/youtubedl.sh
- `yt-dlp` was called without an explicit path in a `Terminal=false` launcher. Changed to `/usr/bin/yt-dlp`.

#### scripts/spiderfoot.sh
- `pgrep` was called without an explicit path in a `Terminal=false` launcher. Changed to `/usr/bin/pgrep`.

#### scripts/ffmpeg_interact.sh
- `ffmpeg` and `ffplay` were called without explicit paths in a `Terminal=false` launcher. Both now use `$FFMPEG_BIN` and `$FFPLAY_BIN` variables pointing to `/usr/bin/`.

#### All scripts in scripts/
- zenity dialogs would not appear on Wayland sessions. All 10 launcher scripts now export `GDK_BACKEND=x11` when `XDG_SESSION_TYPE=wayland`, routing zenity through XWayland transparently. No user action required.

### Changed

#### setup.sh
- Installation log moved from `$HOME/argos_install_*.log` to `$HOME/Downloads/argos_install_*.log` to keep the home directory clean.

---

## [2.0.0-beta] — 2026-03-31

> **BREAKING CHANGE**: Ubuntu 22.04 LTS is no longer supported.
> This release targets Ubuntu 24.04 LTS (Noble Numbat) and Ubuntu Budgie 24.04 LTS.

### setup.sh: Complete Rewrite

#### Added
- `set -euo pipefail` + `trap ERR`: script halts on any error and reports the exact line number
- Installation log file: `~/argos_install_YYYYMMDD_HHMMSS.log` (full output captured via `tee`)
- Helper functions: `log_ok`, `log_warn`, `log_error`, `log_step` for structured output
- Root user check: prevents accidental execution as root
- `sudo add-apt-repository multiverse` before install (required for `unrar`)
- `virtualbox-guest-utils`, `virtualbox-guest-x11`: VirtualBox clipboard and fullscreen support on desktop environments (Budgie)
- `python3-venv`, `pipx`: Python isolation tooling for PEP 668 compliance
- Dynamic Obsidian version via GitHub API (no longer hardcoded)
- Dynamic Firefox profile detection (supports both snap and .deb installs)
- VSCodium repository and installation (replaces Atom)
- `/etc/apt/keyrings/` method for GPG keys (Google Earth, VSCodium)
- `proxychains4` + `tor` as safer replacement for kali-anonsurf
- `yt-dlp` via apt (replaces youtube-dl)
- `httrack` (correct package name, replaces `webhttrack`)
- `openjdk-21-jre` (replaces openjdk-11-jre)

#### Changed
- All `sudo pip3 install` → `pipx install` (PEP 668 / Python 3.12 compliance)
- Tools with `requirements.txt` use dedicated `.venv` per project (theHarvester, metagoofil, recon-ng, blackbird)
- `python-setuptools` → `python3-setuptools` (Python 2 removed from Ubuntu 24.04)
- `apt-key add` (deprecated) → `/etc/apt/keyrings/` for Google Earth and VSCodium
- `p7zip` → `7zip p7zip-full` (package renamed in Ubuntu 24.04)
- Ripgrep: removed manual `.deb` download (v11.0.2) → uses `apt install ripgrep` (v14.x)
- Obsidian: hardcoded v0.14.6 → dynamically fetched latest release
- Maltego: hardcoded S3 URL → resolved via official download page
- `openjdk-11-jre` → `openjdk-21-jre`
- Firefox profile path: now detected dynamically at runtime (snap or deb)
- `cd argosfox/ || warn` → proper `if/else` block (critical logic bug fix)
- Removed all dead `sed` patches on already-updated scripts

#### Removed
- `youtube-dl` (abandoned 2021) → replaced by `yt-dlp`
- `Instalooter` (abandoned 2020) → removed
- `Sublist3r` (abandoned 2019) → removed (Amass covers same use case)
- `Photon` (abandoned 2020) → removed
- `kali-anonsurf` (incompatible with systemd-resolved on Ubuntu 24.04) → replaced by tor + proxychains4
- `Moriarty-Project` (abandoned) → removed
- `Elasticsearch-Crawler` (abandoned) → removed
- `Atom Editor` (discontinued December 2022) → replaced by VSCodium
- `sudo pip3 install --upgrade pip` (broke system pip on Ubuntu 24.04) → removed entirely
- `holehe` via `setup.py install` (removed in Python 3.12) → now via `pipx`
- Redundant `curl` duplicate install
- Dead `sed` blocks on already-updated scripts

---

### scripts/: All Scripts Updated

#### `youtubedl.sh`
- **Changed**: `youtube-dl` → `yt-dlp`
- **Changed**: `nautilus` → `xdg-open` (Budgie compatibility)
- **Changed**: hardcoded `/home/osint/` → `$HOME`

#### `instagram.sh`
- **Removed**: Instalooter option (tool abandoned)
- **Fixed**: `instaloader` output goes to stderr. Added `2>&1` before pipe to zenity so the progress bar works correctly.
- **Fixed**: explicit path `$HOME/.local/bin/instaloader` and `$HOME/.local/bin/toutatis`. Tools are now found when launched from a desktop shortcut with `Terminal=false`.
- **Added**: availability check for each tool before running
- **Changed**: `nautilus` → `xdg-open`, `/home/osint/` → `$HOME`, variables properly quoted

#### `usernames.sh`
- **Removed**: Moriarty-Project option (tool abandoned)
- **Added**: Blackbird option (via venv at `~/Downloads/Programs/blackbird/.venv`)
- **Changed**: Maigret. Was a WIP placeholder; now fully functional via pipx.
- **Changed**: Sherlock. Now called via the `sherlock` command (pipx); no longer run from a cloned repo.
- **Changed**: `nautilus` → `xdg-open`

#### `spiderfoot.sh`
- **Rewritten**: was a non-functional stub (git clone + pip install); now a proper launcher
- **Fixed**: explicit path `$HOME/.local/bin/spiderfoot`. Now found correctly with `Terminal=false`.
- **Fixed**: `pgrep -f "spiderfoot -l"` instead of `pgrep -f "spiderfoot"` (avoids false positive on script itself)
- **Changed**: opens browser via `xdg-open` instead of `firefox`

#### `domains.sh`
- **Removed**: Sublist3r option (tool abandoned since 2019)
- **Removed**: Photon option (tool abandoned since 2020)
- **Changed**: theHarvester. Now uses a dedicated venv at `~/Downloads/Programs/theHarvester/.venv`.
- **Changed**: Amass. Updated to v4 syntax (`amass enum` instead of `amass intel` + `amass enum`).
- **Changed**: `firefox` → `xdg-open`, `nautilus` → `xdg-open`, `/home/osint/` → `$HOME`

#### `elasticsearch.sh`
- **Rewritten**: converted to deprecation notice (tool abandoned, Elasticsearch 8.x requires auth by default)
- **Added**: suggests Shodan CLI as alternative

#### `eyewitness.sh`
- **Fixed**: correct path to `EyeWitness/Python/EyeWitness.py`
- **Changed**: `/home/osint/` → `$HOME`, `mkdir -p` for output directory

#### `metagoofil.sh`
- **Fixed** (CRITICAL): `docs_dir=$(run_metagoofil "$domain")` was capturing metagoofil's entire stdout output along with the path, so `find "$docs_dir"` received a corrupted path. Fixed by using a global variable `$DOCS_DIR` instead of command substitution.
- **Fixed**: `exiftool "$docs_dir"/*` (unsafe glob) → `exiftool -r "$docs_dir"` (handles filenames with spaces)
- **Changed**: uses dedicated venv at `~/Downloads/Programs/metagoofil/.venv`
- **Changed**: `/home/osint/` → `$HOME`, `mkdir -p`

#### `recon-ng.sh`
- **Changed**: uses dedicated venv at `~/Downloads/Programs/recon-ng/.venv`

#### `ffmpeg_interact.sh`
- **Changed**: `nautilus` → `xdg-open` (Budgie: default file manager is Nemo, not Nautilus)
- **Changed**: `/home/osint/` → `$HOME`
- **Removed**: `-strict -2` flag (obsolete in modern ffmpeg)

---

### shortcuts/: Desktop Files Updated

| File | Change |
|------|--------|
| `youtube_dl.desktop` | Name updated to "Video Downloader", comment updated |
| `usernames.desktop` | Name updated from "Sherlock" to "Usernames OSINT" |
| `httrack.desktop` | `Exec=webhttrack` → `Exec=httrack` |
| `elasticsearch.desktop` | `Terminal=true` → `Terminal=false`, name updated |
| `spiderfoot.desktop` | `Terminal=true` → `Terminal=false`, comment added |
| `twitter.desktop` | Was pointing to non-existent `twitter.sh` → now `xdg-open https://x.com` |

---

### multimedia/wallpapers/background.sh

- **Changed**: hardcoded `/home/osint/Pictures/...` → `$HOME` via `WALLPAPER` variable
- **Added**: `picture-uri-dark` for GNOME Wayland dark mode
- **Fixed**: `mkdir -p` before writing to i3 config
- **Changed**: unknown desktop session now prints a message instead of silently failing

---

### New Files

| File | Description |
|------|-------------|
| `.gitignore` | Excludes AI/Claude files, IDE config, install logs |
| `docs/CHANGELOG.md` | This file |
| `docs/PROJECT_STATUS.md` | AI handoff document: current state and open tasks |

---

### Other

- `test/usernames-test.sh`: rewritten to test sherlock, maigret, and blackbird (new toolchain)
- `scripts/changes.txt`: updated with 2026 changes
- `README.md`: BETA label added, tool table updated with maintenance status, Ubuntu 24.04 requirements updated, abandoned tools removed, log section added

---

## [1.x] — 2022

- Added Toutatis to instagram.sh
- Renamed sherlock.sh to usernames.sh
- Icon paths moved from /documents/ to /Pictures/
- Renamed sherlock.desktop to usernames.desktop
