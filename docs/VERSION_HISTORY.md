# Argos — Version History

This page summarises each release at a high level.
For the full technical changelog see [CHANGELOG.md](CHANGELOG.md).

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
