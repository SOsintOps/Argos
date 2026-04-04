#!/bin/bash

# ============================================================
# ARGOS - OSINT Workstation Setup Script
# Compatible with: Ubuntu 24.04 LTS (Noble Numbat), Ubuntu Budgie 24.04 LTS
# Updated: 2026-04-04
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
#  1. virtualbox-guest-utils / virtualbox-guest-x11
#     These packages are only useful inside a VirtualBox VM.
#     On bare-metal or other hypervisors the install will succeed but
#     the kernel modules will not load. If the target is not a VirtualBox
#     guest, these packages can safely be ignored.
#
#  2. snap operations (obsidian, amass, cherrytree, snap refresh)
#     snapd requires a fully operational systemd. In restricted VM
#     environments or containers, snapd may hang rather than fail cleanly.
#     All snap calls are wrapped with a timeout or a || log_warn fallback.
#
#  3. torbrowser-launcher
#     On some Ubuntu 24.04 configurations this package requires the
#     universe repository and may fail to fetch the upstream launcher.
#     Install manually if the apt step reports a download error.
#
#  4. Network-dependent steps
#     wget, curl, and git clone calls all require a working internet
#     connection. Any network failure will abort that individual step.
#     The script does not retry failed downloads automatically.
#
#  5. Firefox auto-launch
#     The profile initialisation block launches Firefox in the background
#     and waits 15 seconds. This will not work in headless environments or
#     minimal desktop sessions where a display is not available.
#
#  6. EyeWitness/Python/setup/setup.sh
#     EyeWitness runs its own bundled setup script, which installs pip
#     dependencies inside its own virtualenv. If those dependencies
#     conflict with the system Python or each other, the step will fail.
#     The outer script captures this with || log_warn and continues.
#
# ─────────────────────────────────────────────────────────────

log_quip "JARVIS is unavailable. You get the manual installation. Try to keep up."

# ── User check ──────────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
    log_error "Do not run this script as root. Use a regular user with sudo."
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

# ============================================================
log_step "Copying scripts, icons, shortcuts and templates"
# ============================================================
echo '#######################################################################'
echo '#                         Support files                              #'
echo '#######################################################################'

mkdir -p ~/Documents/scripts
cp ~/Downloads/Argos/scripts/*.sh ~/Documents/scripts
sudo chmod +x ~/Documents/scripts/*.sh

mkdir -p ~/Pictures/icons
cp ~/Downloads/Argos/multimedia/icons/* ~/Pictures/icons

for f in ~/Downloads/Argos/shortcuts/*.desktop; do
    sed "s|/home/osint/|$HOME/|g" "$f" | sudo tee "/usr/share/applications/$(basename "$f")" > /dev/null
done

cp -r ~/Downloads/Argos/templates/* ~/Templates

cp ~/Downloads/Argos/multimedia/wallpapers/* ~/Pictures
sudo chmod +x ~/Downloads/Argos/multimedia/wallpapers/background.sh
~/Downloads/Argos/multimedia/wallpapers/background.sh || log_warn "Wallpaper script failed"

log_ok "Support files copied"

# ============================================================
log_step "Installing system dependencies"
# ============================================================
echo '#######################################################################'
echo '#      Dependencies: apt, curl, python, java, multimedia tools        #'
echo '#######################################################################'
log_quip "Installing 31 packages. I built a suit faster. Then again, I had better hardware."

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
    virtualbox-guest-utils \
    virtualbox-guest-x11 \
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
install_pipx holehe
install_pipx sherlock-project sherlock
install_pipx spiderfoot

log_ok "Python tools installed via pipx"
log_quip "Isolated environments. Because dependency conflicts are someone else's problem now."

# ============================================================
log_step "Firefox customisation"
# ============================================================
echo '#######################################################################'
echo '#                        Customising Firefox                          #'
echo '#######################################################################'
log_quip "Firefox. Not my first choice. Or my second. But it is open source, I'll give it that."

pkill -f firefox 2>/dev/null || true
sleep 2

# Detect Firefox profile dynamically (snap or deb)
FIREFOX_SNAP_DIR="$HOME/snap/firefox/common/.mozilla/firefox"
FIREFOX_DEB_DIR="$HOME/.mozilla/firefox"
FF_PROFILE=""

# If Firefox has never been opened, launch it once to create the default profile
if [ ! -d "$FIREFOX_SNAP_DIR" ] && [ ! -d "$FIREFOX_DEB_DIR" ]; then
    log_warn "Firefox profile not found. Launching Firefox to initialise it..."
    firefox &>/dev/null &
    FF_INIT_PID=$!
    sleep 15
    kill "$FF_INIT_PID" 2>/dev/null || true
    pkill -f firefox 2>/dev/null || true
    sleep 3
fi

if [ -d "$FIREFOX_SNAP_DIR" ]; then
    FF_PROFILE=$(find "$FIREFOX_SNAP_DIR" -maxdepth 1 -name "*.default*" -type d 2>/dev/null | head -1)
elif [ -d "$FIREFOX_DEB_DIR" ]; then
    FF_PROFILE=$(find "$FIREFOX_DEB_DIR" -maxdepth 1 -name "*.default*" -type d 2>/dev/null | head -1)
fi

if cd ~/Downloads/Argos/argosfox/ 2>/dev/null; then
    if [ -f argos-ff-template.zip ]; then
        zip -F argos-ff-template.zip --out argos-ff-template2.zip
        unzip -o argos-ff-template2.zip
        if [ -n "$FF_PROFILE" ]; then
            cp -R ~/Downloads/Argos/argosfox/argos-ff-template/* "$FF_PROFILE"
            log_ok "Firefox profile customised: $FF_PROFILE"
        else
            log_warn "Firefox profile not found. Open Firefox at least once before running this script."
        fi
    else
        log_warn "argos-ff-template.zip not found, skipping Firefox customisation"
    fi
    cd - > /dev/null
else
    log_warn "argosfox directory not found, skipping Firefox customisation"
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
    | jq -r '.tag_name' | sed 's/v//')
if [ -z "$OBSIDIAN_VERSION" ]; then
    log_warn "Unable to retrieve Obsidian version. Using fallback 1.7.7"
    OBSIDIAN_VERSION="1.7.7"
fi
log_step "  Obsidian version: $OBSIDIAN_VERSION"
cd ~/Downloads
wget -q "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.snap"
sudo snap install --dangerous "obsidian_${OBSIDIAN_VERSION}_amd64.snap" \
    || log_warn "snap install obsidian failed — install manually from https://obsidian.md"
sudo rm -f "obsidian_${OBSIDIAN_VERSION}_amd64.snap"

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
wget -qO- https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/vscodium.gpg > /dev/null
echo "deb [ signed-by=/etc/apt/keyrings/vscodium.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main" \
    | sudo tee /etc/apt/sources.list.d/vscodium.list > /dev/null
sudo apt update -qq && sudo apt install -y codium || log_warn "VSCodium not installed"

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
echo -e "$OKRED +----=[Si vis pacem, para bellum]=----+ $RESET"
echo ""
echo "NOTE: Run 'source ~/.bashrc' or open a new terminal"
echo "      to update the PATH with pipx tools."
echo ""
read -rsp $'Press ENTER to reboot the system...\n'
sudo reboot now
