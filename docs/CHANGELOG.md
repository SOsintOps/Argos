# Changelog

All notable changes to Argos are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [2.1.1-beta] — 2026-07-04

Robustness fixes for setup.sh: the script no longer aborts (or misbehaves)
outside the happy path — missing repo directory, missing standard folders,
empty source directories, non-interactive execution. Repo hygiene: ShellCheck
CI, `.idea/` untracked, internal notes removed.

### Added

#### .github/workflows/shellcheck.yml
- New CI workflow: ShellCheck (severity warning and above) runs on `setup.sh`, all launcher scripts, `background.sh` and the test script on every push to `master` and on pull requests.

#### docs/SECURITY.md
- New security policy: how to report vulnerabilities, supported versions, and scope notes (third-party tools are reported upstream).

### Changed

#### README.md
- OSINT and General Tools tables sorted alphabetically.
- Status badges added under the title: ShellCheck CI, CC BY-NC-SA 4.0 licence, Ubuntu 24.04 LTS platform.
- New mascot displayed at 2.5x size with natural aspect ratio; float cleared before the Contents heading so section dividers no longer cross it.

#### multimedia/images/
- The Argos mascot (`scribblenauts-argos.png`) replaced with a new illustration inspired by the original "Scribblenauts Argos" icon by Miguel Ángel Aranda. Attribution updated in `License.md` and `multimedia/images/license.txt`.

### Fixed

#### setup.sh
- Startup guard: the script now verifies that the repository exists at `~/Downloads/Argos` and exits with a clear error message if not, instead of dying mid-run with a cryptic line-number error. The path is stored in a single `ARGOS_SRC` variable used throughout (support files, Firefox policies.json).
- `~/Templates` is now created with `mkdir -p` before copying templates. On systems where `xdg-user-dirs` has not populated the standard folders, the copy previously aborted the whole install.
- All support-file copies (scripts, icons, `.desktop` shortcuts, templates, wallpapers) are now guarded with `compgen -G`: an empty source directory logs a warning and skips the step instead of aborting under `set -e`. The wallpaper step also checks that `background.sh` exists before running it.
- `/etc/apt/keyrings` is now created before writing the VSCodium signing key. On a clean Ubuntu 24.04 the directory is not guaranteed to exist, and its absence caused VSCodium to be silently skipped.
- The final reboot prompt now runs only in an interactive session (`[ -t 0 ]`). Without a TTY, `read` returned immediately and the machine rebooted with no confirmation; the script now prints a notice and leaves the reboot to the user.

#### scripts/recon-ng.sh
- The launcher now uses its `RECONNG` variable instead of a literal relative path (the variable was defined but never used — flagged by ShellCheck SC2034).

### Removed

#### Repository hygiene
- `.idea/` (JetBrains IDE files, including `workspace.xml`) removed from git tracking; it was already gitignored but still committed.
- `scripts/changes.txt` and `shortcuts/changes.txt` removed: internal work notes superseded by this changelog.

### Repository administration (GitHub side)

