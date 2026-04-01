#!/bin/bash

# ============================================================
# ARGOS - OSINT Workstation Setup Script
# Compatibile con: Ubuntu 24.04 LTS (Noble Numbat), Ubuntu Budgie 24.04 LTS
# Aggiornato: 2026-03-31
# ============================================================

set -euo pipefail
trap 'log_error "ERRORE alla riga $LINENO. Installazione interrotta."; exit 1' ERR

# ── Colori ──────────────────────────────────────────────────
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

# ── Log ─────────────────────────────────────────────────────
LOG_FILE="$HOME/Downloads/argos_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Log di installazione: $LOG_FILE"
echo "Inizio: $(date)"
echo "──────────────────────────────────────────────────────"

log_ok()    { echo -e "${OKGREEN}[OK]${RESET}    $1"; }
log_warn()  { echo -e "${OKORANGE}[WARN]${RESET}  $1"; }
log_error() { echo -e "${OKRED}[ERROR]${RESET} $1"; }
log_step()  { echo -e "\n${OKBLUE}▶ $1${RESET}"; }

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

# ── Verifica utente ─────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
    log_error "Non eseguire questo script come root. Usare un utente normale con sudo."
    exit 1
fi

# ============================================================
log_step "Aggiornamento sistema operativo"
# ============================================================
echo '#######################################################################'
echo '#                         Aggiornamento OS                            #'
echo '#######################################################################'

sudo apt -y update && sudo apt -y upgrade
sudo add-apt-repository -y multiverse 2>/dev/null || true
sudo apt -y update -qq
sudo snap refresh || log_warn "snap refresh fallito (snap potrebbe non essere installato)"
log_ok "Sistema aggiornato"

# ============================================================
log_step "Copia script, icone, shortcut e template"
# ============================================================
echo '#######################################################################'
echo '#                         File di supporto                            #'
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
~/Downloads/Argos/multimedia/wallpapers/background.sh || log_warn "Script wallpaper fallito"

log_ok "File di supporto copiati"

# ============================================================
log_step "Installazione dipendenze di sistema"
# ============================================================
echo '#######################################################################'
echo '#      Dipendenze: apt, curl, python, java, multimedia tools          #'
echo '#######################################################################'

sudo apt install -y \
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
    7zip p7zip-full unrar \
    openshot \
    virtualbox-guest-utils \
    virtualbox-guest-x11 \
    keepassxc \
    torbrowser-launcher \
    kazam \
    audacity \
    tor \
    proxychains4

# Assicura che pipx sia nel PATH
pipx ensurepath || true

log_ok "Dipendenze di sistema installate"

# ============================================================
log_step "Installazione tool Python OSINT via pipx"
# ============================================================
echo '#######################################################################'
echo '#              Tool Python (pipx - Ubuntu 24.04 PEP 668)              #'
echo '#######################################################################'

# pipx isola ogni tool in un venv dedicato, compatibile con PEP 668 (Python 3.12)
install_pipx() {
    local pkg=$1
    local name=${2:-$pkg}
    log_step "  pipx: $name"
    pipx install "$pkg" --force 2>&1 || log_warn "pipx install $pkg fallito, continuo"
}

install_pipx instaloader
install_pipx toutatis
install_pipx maigret
install_pipx holehe
install_pipx sherlock-project sherlock
install_pipx spiderfoot

log_ok "Tool Python installati via pipx"

# ============================================================
log_step "Personalizzazione Firefox"
# ============================================================
echo '#######################################################################'
echo '#                        Customizing Firefox                          #'
echo '#######################################################################'

pkill -f firefox 2>/dev/null || true
sleep 2

# Rileva il profilo Firefox in modo dinamico (snap o deb)
FIREFOX_SNAP_DIR="$HOME/snap/firefox/common/.mozilla/firefox"
FIREFOX_DEB_DIR="$HOME/.mozilla/firefox"
FF_PROFILE=""

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
            log_ok "Profilo Firefox personalizzato: $FF_PROFILE"
        else
            log_warn "Profilo Firefox non trovato. Aprire Firefox almeno una volta prima di eseguire lo script."
        fi
    else
        log_warn "argos-ff-template.zip non trovato, salto personalizzazione Firefox"
    fi
    cd - > /dev/null
