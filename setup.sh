#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Ramingo (SOsintOps)
#
# Argos installer: turns a clean Ubuntu or Ubuntu Budgie 24.04 / 26.04 LTS
# virtual machine into an OSINT workstation. See README.md and
# docs/ARCHITECTURE.md.
#
# Usage:
#   ./setup.sh                 install everything
#   ./setup.sh STEP [STEP...]  run only the named steps (./setup.sh --list)

set -uo pipefail

ARGOS_VERSION="3.0.0-beta"
SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
ARGOS_HOME="$HOME/.local/share/argos"
TOOLS="$ARGOS_HOME/tools"
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
WORK="$(mktemp -d)"
export PATH="$BIN:$PATH"

# ── Output ──────────────────────────────────────────────────────────────────

BLUE=$'\033[94m'; RED=$'\033[91m'; GREEN=$'\033[92m'; YELLOW=$'\033[93m'; RESET=$'\033[0m'
ok()   { printf '%s[ OK ]%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$*"; WARNINGS+=("$*"); }
fail() { printf '%s[FAIL]%s %s\n' "$RED" "$RESET" "$*"; }
head_line() { printf '\n%s━━ %s%s\n' "$BLUE" "$*" "$RESET"; }

WARNINGS=()
FAILED_STEPS=()
DONE_STEPS=()

banner() {
    printf '%s' "$BLUE"
    cat <<'EOF'
     _    ____   ____  ___  ____
    / \  |  _ \ / ___|/ _ \/ ___|
   / _ \ | |_) | |  _| | | \___ \
  / ___ \|  _ <| |_| | |_| |___) |
 /_/   \_\_| \_\\____|\___/|____/
EOF
    printf '%s  OSINT workstation installer %s — Osint Ops\n\n' "$RESET" "$ARGOS_VERSION"
}

# ── Helpers ─────────────────────────────────────────────────────────────────

