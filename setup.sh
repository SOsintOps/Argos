#!/bin/bash

# ============================================================
# ARGOS - OSINT Workstation Setup Script
# Compatible with: Ubuntu 24.04 LTS (Noble Numbat), Ubuntu Budgie 24.04 LTS
# Updated: 2026-07-04
# ============================================================

set -euo pipefail
trap 'log_error "ERROR at line $LINENO. Installation aborted."; exit 1' ERR

# ── Colours ─────────────────────────────────────────────────
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
OKCYAN='\033[96m'
RESET='\e[0m'

# ── Log ─────────────────────────────────────────────────────
LOG_FILE="$HOME/Downloads/argos_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Installation log: $LOG_FILE"
echo "Start: $(date)"
echo "──────────────────────────────────────────────────────"

log_ok()    { echo -e "${OKGREEN}[OK]${RESET}    $1"; }
log_warn()  { echo -e "${OKORANGE}[WARN]${RESET}  $1"; }
log_error() { echo -e "${OKRED}[ERROR]${RESET} $1"; }
log_step()  { echo -e "\n${OKBLUE}▶ $1${RESET}"; }
log_quip()  { echo -e "${OKCYAN}[STARK]${RESET} $1"; }

# ── Failed package tracking ─────────────────────────────────
FAILED_PACKAGES=()

# install_apt: install a single apt package, log warning on failure
install_apt() {
    local pkg="$1"
    if sudo apt install -y "$pkg"; then
        log_ok "  apt: $pkg"
    else
        log_warn "Package '$pkg' failed to install — continuing"
        FAILED_PACKAGES+=("$pkg")
    fi
}

# clone_or_update: clone a repo or pull if already present; handle partial clones
clone_or_update() {
    local repo="$1"
    local dest="$2"
    if [ -d "$dest/.git" ]; then
        git -C "$dest" pull || log_warn "git pull failed for $dest"
    elif [ -d "$dest" ]; then
        log_warn "$dest exists but is not a git repo — removing and re-cloning"
        rm -rf "$dest"
        git clone "$repo" "$dest" || log_warn "git clone failed for $dest"
    else
        git clone "$repo" "$dest" || log_warn "git clone failed for $dest"
    fi
}

# ── Banner ──────────────────────────────────────────────────
echo -e "$OKBLUE          _                   _           _              _            _        "
echo -e "$OKBLUE         / /\                /\ \        /\ \           /\ \         / /\      "
echo -e "$OKBLUE        / /  \              /  \ \      /  \ \         /  \ \       / /  \     "
echo -e "$OKBLUE       / / /\ \            / /\ \ \    / /\ \_\       / /\ \ \     / / /\ \__  "
echo -e "$OKBLUE      / / /\ \ \          / / /\ \_\  / / /\/_/      / / /\ \ \   / / /\ \___\ "
echo -e "$OKBLUE    / / /  \ \ \        / / /_/ / / / / / ______   / / /  \ \_\  \ \ \ \/___/ "
echo -e "$OKBLUE    / / /___/ /\ \      / / /__\/ / / / / /\_____\ / / /   / / /   \ \ \       "
echo -e "$OKBLUE   / / /_____/ /\ \    / / /_____/ / / /  \/____ // / /   / / /_    \ \ \      "
echo -e "$OKBLUE  / /_________/\ \ \  / / /\ \ \  / / /_____/ / // / /___/ / //_/\__/ / /      "
echo -e "$OKBLUE / / /_       __\ \_\/ / /  \ \ \/ / /______\/ // / /____\/ / \ \/___/ /       "
echo -e "$OKBLUE \_\___\     /____/_/\/_/    \_\/\/___________/ \/_________/   \_____\/        "
echo "    "
echo -e "$RESET"
echo -e "$OKRED +----=[Osint Ops]=----+ $RESET"