else
    log_warn "Directory argosfox non trovata, salto personalizzazione Firefox"
fi

# ============================================================
log_step "Obsidian"
# ============================================================
echo '#######################################################################'
echo '#                           Obsidian                                  #'
echo '#######################################################################'

# Recupera dinamicamente l'ultima versione
OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
    | jq -r '.tag_name' | sed 's/v//')
if [ -z "$OBSIDIAN_VERSION" ]; then
    log_warn "Impossibile recuperare la versione Obsidian. Uso versione di fallback 1.7.7"
    OBSIDIAN_VERSION="1.7.7"
fi
log_step "  Obsidian versione: $OBSIDIAN_VERSION"
cd ~/Downloads
wget -q "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.snap"
sudo snap install --dangerous "obsidian_${OBSIDIAN_VERSION}_amd64.snap"
sudo rm "obsidian_${OBSIDIAN_VERSION}_amd64.snap"

git clone https://github.com/WebBreacher/obsidian-osint-templates ~/Documents/obsidian-osint-templates 2>/dev/null \
    || log_warn "obsidian-osint-templates già presente"
git clone https://github.com/theNerdInTheHighCastle/Obsidian ~/Documents/obsidian-criptovalute 2>/dev/null \
    || log_warn "obsidian-criptovalute già presente"

log_ok "Obsidian $OBSIDIAN_VERSION installato"

# ============================================================
log_step "Amass"
# ============================================================
echo '#######################################################################'
echo '#                             Amass                                   #'
echo '#######################################################################'

sudo snap install amass || log_warn "snap install amass fallito"
log_ok "Amass installato"

# ============================================================
log_step "EyeWitness"
# ============================================================
echo '#######################################################################'
echo '#                          EyeWitness                                 #'
echo '#######################################################################'

mkdir -p ~/Downloads/Programs
git clone https://github.com/FortyNorthSecurity/EyeWitness.git ~/Downloads/Programs/EyeWitness 2>/dev/null \
    || (cd ~/Downloads/Programs/EyeWitness && git pull)
bash ~/Downloads/Programs/EyeWitness/Python/setup/setup.sh || log_warn "Setup EyeWitness fallito"
log_ok "EyeWitness installato"

# ============================================================
log_step "theHarvester"
# ============================================================
echo '#######################################################################'
echo '#                       The Harvester                                 #'
echo '#######################################################################'

git clone https://github.com/laramies/theHarvester.git ~/Downloads/Programs/theHarvester 2>/dev/null \
    || (cd ~/Downloads/Programs/theHarvester && git pull)
python3 -m venv ~/Downloads/Programs/theHarvester/.venv
~/Downloads/Programs/theHarvester/.venv/bin/pip install -r ~/Downloads/Programs/theHarvester/requirements/base.txt
log_ok "theHarvester installato"

# ============================================================
log_step "metagoofil"
# ============================================================
echo '#######################################################################'
echo '#                           Metagoofil                                #'
echo '#######################################################################'

git clone https://github.com/opsdisk/metagoofil.git ~/Downloads/Programs/metagoofil 2>/dev/null \
    || (cd ~/Downloads/Programs/metagoofil && git pull)
python3 -m venv ~/Downloads/Programs/metagoofil/.venv
~/Downloads/Programs/metagoofil/.venv/bin/pip install -r ~/Downloads/Programs/metagoofil/requirements.txt
log_ok "metagoofil installato"

# ============================================================
log_step "recon-ng"
# ============================================================
echo '#######################################################################'
echo '#                            recon-ng                                 #'
echo '#######################################################################'

git clone https://github.com/lanmaster53/recon-ng.git ~/Downloads/Programs/recon-ng 2>/dev/null \
    || (cd ~/Downloads/Programs/recon-ng && git pull)
python3 -m venv ~/Downloads/Programs/recon-ng/.venv
~/Downloads/Programs/recon-ng/.venv/bin/pip install -r ~/Downloads/Programs/recon-ng/REQUIREMENTS
log_ok "recon-ng installato"

# ============================================================
log_step "blackbird"
# ============================================================
echo '#######################################################################'
echo '#                            blackbird                                #'
echo '#######################################################################'

