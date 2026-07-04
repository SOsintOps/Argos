# Argos — Version History

This page summarises each release at a high level.
For the full technical changelog see [CHANGELOG.md](CHANGELOG.md).

---

## v2.1.1-beta — 2026-07-04

Robustness release: setup.sh no longer aborts outside the happy path.

### Highlights

**Clear error when the repo is not where expected.**
If the repository has not been cloned to `~/Downloads/Argos`, the script now stops immediately with an explicit message instead of failing mid-install with a bare line number. The source path is centralised in one `ARGOS_SRC` variable.

**Survives minimal or non-standard systems.**
`~/Templates` is created if missing, empty source directories are skipped with a warning instead of killing the install, and `/etc/apt/keyrings` is created before deploying the VSCodium signing key (its absence silently skipped VSCodium on clean 24.04 systems).

**No more surprise reboots.**
The final reboot now requires an interactive terminal. In headless or piped runs the script prints a notice and lets the user reboot manually.

**Repo hygiene and GitHub housekeeping.**
ShellCheck now runs in CI on every push and PR; a SECURITY.md policy was added; `.idea/` and internal `changes.txt` notes were removed from tracking. On the GitHub side: Issues re-enabled (the README pointed to them but they were off), the placeholder GitHub Pages site and its `gh-pages` branch removed, and the pre-rewrite 2019-2022 history preserved under the `archive/pre-rewrite` tag.

---

## v2.1.0-beta — 2026-07-04

Exploratores added and wired into Firefox; GUI launchers for uncovered tools; Elasticsearch replaced with Shodan; script bug fixes.

### Highlights

**Exploratores installed locally.**
[Exploratores](https://github.com/SOsintOps/Exploratores) (from SOsintOps, the same project behind the Speculator policies) is a browser-based OSINT toolkit: curated search tools, a PII redactor, multi-country IBAN analysis, and an embedded CyberChef — all static HTML/CSS/JS, no backend, all processing client-side. `setup.sh` clones it to `~/Documents/Exploratores`.

**Firefox integration, three ways.**
- Firefox homepage set to the local `launchme.html` (changeable by the user — the policy is not locked).
- "Exploratores" bookmark in the managed "Local Tools" OSINT bookmark folder.
- New `exploratores.desktop` shortcut in the application menu that opens the toolkit in Firefox.

To support local `file://` URLs, `setup.sh` now deploys policies.json with `__HOME__` placeholder substitution, the same mechanism used for the `.desktop` files.

**Previously uncovered tools now reachable from the menu.**
`user-scanner`, `linkook`, and `socialscan` (installed since v2.0.6 but with no launcher) are now menu entries inside the Usernames tool. PhoneInfoga gets its own `phoneinfoga.desktop` shortcut, launching its web UI on `http://127.0.0.1:5000` like SpiderFoot.

**Elasticsearch-Crawler replaced with Shodan.**
The dead Elasticsearch-Crawler script (only a deprecation warning) has been removed. In its place, a Shodan CLI wrapper prompts for the API key on first use, then runs searches and shows the results.

**Reliability and consistency fixes.**
- `amass enum` no longer passes the removed `-src` flag (broke on Amass v4).
- Blackbird now opens the folder where it actually writes results.
- EyeWitness prefers its virtualenv and reports failures clearly.
- `setup.sh` no longer aborts the whole install if the Obsidian or VSCodium downloads fail.
- All launcher UI messages are now English-only.

---

## v2.0.7-beta — 2026-04-30

Firefox customisation rewritten from scratch.

### Highlights

**Zip-based profile template replaced by enterprise policies.json.**
The previous method used a ~50 MB zip archive (`argosfox/argos-ff-template.zip`) containing a full Firefox profile snapshot from 2022, including stale telemetry, old cookies databases, and deprecated extensions (HTTPS Everywhere). The script had to launch Firefox, wait 15 seconds for a profile directory to appear, then extract and overwrite it.

The new method deploys a single `config/policies.json` file (based on the [Speculator Project](https://github.com/SOsintOps/Speculator-Project)) to the Firefox distribution directory. It works on both snap (`/etc/firefox/policies/`) and deb (`/usr/lib/firefox/distribution/`) installs. No profile detection, no zip handling, no Firefox auto-launch.

**What the policies.json configures:**
- Privacy: telemetry, studies, Pocket, form history, password manager disabled. Tracking protection set to strict. WebRTC, geolocation, battery API, beacon, DNS prefetch disabled. Fingerprinting resistance enabled.
- Permissions: camera, microphone, location, notifications blocked. Autoplay blocked.
- Sanitise on shutdown: cache, cookies, history, sessions, form data cleared automatically.
- Extensions (12): uBlock Origin, CanvasBlocker, ClearURLs, Multi-Account Containers, EXIF Viewer, Wayback Machine, GPS Detect, Search by Image, Nimbus Screenshot, Resurrect Pages, Link Gopher, Mitaka.
- Managed bookmarks: OSINT folder tree with Person Investigation, Domain & Infrastructure, Image & Media, Geolocation, Archives, Social Media, Local Tools, and Resources subfolders.

---

## v2.0.6-beta — 2026-04-08

Toolset update replacing an abandoned tool and adding three new OSINT tools.

### Highlights

**holehe removed; user-scanner added.**
holehe (last commit September 2024) has many broken modules and produces frequent false positives. It has been replaced by `user-scanner`, a 2-in-1 email and username OSINT suite with 195+ scan vectors, actively maintained in 2025/2026.

**Three new tools added.**
- `linkook`: maps linked social accounts and associated emails from a single username across multiple platforms.
- `socialscan`: queries registration endpoints directly for accurate email and username availability checks on 11 platforms.
- `PhoneInfoga`: phone number intelligence gathering. Installed as a Go binary to `/usr/local/bin/`. The developer has declared the project stable but unmaintained; the binary remains fully functional.

---

## v2.0.5-beta — 2026-04-08

Patch release cleaning up the `.desktop` template files.

### Highlights

**`.desktop` files now use an explicit placeholder.**
All 12 shortcut files previously contained `/home/osint/` as a de facto placeholder. These paths have been replaced with `__HOME__`, making clear that these are templates, not live paths. The `sed` substitution in `setup.sh` has been updated to match. Behaviour at install time is unchanged.

---

## v2.0.4-beta — 2026-04-04

Patch release focused on installation correctness and user experience.

### Highlights

**VirtualBox Guest Additions removed from installer.**
`virtualbox-guest-utils` and `virtualbox-guest-x11` have been removed from the apt install list. The dpkg config file prompt on `virtualbox-guest-x11` blocked non-interactive installation. Guest Additions must now be installed manually before running `setup.sh`. The README Requirements section documents this as a prerequisite.

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