# ── Known potential failure points ──────────────────────────
#
# The following steps may fail under certain conditions.
# The script will log a warning and continue where possible.
#
#  1. snap operations (obsidian, amass, cherrytree, snap refresh)
#     snapd requires a fully operational systemd. In restricted VM
#     environments or containers, snapd may hang rather than fail cleanly.
#     All snap calls are wrapped with a timeout or a || log_warn fallback.
#
#  2. torbrowser-launcher
#     On some Ubuntu 24.04 configurations this package requires the
#     universe repository and may fail to fetch the upstream launcher.
#     Install manually if the apt step reports a download error.
#
#  3. Network-dependent steps
#     wget, curl, and git clone calls all require a working internet
#     connection. Any network failure will abort that individual step.
#     The script does not retry failed downloads automatically.
#
#  4. Firefox policies.json
#     The script deploys a policies.json file to the Firefox distribution
#     directory. On snap installs the target is /etc/firefox/policies/; on
#     deb installs it is /usr/lib/firefox/distribution/. If neither path
#     can be created the step is skipped with a warning.
#
#  5. EyeWitness/Python/setup/setup.sh
#     EyeWitness runs its own bundled setup script, which installs pip
#     dependencies inside its own virtualenv. If those dependencies
#     conflict with the system Python or each other, the step will fail.
#     The outer script captures this with || log_warn and continues.
#
# ─────────────────────────────────────────────────────────────

# ── User check ──────────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
    log_error "Do not run this script as root. Use a regular user with sudo."
    exit 1
fi

# ── Source directory check ──────────────────────────────────
ARGOS_SRC="$HOME/Downloads/Argos"
if [ ! -d "$ARGOS_SRC" ]; then
    log_error "Argos repository not found at $ARGOS_SRC. Clone it there first (see README)."
    exit 1
fi

# ============================================================
log_step "System update"
# ============================================================
echo '#######################################################################'
echo '#                           OS Update                                #'
echo '#######################################################################'

sudo apt -y update && sudo apt -y upgrade
sudo add-apt-repository -y multiverse 2>/dev/null || true
sudo apt -y update -qq
timeout 30 sudo snap refresh 2>/dev/null || log_warn "snap refresh failed or timed out"
log_ok "System updated"
log_quip "System patched. Unlike some people's situational awareness."
log_quip "JARVIS is unavailable. You get the manual installation. Try to keep up."

# ============================================================
log_step "Copying scripts, icons, shortcuts and templates"
# ============================================================
echo '#######################################################################'
echo '#                         Support files                              #'
echo '#######################################################################'