apt_install() {
    local pkg failed=()
    for pkg in "$@"; do
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q "$pkg" >/dev/null; then
            ok "apt: $pkg"
        else
            failed+=("$pkg")
            warn "apt: $pkg could not be installed"
        fi
    done
    [ ${#failed[@]} -eq 0 ]
}

# git_sync URL DIR: clone, or update an existing clone.
git_sync() {
    if [ -d "$2/.git" ]; then
        git -C "$2" pull --ff-only -q
    else
        rm -rf "$2"
        git clone -q --depth 1 "$1" "$2"
    fi
}

# Python used by every tool environment. uv downloads it when the system has
# another version (Ubuntu 24.04 ships 3.12, Ubuntu 26.04 ships 3.14), so the
# tools run on the same, tested Python on both releases.
TOOLS_PYTHON=3.12

# venv_requirements DIR REQUIREMENTS_FILE [VENV_NAME]: environment for a tool
# installed from source, in DIR/.venv (or DIR/VENV_NAME).
venv_requirements() {
    local venv="$1/${3:-.venv}"
    rm -rf "$venv"
    uv venv -q --python "$TOOLS_PYTHON" "$venv" &&
        uv pip install -q --python "$venv/bin/python" -r "$1/$2"
}

# uv_tool PACKAGE [--with EXTRA]...: command-line tool in its own environment,
# linked into ~/.local/bin.
uv_tool() {
    uv tool install -q --force --python "$TOOLS_PYTHON" "$@"
}

# github_latest OWNER/REPO: tag of the latest release, read from the
# redirect of /releases/latest (no API call, no rate limit).
github_latest() {
    local url
    url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest") || return 1
    [ "${url##*/}" != latest ] && printf '%s\n' "${url##*/}"
}

# download_verified URL CHECKSUMS_URL FILE: download and check the SHA-256.
download_verified() {
    local url=$1 sums=$2 file=$3 expected actual
    curl -fsSL -o "$WORK/$file" "$url" || return 1
    expected=$(curl -fsSL "$sums" | awk -v f="$file" '$2 == f || $2 == "*" f {print $1}')
    actual=$(sha256sum "$WORK/$file" | cut -d' ' -f1)
    if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
        fail "checksum mismatch for $file"
        return 1
    fi
}

deb_arch() { dpkg --print-architecture; }

# ── Steps ───────────────────────────────────────────────────────────────────
# Each step is a function step_NAME. A failing step is reported at the end;
# it does not stop the other steps.

STEPS=(system packages python-tools theharvester source-tools eyewitness amass phoneinfoga
       obsidian google-earth vscodium resources firefox launchers templates wallpaper)

step_system() {
    sudo add-apt-repository -y universe >/dev/null &&
        sudo add-apt-repository -y multiverse >/dev/null &&
        sudo apt-get update -q &&
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q upgrade
}

step_packages() {
    apt_install \
        git curl wget jq zenity xdg-utils ca-certificates gnupg \
        python3 python3-venv python3-pip pipx \
        ffmpeg mediainfo-gui libimage-exiftool-perl httrack \
        openjdk-21-jre ripgrep 7zip unrar zip subversion \
        vlc openshot-qt audacity kazam keepassxc cherrytree \
        tor torbrowser-launcher proxychains4
}

# install_uv: uv manages the Python environments of all the tools.
install_uv() {
    command -v uv >/dev/null 2>&1 && return 0
    pipx install -q uv >/dev/null && pipx ensurepath >/dev/null 2>&1 && command -v uv >/dev/null
}

step_python_tools() {
    local rc=0 spec
    install_uv || { fail "uv could not be installed (needs pipx)"; return 1; }
    # One line per tool: package and extra packages it needs.
    #  - maigret[pdf]: PDF reports need the optional extra.
    #  - instaloader + browser_cookie3: needed by --load-cookies (Firefox session).
    #  - shodan + setuptools<81: the CLI still imports pkg_resources.
    while read -r -a spec; do
        if uv_tool "${spec[@]}"; then ok "${spec[0]}"; else warn "${spec[0]} could not be installed"; rc=1; fi
    done <<'EOF_TOOLS'
sherlock-project
maigret[pdf]
user-scanner
linkook
socialscan
instaloader --with browser_cookie3
toutatis
yt-dlp
shodan --with setuptools<81
EOF_TOOLS
    return "$rc"
}

step_theharvester() {
    install_uv || return 1
    # theHarvester 5 needs Python 3.14: uv provides it on Ubuntu 24.04 as well.
    uv tool install -q --force --python 3.14 "git+https://github.com/laramies/theHarvester" &&
        ok "theHarvester $(theHarvester -h 2>/dev/null | grep -o 'theHarvester [0-9.]*' | head -1)"
}

step_source_tools() {
    local rc=0 name url req
    install_uv || return 1
    mkdir -p "$TOOLS"
    # SpiderFoot is not published on PyPI: it is installed from its repository.
    while read -r name url req; do
        if git_sync "$url" "$TOOLS/$name" && venv_requirements "$TOOLS/$name" "$req"; then
            ok "$name"
        else
            warn "$name could not be installed"
            rc=1
        fi
    done <<'EOF_TOOLS'
blackbird https://github.com/p1ngul1n0/blackbird requirements.txt
metagoofil https://github.com/opsdisk/metagoofil requirements.txt
recon-ng https://github.com/lanmaster53/recon-ng REQUIREMENTS
spiderfoot https://github.com/smicallef/spiderfoot requirements.txt
EOF_TOOLS
    return "$rc"
}

step_eyewitness() {
    mkdir -p "$TOOLS"
    git_sync https://github.com/FortyNorthSecurity/EyeWitness "$TOOLS/EyeWitness" || return 1
    install_uv || return 1
    # The upstream installer (needs root) adds Chromium, its driver and the
    # system libraries. Its Python environment is then rebuilt with uv on the
    # tested Python, whatever the upstream step did with the system Python.
    sudo bash "$TOOLS/EyeWitness/setup/setup.sh" ||
        warn "EyeWitness: the upstream installer reported errors; continuing with the Python environment"
    sudo chown -R "$(id -u):$(id -g)" "$TOOLS/EyeWitness"
    venv_requirements "$TOOLS/EyeWitness" setup/requirements.txt eyewitness-venv &&
        "$TOOLS/EyeWitness/eyewitness-venv/bin/python" -c "import selenium" &&
        ok "EyeWitness"
}

step_amass() {
    local tag arch file
    tag=$(github_latest owasp-amass/amass) || return 1
    case "$(deb_arch)" in arm64) arch=arm64 ;; *) arch=amd64 ;; esac
    file="amass_linux_${arch}.tar.gz"
    download_verified "https://github.com/owasp-amass/amass/releases/download/$tag/$file" \
        "https://github.com/owasp-amass/amass/releases/download/$tag/amass_checksums.txt" "$file" || return 1
    tar -xzf "$WORK/$file" -C "$WORK" &&
        install -D -m 755 "$WORK/amass_linux_${arch}/amass" "$BIN/amass" &&
        ok "Amass $tag"
}

