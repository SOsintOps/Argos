# Argos architecture

This document describes how Argos is organised from version 3.0 onwards: what
`setup.sh` installs, how the desktop launchers work, and where results are saved.

## Goals

- **One case, one folder.** Every result an investigator produces belongs to a
  case. Launchers never scatter files across `~/Documents`.
- **Evidence you can defend.** Each run records the exact command, the tool
  version, start and end time in UTC, the full console output and a SHA-256
  hash of every file produced.
- **No silent failures.** A launcher either produces results or tells the user
  what went wrong and how to fix it.
- **Explicit OPSEC choices.** Options that send the target to a third-party
  service (AI analysis, breach lookups, account-recovery checks) are off by
  default and require a confirmation that names the service.
- **Works with and without a desktop.** The same launchers run with zenity
  dialogs on the desktop and with plain prompts in a terminal or over SSH.

## Layout in the repository

```
setup.sh                 installer (run once on a clean Ubuntu 24.04 or 26.04 VM)
launchers/lib/argos.sh   shared library used by every launcher
launchers/*.sh           one launcher per task (usernames, domains, ...)
desktop/*.desktop        application menu entries (templates)
config/policies.json     Firefox enterprise policies
multimedia/              icons, wallpaper and the wallpaper helper
templates/               report templates
tests/                   automated tests (bats) and test doubles
```

## Layout on the installed system

| Path | Content |
|---|---|
| `~/.local/share/argos/launchers/` | launchers and `lib/argos.sh` |
| `~/.local/share/argos/icons/` | launcher icons |
| `~/.local/share/applications/argos-*.desktop` | menu entries |
| `~/.local/share/argos/tools/` | tools installed from source (Blackbird, EyeWitness, metagoofil, recon-ng, SpiderFoot), each with a uv environment on Python 3.12 |
| `~/.local/bin/` | command-line tools installed with uv (own environment each), Amass and PhoneInfoga |
| `~/.config/argos/argos.conf` | active case and user settings |
| `~/Documents/Argos/cases/<case>/` | all results |

Nothing is written to `/usr/share/applications`: menu entries are per user.

## Cases and runs

The active case is chosen with the **Argos Case** launcher and stored in
`argos.conf`. When no case has been chosen, results go to the case `unsorted`.

Each launcher execution creates a **run folder**:

```
~/Documents/Argos/cases/<case>/<tool>/<UTC timestamp>_<target>/
    command.txt     command line, tool version, start/end time (UTC), exit code
    output.log      full console output of the tool
    SHA256SUMS      hash of every other file in the folder
    ...             files produced by the tool
```

Target strings are reduced to a safe file name (letters, digits, `.`, `_`,
`-`, `@`); the original value is kept in `command.txt`.

## Shared library (`launchers/lib/argos.sh`)

| Area | Functions |
|---|---|
| Start-up | `argos_init` loads the configuration and picks the user interface |
| User interface | `ui_info`, `ui_warn`, `ui_error`, `ui_entry`, `ui_secret`, `ui_choice`, `ui_checklist`, `ui_file`, `ui_question`, `ui_text_file` |
| Validation | `is_username`, `is_email`, `is_domain`, `is_url`, `is_ipv4`, `is_phone`, `safe_name` |
| Cases | `case_name`, `case_root`, `new_run_dir` |
| Tools | `find_tool` (clear error with the fix when a tool is missing) |
| Execution | `run_logged` (progress window with a working Cancel button that stops the tool), `finish_run` (hashes and opens the folder) |
| OPSEC | `confirm_third_party` |

The interface is selected automatically: zenity when a graphical session and
zenity are available, terminal prompts otherwise. `ARGOS_UI=tty` forces the
terminal mode; the automated tests use it.

## Launchers

| Launcher | Tools | Inputs |
|---|---|---|
| Argos Case | — | create, select or open a case |
| Usernames & Emails | Sherlock, Maigret, Blackbird, User Scanner, Linkook, Socialscan | username or email, report formats, scope |
| Instagram | Instaloader, Toutatis | profile; optional session for Toutatis |
| Domains | Amass v5, theHarvester 5 | domain, passive or brute force, sources |
| Web Screenshots | EyeWitness | one URL, a URL list or an Nmap/Nessus XML |
| Documents & Metadata | metagoofil, ExifTool | domain, file types, metadata report |
| Video Download | yt-dlp | URL, video or audio, metadata and comments |
| Video Tools | ffmpeg, ffprobe, ExifTool | video file, operation |
| Shodan | Shodan CLI | API key once; search, host, domain, count, download |
| SpiderFoot | SpiderFoot web UI | — |
| PhoneInfoga | PhoneInfoga | web UI or a single number scan |
| recon-ng | recon-ng | workspace named after the case |
| Website Mirror | HTTrack | URL, depth |
| Exploratores | Exploratores (local) | — |

## Testing

- `shellcheck` on every shell file (also in CI).
- `bats` tests in `tests/` run the launchers in terminal mode against test
  doubles of each tool, so they check argument building, folder layout, hashes
  and error handling without network access.
- An end-to-end install on clean Ubuntu 24.04 and 26.04 systems before every release.