# Guard each copy with compgen so an empty source directory logs a
# warning instead of aborting the whole install under set -e.
mkdir -p ~/Documents/scripts
if compgen -G "$ARGOS_SRC/scripts/*.sh" > /dev/null; then
    cp "$ARGOS_SRC"/scripts/*.sh ~/Documents/scripts
    sudo chmod +x ~/Documents/scripts/*.sh
else
    log_warn "No scripts found in $ARGOS_SRC/scripts — skipping"
fi

mkdir -p ~/Pictures/icons
if compgen -G "$ARGOS_SRC/multimedia/icons/*" > /dev/null; then
    cp "$ARGOS_SRC"/multimedia/icons/* ~/Pictures/icons
else
    log_warn "No icons found in $ARGOS_SRC/multimedia/icons — skipping"
fi

if compgen -G "$ARGOS_SRC/shortcuts/*.desktop" > /dev/null; then
    for f in "$ARGOS_SRC"/shortcuts/*.desktop; do
        sed "s|__HOME__|$HOME|g" "$f" | sudo tee "/usr/share/applications/$(basename "$f")" > /dev/null
    done
else
    log_warn "No .desktop shortcuts found in $ARGOS_SRC/shortcuts — skipping"
fi

mkdir -p ~/Templates
if compgen -G "$ARGOS_SRC/templates/*" > /dev/null; then
    cp -r "$ARGOS_SRC"/templates/* ~/Templates
else
    log_warn "No templates found in $ARGOS_SRC/templates — skipping"
fi

if compgen -G "$ARGOS_SRC/multimedia/wallpapers/*" > /dev/null; then
    cp "$ARGOS_SRC"/multimedia/wallpapers/* ~/Pictures
fi
if [ -f "$ARGOS_SRC/multimedia/wallpapers/background.sh" ]; then
    sudo chmod +x "$ARGOS_SRC/multimedia/wallpapers/background.sh"
    "$ARGOS_SRC/multimedia/wallpapers/background.sh" || log_warn "Wallpaper script failed"
else
    log_warn "background.sh not found — skipping wallpaper setup"
fi

log_ok "Support files copied"

# ============================================================
log_step "Installing system dependencies"
# ============================================================
echo '#######################################################################'
echo '#      Dependencies: apt, curl, python, java, multimedia tools        #'
echo '#######################################################################'
log_quip "Installing 29 packages. I built a suit faster. Then again, I had better hardware."

for _pkg in \
    vlc \
    python3 \
    python3-setuptools \
    python3-pip \
    python3-venv \
    pipx \
    jq \
    git \
    curl \
    wget \
    ffmpeg \
    mediainfo-gui \
    libimage-exiftool-perl \
    subversion \
    yt-dlp \
    httrack \
    openjdk-21-jre \
    ripgrep \
    7zip \
    p7zip-full \
    unrar \
    zip \
    openshot-qt \
    keepassxc \
    torbrowser-launcher \
    kazam \
    audacity \
    tor \
    proxychains4; do
    install_apt "$_pkg"
done

# Ensure pipx is in PATH
pipx ensurepath || true

log_ok "System dependencies installed"
log_quip "Dependencies resolved. You'd think they'd standardise this by now. They won't."

# ============================================================
log_step "Installing Python OSINT tools via pipx"
# ============================================================
echo '#######################################################################'
echo '#           Python tools (pipx - Ubuntu 24.04 PEP 668)               #'
echo '#######################################################################'

# pipx isolates each tool in a dedicated venv, compatible with PEP 668 (Python 3.12)
install_pipx() {
    local pkg=$1
    local name=${2:-$pkg}
    log_step "  pipx: $name"
    pipx install "$pkg" --force 2>&1 || log_warn "pipx install $pkg failed, continuing"
}

install_pipx instaloader
install_pipx toutatis
install_pipx maigret
install_pipx user-scanner
install_pipx sherlock-project sherlock
install_pipx spiderfoot
install_pipx linkook
install_pipx socialscan
install_pipx shodan

log_ok "Python tools installed via pipx"
log_quip "Isolated environments. Because dependency conflicts are someone else's problem now."

# ============================================================
log_step "Firefox customisation"
# ============================================================
echo '#######################################################################'
echo '#                        Customising Firefox                          #'
echo '#######################################################################'
log_quip "Firefox. Not my first choice. Or my second. But it is open source, I'll give it that."

POLICIES_SRC="$ARGOS_SRC/config/policies.json"

if [ ! -f "$POLICIES_SRC" ]; then
    log_warn "policies.json not found at $POLICIES_SRC, skipping Firefox customisation"
else
    FF_POLICY_DIR=""
    if snap list firefox &>/dev/null; then
        FF_POLICY_DIR="/etc/firefox/policies"
    elif [ -d "/usr/lib/firefox" ]; then
        FF_POLICY_DIR="/usr/lib/firefox/distribution"
    fi

    if [ -n "$FF_POLICY_DIR" ]; then
        sudo mkdir -p "$FF_POLICY_DIR"
        # policies.json contains local file:// URLs (Exploratores) with a
        # __HOME__ placeholder — substitute the real $HOME at deploy time,
        # same mechanism used for the .desktop shortcuts.
        sed "s|__HOME__|$HOME|g" "$POLICIES_SRC" | sudo tee "$FF_POLICY_DIR/policies.json" > /dev/null
        sudo chmod 644 "$FF_POLICY_DIR/policies.json"
        log_ok "Firefox policies.json deployed to $FF_POLICY_DIR"
    else
        log_warn "Firefox installation not detected (snap or deb). Skipping policies.json deployment."
    fi
fi

# ============================================================
log_step "Obsidian"
# ============================================================
echo '#######################################################################'
echo '#                           Obsidian                                  #'
echo '#######################################################################'
log_quip "Obsidian. Note-taking for people who think in graphs. I can respect that."

# Fetch the latest version dynamically
OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
    | jq -r '.tag_name' | sed 's/v//') || true
if [ -z "$OBSIDIAN_VERSION" ] || [ "$OBSIDIAN_VERSION" = "null" ]; then
    log_warn "Unable to retrieve Obsidian version. Using fallback 1.7.7"
    OBSIDIAN_VERSION="1.7.7"
fi
log_step "  Obsidian version: $OBSIDIAN_VERSION"
cd ~/Downloads
if wget -q "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.snap"; then
    sudo snap install --dangerous "obsidian_${OBSIDIAN_VERSION}_amd64.snap" \
        || log_warn "snap install obsidian failed — install manually from https://obsidian.md"
    sudo rm -f "obsidian_${OBSIDIAN_VERSION}_amd64.snap"
else
    log_warn "Obsidian download failed — install manually from https://obsidian.md"
fi

git clone https://github.com/WebBreacher/obsidian-osint-templates ~/Documents/obsidian-osint-templates 2>/dev/null \
    || log_warn "obsidian-osint-templates already present"
git clone https://github.com/theNerdInTheHighCastle/Obsidian ~/Documents/obsidian-criptovalute 2>/dev/null \
    || log_warn "obsidian-criptovalute already present"

log_ok "Obsidian $OBSIDIAN_VERSION installed"

# ============================================================
log_step "Amass"
# ============================================================
echo '#######################################################################'
echo '#                             Amass                                   #'
echo '#######################################################################'

sudo snap install amass || log_warn "snap install amass failed"
log_ok "Amass installed"

# ============================================================
log_step "EyeWitness"
# ============================================================
echo '#######################################################################'
echo '#                          EyeWitness                                 #'
echo '#######################################################################'

mkdir -p ~/Downloads/Programs
clone_or_update "https://github.com/FortyNorthSecurity/EyeWitness.git" "$HOME/Downloads/Programs/EyeWitness"
bash ~/Downloads/Programs/EyeWitness/Python/setup/setup.sh || log_warn "EyeWitness setup failed"
log_ok "EyeWitness installed"

# ============================================================
log_step "theHarvester"
# ============================================================
echo '#######################################################################'
echo '#                       The Harvester                                 #'
echo '#######################################################################'
log_quip "theHarvester. I built something similar once. In an afternoon. With worse coffee."

clone_or_update "https://github.com/laramies/theHarvester.git" "$HOME/Downloads/Programs/theHarvester"
if python3 -m venv ~/Downloads/Programs/theHarvester/.venv; then
    ~/Downloads/Programs/theHarvester/.venv/bin/pip install -r ~/Downloads/Programs/theHarvester/requirements/base.txt \
        || log_warn "pip install for theHarvester failed — check requirements/base.txt"
else
    log_warn "venv creation failed for theHarvester — python3-venv may not be installed"
fi
log_ok "theHarvester installed"

# ============================================================
log_step "metagoofil"
# ============================================================
echo '#######################################################################'
echo '#                           Metagoofil                                #'
echo '#######################################################################'

clone_or_update "https://github.com/opsdisk/metagoofil.git" "$HOME/Downloads/Programs/metagoofil"
if python3 -m venv ~/Downloads/Programs/metagoofil/.venv; then
    ~/Downloads/Programs/metagoofil/.venv/bin/pip install -r ~/Downloads/Programs/metagoofil/requirements.txt \
        || log_warn "pip install for metagoofil failed — check requirements.txt"
else
    log_warn "venv creation failed for metagoofil — python3-venv may not be installed"
fi
log_ok "metagoofil installed"

# ============================================================
log_step "recon-ng"
# ============================================================
echo '#######################################################################'
echo '#                            recon-ng                                 #'
echo '#######################################################################'

clone_or_update "https://github.com/lanmaster53/recon-ng.git" "$HOME/Downloads/Programs/recon-ng"
if python3 -m venv ~/Downloads/Programs/recon-ng/.venv; then
    ~/Downloads/Programs/recon-ng/.venv/bin/pip install -r ~/Downloads/Programs/recon-ng/REQUIREMENTS \
        || log_warn "pip install for recon-ng failed — check REQUIREMENTS"
else
    log_warn "venv creation failed for recon-ng — python3-venv may not be installed"
fi
log_ok "recon-ng installed"

# ============================================================
log_step "blackbird"
# ============================================================
echo '#######################################################################'
echo '#                            blackbird                                #'
echo '#######################################################################'

clone_or_update "https://github.com/p1ngul1n0/blackbird.git" "$HOME/Downloads/Programs/blackbird"
if python3 -m venv ~/Downloads/Programs/blackbird/.venv; then
    ~/Downloads/Programs/blackbird/.venv/bin/pip install -r ~/Downloads/Programs/blackbird/requirements.txt \
        || log_warn "pip install for blackbird failed — check requirements.txt"
else
    log_warn "venv creation failed for blackbird — python3-venv may not be installed"
fi
log_ok "blackbird installed"

# ============================================================
log_step "spiderfoot (script launcher)"
# ============================================================
echo '#######################################################################'
echo '#                           spiderfoot                                #'
echo '#######################################################################'

log_ok "spiderfoot configured (via pipx)"

# ============================================================
log_step "Google Earth Pro"
# ============================================================
echo '#######################################################################'
echo '#                          Google Earth Pro                           #'
echo '#######################################################################'

log_quip "Google Earth. I have better satellite access. It's classified. You're welcome."
# The official APT repo (dl.google.com/linux/earth/deb/) does not include Noble (24.04)
# and causes errors on every apt update. Using the direct .deb download instead.
wget -q -O ~/Downloads/google-earth64.deb \
    https://dl.google.com/linux/direct/google-earth-pro-stable_current_amd64.deb || {
    log_warn "Google Earth Pro download failed. Download manually from https://www.google.com/earth/about/versions/"
}
if [ -f ~/Downloads/google-earth64.deb ]; then
    sudo apt install -y "$HOME/Downloads/google-earth64.deb" || { sudo dpkg -i "$HOME/Downloads/google-earth64.deb"; sudo apt -f install -y; }
    rm -f ~/Downloads/google-earth64.deb
    # The .deb post-install adds a broken APT repo on Noble — remove it
    sudo rm -f /etc/apt/sources.list.d/google-earth-pro.list
    sudo apt update -qq
    log_ok "Google Earth Pro installed"
else
    log_warn "Google Earth Pro not installed — proceed manually"
fi

# ============================================================
log_step "PhoneInfoga"
# ============================================================
echo '#######################################################################'
echo '#                          PhoneInfoga                                #'
echo '#######################################################################'

# PhoneInfoga is a Go binary — no pip/pipx available.
# The developer has declared the project stable but unmaintained.
# The binary remains functional and is widely used.
PHONEINFOGA_URL="https://raw.githubusercontent.com/sundowndev/phoneinfoga/master/support/scripts/install"
if curl -sSL "$PHONEINFOGA_URL" -o /tmp/phoneinfoga_install.sh 2>/dev/null; then
    bash /tmp/phoneinfoga_install.sh || log_warn "PhoneInfoga install script failed"
    rm -f /tmp/phoneinfoga_install.sh
    if [ -f ./phoneinfoga ]; then
        sudo install ./phoneinfoga /usr/local/bin/phoneinfoga || log_warn "PhoneInfoga binary install failed"
        rm -f ./phoneinfoga
        log_ok "PhoneInfoga installed"
    else
        log_warn "PhoneInfoga binary not found after install — check manually"
    fi
else
    log_warn "PhoneInfoga download failed — install manually from https://github.com/sundowndev/phoneinfoga/releases"
fi

# ============================================================
log_step "Exploratores"
# ============================================================
echo '#######################################################################'
echo '#                          Exploratores                               #'
echo '#######################################################################'

# Exploratores: browser-based OSINT toolkit (static HTML/CSS/JS, no backend).
# Cloned locally; entry point is launchme.html, opened directly in Firefox.
clone_or_update "https://github.com/SOsintOps/Exploratores.git" "$HOME/Documents/Exploratores"
if [ -f "$HOME/Documents/Exploratores/launchme.html" ]; then
    log_ok "Exploratores installed in ~/Documents/Exploratores"
else
    log_warn "Exploratores clone incomplete — launchme.html not found"
fi

# ============================================================
log_step "General purpose tools"
# ============================================================
echo '#######################################################################'
echo '#                       General Purpose Tools                         #'
echo '#######################################################################'

# CherryTree via snap (more reliable than the PPA on Ubuntu 24.04)
sudo snap install cherrytree || {
    log_warn "snap cherrytree failed, trying apt"
    sudo add-apt-repository -y ppa:giuspen/ppa 2>/dev/null && sudo apt install -y cherrytree \
        || log_warn "cherrytree not installed"
}

# VSCodium instead of Atom (discontinued Dec 2022)
sudo mkdir -p /etc/apt/keyrings
if wget -qO- https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/vscodium.gpg > /dev/null; then
    echo "deb [ signed-by=/etc/apt/keyrings/vscodium.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main" \
        | sudo tee /etc/apt/sources.list.d/vscodium.list > /dev/null
    sudo apt update -qq && sudo apt install -y codium || log_warn "VSCodium not installed"
else
    log_warn "VSCodium key download failed — skipping VSCodium install"
fi

# OSINT resources
git clone https://github.com/pstirparo/threatintel-resources ~/Documents/threatintel-resources 2>/dev/null \
    || log_warn "threatintel-resources already present"
git clone https://github.com/mxm0z/awesome-intelligence-writing ~/Documents/awesome-intelligence-writing 2>/dev/null \
    || log_warn "awesome-intelligence-writing already present"

sudo apt autoremove -y
log_ok "General purpose tools installed"

# ============================================================
log_step "Script launcher customisation"
# ============================================================
echo '#######################################################################'
echo '#                       Customising scripts                           #'
echo '#######################################################################'

log_ok "Scripts ready"

# ── Failed packages summary ──────────────────────────────────
if [ "${#FAILED_PACKAGES[@]}" -gt 0 ]; then
    echo ""
    echo "══════════════════════════════════════════════════════"
    echo -e "${OKORANGE}  The following packages failed to install:${RESET}"
    for _p in "${FAILED_PACKAGES[@]}"; do
        echo -e "  ${OKORANGE}[WARN]${RESET}  $_p"
    done
    echo "  Review the log for details: $LOG_FILE"
    echo "══════════════════════════════════════════════════════"
fi

# ============================================================
log_quip "Installation complete. The world is marginally better equipped. You're welcome."
echo ""
echo "══════════════════════════════════════════════════════"
echo -e "$OKGREEN  Installation complete!$RESET"
echo "  Log saved to: $LOG_FILE"
echo "══════════════════════════════════════════════════════"
echo ""
echo -e "$OKRED +----=[Audi, vide, tace]=----+ $RESET"
echo ""
echo "NOTE: Run 'source ~/.bashrc' or open a new terminal"
echo "      to update the PATH with pipx tools."
echo ""
# Reboot only in an interactive session: without a TTY, read would
# return immediately and the machine would reboot with no confirmation.
if [ -t 0 ]; then
    read -rsp $'Press ENTER to reboot the system...\n'
    sudo reboot now
else
    echo "Non-interactive session detected — automatic reboot skipped."
    echo "Reboot manually to complete the setup."
fi