- Issues re-enabled on the repository: they had been turned off, contradicting the README's "open an issue" instruction.
- GitHub Pages unpublished and the `gh-pages` branch deleted: the site had been serving the untouched 2020 "Welcome to GitHub Pages" placeholder (created when the repo was still named OsintUbU) — a forgotten, unmonitored surface.
- New annotated tag `archive/pre-rewrite` on the tip of the old `patch-1` branch (commit `06f08f6`, 2022-09-15): preserves the original 2019-2022 history line (Ryan Foote's OSINT_VM_Setup onward, with all contributor attributions), which has no merge base with the rewritten `master`. The `patch-1` branch can now be deleted without losing that history.

---

## [2.1.0-beta] — 2026-07-04

Exploratores added and integrated with Firefox; GUI launchers for previously
uncovered tools; Elasticsearch replaced with Shodan; script bug fixes and
English-only UI messages.

### Added

#### setup.sh
- New "Exploratores" section: clones [SOsintOps/Exploratores](https://github.com/SOsintOps/Exploratores) to `~/Documents/Exploratores` via `clone_or_update`. Exploratores is a static HTML/CSS/JS OSINT toolkit (curated search tools, PII redactor, multi-country IBAN analysis, embedded CyberChef) with no backend; the entry point is `launchme.html`, opened directly in Firefox.
- `shodan` added to the pipx tool list.

#### config/policies.json
- `Homepage` policy: Firefox now opens Exploratores (`file://__HOME__/Documents/Exploratores/launchme.html`) as its homepage. Not locked, so the user can change it from Firefox settings.
- New "Exploratores" bookmark added to the managed "Local Tools" bookmark folder, pointing to the local `launchme.html`.

#### scripts/ and shortcuts/
- `exploratores.desktop`: application menu shortcut that launches Exploratores in Firefox. Uses the system Firefox icon.
- `usernames.sh`: three previously uncovered pipx tools added to the menu — **User Scanner** (`user-scanner -u/-e`), **Linkook** (`linkook`), and **Socialscan** (`socialscan`). They were installed since v2.0.6 but had no launcher.
- `phoneinfoga.sh` + `phoneinfoga.desktop`: new launcher for PhoneInfoga (installed since v2.0.6 but previously unreachable). Starts the PhoneInfoga web UI (`phoneinfoga serve`) on `http://127.0.0.1:5000` and opens the browser — same pattern as SpiderFoot. Uses the freedesktop `phone` icon.
- `shodan.sh` + `shodan.desktop`: zenity wrapper for the Shodan CLI (prompts for the API key on first use via `shodan init`, then runs `shodan search`). Replaces the deprecated Elasticsearch-Crawler. Uses the freedesktop `network-server` icon.

### Changed

#### setup.sh
- policies.json deployment now substitutes the `__HOME__` placeholder with the real `$HOME` at deploy time (`sed` piped to `sudo tee`, replacing the previous `sudo cp`). Required because policies.json now contains local `file://` URLs. This is the same mechanism already used for the `.desktop` shortcut files.
- Obsidian download, Obsidian version lookup, and the VSCodium key/repo setup are now wrapped so a network failure logs a warning and continues instead of aborting the whole install under `set -euo pipefail` + the `ERR` trap.

#### scripts/
- All zenity/UI messages translated to English (previously mixed Italian/English across `usernames.sh`, `instagram.sh`, `metagoofil.sh`, `eyewitness.sh`, `ffmpeg_interact.sh`, `youtubedl.sh`).

### Fixed

#### scripts/domains.sh
- Removed the `-src` flag from `amass enum`. The flag was removed in Amass v4 (the version installed via snap) and caused the command to error.

#### scripts/usernames.sh
- Blackbird: the script now opens the folder where Blackbird actually writes its reports (`~/Downloads/Programs/blackbird/results/`) instead of an empty `~/Documents/blackbird/`.

#### scripts/eyewitness.sh
- Uses the EyeWitness virtualenv Python if present, falling back to the system `python3`, and shows a clear error dialog on failure instead of crashing silently (Ubuntu 24.04 / PEP 668 dependency issues).

### Removed

#### scripts/ and shortcuts/
- Elasticsearch-Crawler removed (`elasticsearch.sh`, `elasticsearch.desktop`, `elasticsearch.png`). The tool was unmaintained and the script only showed a deprecation warning; replaced by Shodan (see Added).

---

## [2.0.7-beta] — 2026-04-30

Firefox customisation replaced: zip-based profile template removed, enterprise policies.json adopted.

### Added

#### config/policies.json
- Enterprise policies file for Firefox, based on the [Speculator Project](https://github.com/SOsintOps/Speculator-Project) configuration. Covers privacy hardening (telemetry, tracking, fingerprinting, WebRTC, geolocation disabled), permission lockdown (camera, microphone, location, notifications blocked), sanitise-on-shutdown (cache, cookies, history, sessions cleared), 12 OSINT extensions auto-installed (uBlock Origin, CanvasBlocker, ClearURLs, Multi-Account Containers, EXIF Viewer, Wayback Machine, GPS Detect, Search by Image, Nimbus Screenshot, Resurrect Pages, Link Gopher, Mitaka), and managed OSINT bookmark folders.

### Changed

#### setup.sh
- Firefox customisation block completely rewritten. The old approach launched Firefox to create a profile, extracted a ~50 MB zip archive (`argosfox/argos-ff-template.zip`) from 2022, and copied its contents into the profile directory. The new approach deploys a single `policies.json` file to the Firefox distribution directory. No profile detection, no zip handling, no Firefox auto-launch required.
- Snap Firefox: policies deployed to `/etc/firefox/policies/policies.json`.
- Deb Firefox: policies deployed to `/usr/lib/firefox/distribution/policies.json`.
- Known failure point #4 updated: "Firefox auto-launch" replaced with "Firefox policies.json" describing the new deployment paths.

### Removed

#### setup.sh
- `zip` dependency is no longer required by the Firefox customisation step. It remains in the apt list only if other steps still use it.
- Profile detection logic removed (`FIREFOX_SNAP_DIR`, `FIREFOX_DEB_DIR`, `FF_PROFILE`, `find *.default*`).
- Firefox auto-launch block removed (the `firefox &>/dev/null &`, 15-second wait, and `pkill` sequence).
- `argosfox/argos-ff-template.zip` reference removed from setup.sh. The `argosfox/` directory is no longer used at install time.

---

## [2.0.6-beta] — 2026-04-08

Toolset update: holehe replaced, three new OSINT tools added.

### Added

#### setup.sh
- `user-scanner` (pipx): 2-in-1 email and username OSINT suite, 195+ scan vectors. Replaces holehe.
- `linkook` (pipx): discovers linked social accounts and associated emails from a single username.
- `socialscan` (pipx): accurate email and username availability checks via direct registration endpoint queries.
- `PhoneInfoga` (binary): phone number intelligence gathering framework. Installed via the official upstream script to `/usr/local/bin/phoneinfoga`. Note: declared stable but unmaintained by the developer; binary remains functional.

### Removed

#### setup.sh
- `holehe` (pipx): removed. Last commit September 2024; many modules broken, frequent false positives, superseded by `user-scanner`.

---

## [2.0.5-beta] — 2026-04-08

Patch release replacing hardcoded template paths in `.desktop` shortcut files.

### Changed

#### shortcuts/*.desktop
- All 12 `.desktop` files: `/home/osint/` replaced with `__HOME__` placeholder. Makes the template nature of these files explicit and removes any ambiguity about the `osint` username dependency.
- `youtube_dl.desktop`: CRLF line endings converted to LF.

#### setup.sh
- `sed` substitution in the `.desktop` copy loop updated from `s|/home/osint/|$HOME/|g` to `s|__HOME__|$HOME|g` to match the new placeholder.

---

## [2.0.4-beta] — 2026-04-04

Patch release focused on installation correctness and user experience.

### Added

#### README.md
- VirtualBox Guest Additions listed as an explicit prerequisite. The script no longer installs them; they must be present before running `setup.sh`.

### Fixed

#### setup.sh
- `virtualbox-guest-utils` and `virtualbox-guest-x11` removed from the apt install list. The dpkg interactive config file prompt on `virtualbox-guest-x11` blocked non-interactive installation.
- Package count in startup quip corrected from 31 to 29.
- Known failure points comment block reduced from 6 to 5 entries: the VirtualBox entry removed as those packages are no longer installed.

### Changed

#### setup.sh
- Closing motto changed from *Si vis pacem, para bellum* to *Audi, vide, tace* — more fitting for an OSINT workstation.

---

## [2.0.3-beta] — 2026-04-04

Patch release focused on installation resilience and failure transparency.

### Added

#### setup.sh
- `FAILED_PACKAGES` array: tracks every apt package that fails to install during the session.
- `install_apt()` function: wraps each apt package install individually. On failure, logs a `[WARN]` message and appends the package name to `FAILED_PACKAGES`. The script continues rather than aborting.
- Failed packages summary block: printed before the final reboot prompt. Lists every package that did not install, with the log file path for diagnosis.
- Known failure points comment block near the top of the script (after the banner). Documents six categories of expected failure: VirtualBox packages on bare-metal, snap/snapd in restricted environments, `torbrowser-launcher` repository issues, network-dependent steps, Firefox auto-launch in headless sessions, and EyeWitness bundled pip dependencies.

### Fixed

#### setup.sh
- `python3 -m venv` calls for all four venv-based tools (theHarvester, metagoofil, recon-ng, blackbird) are now wrapped in an if/else block. A failed venv creation logs a clear warning and skips the pip install step rather than producing a cryptic error.
- Replaced the `git clone || (cd && git pull)` pattern with a `clone_or_update()` helper function that handles three cases: clean clone, existing valid repo (pull), and corrupted/partial directory (remove and re-clone).
- `snap refresh` now runs with a 30-second timeout. In restricted VM environments where snapd cannot complete a systemd restart, the previous call would hang indefinitely. The script now continues after 30 seconds and logs a warning.
- All 31 apt packages now install individually via `install_apt()`. A single unavailable package no longer aborts the entire dependency block.
- `sudo snap install --dangerous "obsidian_..."` now has a `|| log_warn` fallback, consistent with the `amass` and `cherrytree` snap installs.
- `pip install` calls for theHarvester, metagoofil, recon-ng, and blackbird now each have a `|| log_warn` fallback. A dependency conflict in one tool's venv no longer aborts the remaining tool installations.
- `sudo rm` on the Obsidian snap file changed to `sudo rm -f` to avoid aborting if the file was not created (e.g. after a failed download).

---

## [2.0.2-beta] — 2026-04-04

Patch release focused on package compatibility and script internationalisation.

### Fixed

#### setup.sh
- `openshot` replaced with `openshot-qt` — the former package does not exist on Ubuntu 24.04 Noble. Installation would abort at the apt install block.
- `zip` added to the apt dependency list — it is used by the Firefox customisation step but was not explicitly installed, causing failure on minimal systems.

### Changed

#### setup.sh
- All user-facing messages, log output, echo statements and inline comments translated to English. Script was previously a mix of Italian and English.
- Header updated: `Compatibile con` → `Compatible with`, `Aggiornato` → `Updated`.

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