git clone https://github.com/p1ngul1n0/blackbird.git ~/Downloads/Programs/blackbird 2>/dev/null \
    || (cd ~/Downloads/Programs/blackbird && git pull)
python3 -m venv ~/Downloads/Programs/blackbird/.venv
~/Downloads/Programs/blackbird/.venv/bin/pip install -r ~/Downloads/Programs/blackbird/requirements.txt
log_ok "blackbird installato"

# ============================================================
log_step "spiderfoot (script launcher)"
# ============================================================
echo '#######################################################################'
echo '#                           spiderfoot                                #'
echo '#######################################################################'

log_ok "spiderfoot configurato (via pipx)"

# ============================================================
log_step "Google Earth Pro"
# ============================================================
echo '#######################################################################'
echo '#                          Google Earth Pro                           #'
echo '#######################################################################'

# Il repo APT ufficiale (dl.google.com/linux/earth/deb/) non include Noble (24.04)
# e causa errori ad ogni apt update. Si usa il download diretto del .deb.
wget -q -O ~/Downloads/google-earth64.deb \
    https://dl.google.com/linux/direct/google-earth-pro-stable_current_amd64.deb || {
    log_warn "Download Google Earth Pro fallito. Scaricare manualmente da https://www.google.com/earth/about/versions/"
}
if [ -f ~/Downloads/google-earth64.deb ]; then
    sudo apt install -y "$HOME/Downloads/google-earth64.deb" || { sudo dpkg -i "$HOME/Downloads/google-earth64.deb"; sudo apt -f install -y; }
    rm -f ~/Downloads/google-earth64.deb
    # Il post-install del .deb aggiunge un repo APT rotto su Noble — va rimosso
    sudo rm -f /etc/apt/sources.list.d/google-earth-pro.list
    sudo apt update -qq
    log_ok "Google Earth Pro installato"
else
    log_warn "Google Earth Pro non installato — procedere manualmente"
fi

# ============================================================
log_step "Tool generici"
# ============================================================
echo '#######################################################################'
echo '#                       General Purpose Tools                         #'
echo '#######################################################################'

# CherryTree via snap (piu' affidabile del PPA su Ubuntu 24.04)
sudo snap install cherrytree || {
    log_warn "snap cherrytree fallito, provo apt"
    sudo add-apt-repository -y ppa:giuspen/ppa 2>/dev/null && sudo apt install -y cherrytree \
        || log_warn "cherrytree non installato"
}

# VSCodium al posto di Atom (discontinuato dic 2022)
wget -qO- https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/vscodium.gpg > /dev/null
echo "deb [ signed-by=/etc/apt/keyrings/vscodium.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main" \
    | sudo tee /etc/apt/sources.list.d/vscodium.list > /dev/null
sudo apt update -qq && sudo apt install -y codium || log_warn "VSCodium non installato"

# Risorse OSINT
git clone https://github.com/pstirparo/threatintel-resources ~/Documents/threatintel-resources 2>/dev/null \
    || log_warn "threatintel-resources gia presente"
git clone https://github.com/mxm0z/awesome-intelligence-writing ~/Documents/awesome-intelligence-writing 2>/dev/null \
    || log_warn "awesome-intelligence-writing gia presente"

sudo apt autoremove -y
log_ok "Tool generici installati"

# ============================================================
log_step "Personalizzazione script launcher"
# ============================================================
echo '#######################################################################'
echo '#                       Customising scripts                           #'
echo '#######################################################################'

log_ok "Script pronti"

# ============================================================
echo ""
echo "══════════════════════════════════════════════════════"
echo -e "$OKGREEN  Installazione completata!$RESET"
echo "  Log salvato in: $LOG_FILE"
echo "══════════════════════════════════════════════════════"
echo ""
echo -e "$OKRED +----=[Si vis pacem, para bellum]=----+ $RESET"
echo ""
echo "NOTA: Eseguire 'source ~/.bashrc' o aprire un nuovo terminale"
echo "      per aggiornare il PATH con i tool pipx."
echo ""
read -rsp $'Premi INVIO per riavviare il sistema...\n'
sudo reboot now