step_phoneinfoga() {
    local tag arch file
    tag=$(github_latest sundowndev/phoneinfoga) || return 1
    case "$(deb_arch)" in arm64) arch=arm64 ;; *) arch=x86_64 ;; esac
    file="phoneinfoga_Linux_${arch}.tar.gz"
    download_verified "https://github.com/sundowndev/phoneinfoga/releases/download/$tag/$file" \
        "https://github.com/sundowndev/phoneinfoga/releases/download/$tag/phoneinfoga_checksums.txt" "$file" || return 1
    tar -xzf "$WORK/$file" -C "$WORK" phoneinfoga &&
        install -D -m 755 "$WORK/phoneinfoga" "$BIN/phoneinfoga" &&
        ok "PhoneInfoga $tag"
}

step_obsidian() {
    local tag version
    tag=$(github_latest obsidianmd/obsidian-releases) || return 1
    version=${tag#v}
    curl -fsSL -o "$WORK/obsidian.deb" \
        "https://github.com/obsidianmd/obsidian-releases/releases/download/$tag/obsidian_${version}_amd64.deb" &&
        sudo apt-get install -y -q "$WORK/obsidian.deb" >/dev/null &&
        ok "Obsidian $version" || return 1
    git_sync https://github.com/WebBreacher/obsidian-osint-templates "$HOME/Documents/obsidian-osint-templates"
}

step_google_earth() {
    curl -fsSL -o "$WORK/google-earth.deb" \
        https://dl.google.com/linux/direct/google-earth-pro-stable_current_amd64.deb &&
        sudo apt-get install -y -q "$WORK/google-earth.deb" >/dev/null || return 1
    # The package adds an APT source that has no release for Ubuntu 24.04.
    sudo rm -f /etc/apt/sources.list.d/google-earth-pro.list
    ok "Google Earth Pro"
}

step_vscodium() {
    sudo install -d -m 755 /etc/apt/keyrings &&
        curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg |
        gpg --dearmor | sudo tee /etc/apt/keyrings/vscodium.gpg >/dev/null &&
        echo "deb [signed-by=/etc/apt/keyrings/vscodium.gpg] https://download.vscodium.com/debs vscodium main" |
        sudo tee /etc/apt/sources.list.d/vscodium.list >/dev/null &&
        sudo apt-get update -q >/dev/null &&
        apt_install codium
}

step_resources() {
    local rc=0
    git_sync https://github.com/SOsintOps/Exploratores "$HOME/Documents/Exploratores" && ok "Exploratores" || rc=1
    mkdir -p "$HOME/Documents/Resources"
    git_sync https://github.com/pstirparo/threatintel-resources "$HOME/Documents/Resources/threatintel-resources" || rc=1
    git_sync https://github.com/mxm0z/awesome-intelligence-writing "$HOME/Documents/Resources/awesome-intelligence-writing" || rc=1
    return "$rc"
}

step_firefox() {
    local dir
    if snap list firefox >/dev/null 2>&1; then
        dir=/etc/firefox/policies
    elif [ -d /usr/lib/firefox ]; then
        dir=/usr/lib/firefox/distribution
    else
        warn "Firefox not found: policies not deployed"
        return 1
    fi
    sudo install -d -m 755 "$dir" &&
        sed "s|__HOME__|$HOME|g" "$SRC/config/policies.json" | sudo tee "$dir/policies.json" >/dev/null &&
        sudo chmod 644 "$dir/policies.json" &&
        ok "Firefox policies in $dir"
}

step_launchers() {
    local f
    mkdir -p "$ARGOS_HOME/launchers/lib" "$ARGOS_HOME/icons" "$APPS" "$HOME/Documents/Argos/cases"
    install -m 755 "$SRC"/launchers/*.sh "$ARGOS_HOME/launchers/"
    install -m 644 "$SRC/launchers/lib/argos.sh" "$ARGOS_HOME/launchers/lib/"
    install -m 644 "$SRC"/multimedia/icons/argos-*.svg "$ARGOS_HOME/icons/"
    # Folders and files that every new case starts with (see the Argos Case launcher).
    rm -rf "$ARGOS_HOME/case-skeleton"
    cp -r "$SRC/templates/case-skeleton" "$ARGOS_HOME/case-skeleton"
    cp "$SRC/templates/Argos_Research_Log.csv" "$SRC/templates/Argos_Case_Notebook.ctd" "$ARGOS_HOME/case-skeleton/notes/"
    for f in "$SRC"/desktop/argos-*.desktop; do
        sed -e "s|__ARGOS_HOME__|$ARGOS_HOME|g" -e "s|__HOME__|$HOME|g" "$f" > "$APPS/$(basename "$f")"
    done
    command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" 2>/dev/null
    ok "Launchers, icons and menu entries"
}

step_templates() {
    mkdir -p "$HOME/Templates"
    find "$SRC/templates" -maxdepth 1 -type f -name 'Argos_*' -exec cp {} "$HOME/Templates/" \; &&
        ok "Report templates in ~/Templates"
}

step_wallpaper() {
    local image="$HOME/Pictures/argos-wallpaper.jpg"
    mkdir -p "$HOME/Pictures"
    cp "$SRC/multimedia/wallpapers/Be-quiet-Priest-sculpture-in-Venlo.jpg" "$image" &&
        bash "$SRC/multimedia/wallpapers/set-wallpaper.sh" "$image"
}

# ── Main ────────────────────────────────────────────────────────────────────

run_step() {
    local name=$1 fn="step_${1//-/_}"
    if ! declare -F "$fn" >/dev/null; then
        fail "unknown step: $name (see --list)"
        FAILED_STEPS+=("$name")
        return
    fi
    head_line "$name"
    if "$fn"; then
        DONE_STEPS+=("$name")
    else
        fail "step $name did not complete"
        FAILED_STEPS+=("$name")
    fi
}

preflight() {
    if [ "$(id -u)" -eq 0 ]; then
        fail "Run setup.sh as your normal user (it uses sudo when needed), not as root."
        exit 1
    fi
    # shellcheck source=/dev/null
    . /etc/os-release
    if [ "${ID:-}" != ubuntu ]; then
        fail "Argos supports Ubuntu and Ubuntu Budgie 24.04 / 26.04 LTS. This system is ${PRETTY_NAME:-unknown}."
        exit 1
    fi
    case "${VERSION_ID:-}" in
        24.04|26.04) ok "${PRETTY_NAME}" ;;
        *) warn "Argos supports Ubuntu 24.04 and 26.04 LTS; this is ${PRETTY_NAME}. Continuing anyway." ;;
    esac
    if ! curl -fsS -o /dev/null --max-time 15 https://github.com; then
        fail "No internet connection (github.com unreachable)."
        exit 1
    fi
}

# need_sudo STEP...: true when one of the steps installs system files.
need_sudo() {
    local s
    for s in "$@"; do
        case "$s" in system|packages|eyewitness|obsidian|google-earth|vscodium|firefox) return 0 ;; esac
    done
    return 1
}

if [ "${1:-}" = "--list" ]; then
    printf '%s\n' "${STEPS[@]}"
    exit 0
fi

mkdir -p "$HOME/Downloads"
LOG_FILE="$HOME/Downloads/argos_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
trap 'rm -rf "$WORK"' EXIT

banner
printf 'Log file: %s\nStarted: %s\n' "$LOG_FILE" "$(date)"
preflight

if [ $# -gt 0 ]; then selected=("$@"); else selected=("${STEPS[@]}"); fi
if need_sudo "${selected[@]}"; then
    # "sudo true" rather than "sudo -v": Ubuntu 26.04 ships sudo-rs, whose -v
    # can hang without a terminal even when no password is needed.
    sudo -n true 2>/dev/null || sudo true || exit 1
    # Keep the sudo timestamp fresh during the long install.
    ( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &
fi
for s in "${selected[@]}"; do
    run_step "$s"
done

head_line "Summary"
printf 'Completed steps: %s\n' "${DONE_STEPS[*]:-none}"
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
    printf '%sSteps with errors: %s%s\n' "$RED" "${FAILED_STEPS[*]}" "$RESET"
fi
if [ ${#WARNINGS[@]} -gt 0 ]; then
    printf '%sWarnings:%s\n' "$YELLOW" "$RESET"
    printf '  - %s\n' "${WARNINGS[@]}"
fi
printf '\nFull log: %s\n' "$LOG_FILE"
printf '%s+----=[ Audi, vide, tace ]=----+%s\n\n' "$RED" "$RESET"

if [ $# -eq 0 ] && [ -t 0 ]; then
    read -rp "Press ENTER to reboot (needed for the PATH and the menu), or Ctrl+C to skip... "
    sudo reboot
fi
[ ${#FAILED_STEPS[@]} -eq 0 ]
