#!/bin/bash
# =============================================================================
# macrecovery-download.sh – Télécharge macOS Sequoia Recovery depuis Linux
# Utilise macrecovery.py d'OpenCorePkg pour télécharger BaseSystem.dmg
# Board-ID : Mac-4B682C642B45593E (iMac18,1)
# =============================================================================
set -euo pipefail

# --- Couleurs ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[ATTENTION]${NC} $1"; }
print_error()   { echo -e "${RED}[ERREUR]${NC} $1"; }
print_step()    { echo -e "\n${GREEN}==>${NC} $1"; }

# --- Aide ---
usage() {
    echo "Usage: $0 [répertoire_de_sortie]"
    echo ""
    echo "Télécharge macOS Sequoia Recovery (BaseSystem.dmg) depuis les serveurs Apple."
    echo "Utilise macrecovery.py d'OpenCorePkg."
    echo ""
    echo "Arguments:"
    echo "  répertoire_de_sortie   Répertoire où sauvegarder (défaut: ./macOS-Recovery)"
    echo ""
    echo "Prérequis:"
    echo "  - python3 installé"
    echo "  - Connexion Internet"
    exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

# --- Paramètres ---
OUTPUT_DIR="${1:-./macOS-Recovery}"
BOARD_ID="Mac-4B682C642B45593E"
MLB="00000000000000000"

echo ""
echo "=========================================="
echo "  macOS Sequoia Recovery – Téléchargement"
echo "=========================================="
echo ""

# --- Vérifier python3 ---
print_step "Vérification de python3"

if ! command -v python3 &>/dev/null; then
    print_error "python3 est requis mais non installé"
    echo ""
    echo "  Installation sur Ubuntu/Debian :"
    echo "    sudo apt install python3"
    echo ""
    echo "  Installation sur Fedora :"
    echo "    sudo dnf install python3"
    exit 1
fi

print_success "python3 trouvé : $(python3 --version)"

# --- Créer le répertoire de sortie ---
print_step "Préparation du répertoire de sortie"

mkdir -p "${OUTPUT_DIR}"
cd "${OUTPUT_DIR}"
print_info "Répertoire : $(pwd)"

# --- Télécharger macrecovery.py si absent ---
print_step "Vérification de macrecovery.py"

if [ ! -f "macrecovery.py" ]; then
    print_info "Téléchargement de macrecovery.py depuis OpenCorePkg..."

    MACRECOVERY_URL="https://raw.githubusercontent.com/acidanthera/OpenCorePkg/master/Utilities/macrecovery/macrecovery.py"

    if ! curl -qLs -o "macrecovery.py" "${MACRECOVERY_URL}"; then
        print_error "Impossible de télécharger macrecovery.py"
        print_info "Téléchargez manuellement depuis :"
        print_info "  https://github.com/acidanthera/OpenCorePkg/tree/master/Utilities/macrecovery"
        exit 1
    fi

    chmod +x macrecovery.py
    print_success "macrecovery.py téléchargé"
else
    print_success "macrecovery.py déjà présent"
fi

# --- Lancer le téléchargement ---
print_step "Téléchargement de macOS Sequoia Recovery"

print_info "Board-ID : ${BOARD_ID} (iMac18,1)"
print_info "Ce téléchargement fait environ 600 Mo"
print_info "Cela peut prendre plusieurs minutes selon votre connexion..."
echo ""

if ! python3 macrecovery.py -b "${BOARD_ID}" -m "${MLB}" download; then
    print_error "Le téléchargement a échoué"
    echo ""
    echo "  Causes possibles :"
    echo "    - Connexion Internet instable"
    echo "    - Serveurs Apple temporairement indisponibles"
    echo "    - Pare-feu bloquant les connexions Apple"
    echo ""
    echo "  Réessayez dans quelques minutes."
    exit 1
fi

# --- Vérifier le résultat ---
print_step "Vérification des fichiers téléchargés"

if [ -d "com.apple.recovery.boot" ]; then
    RECOVERY_DIR="com.apple.recovery.boot"
elif [ -f "BaseSystem.dmg" ]; then
    RECOVERY_DIR="."
else
    print_error "BaseSystem.dmg introuvable après le téléchargement"
    print_info "Le téléchargement a peut-être échoué silencieusement"
    exit 1
fi

if [ -f "${RECOVERY_DIR}/BaseSystem.dmg" ]; then
    DMG_SIZE=$(du -sh "${RECOVERY_DIR}/BaseSystem.dmg" | cut -f1)
    print_success "BaseSystem.dmg téléchargé (${DMG_SIZE})"
else
    print_error "BaseSystem.dmg introuvable"
    exit 1
fi

if [ -f "${RECOVERY_DIR}/BaseSystem.chunklist" ]; then
    print_success "BaseSystem.chunklist téléchargé"
else
    print_warning "BaseSystem.chunklist manquant (non critique)"
fi

# --- Résumé ---
print_step "Téléchargement terminé !"

echo ""
echo "  Fichiers dans : $(pwd)/${RECOVERY_DIR}/"
ls -lh "${RECOVERY_DIR}"/BaseSystem* 2>/dev/null || true
echo ""

print_info "Étapes suivantes :"
echo ""
echo "  1. Préparez la clé USB (Guide 2) :"
echo "     sudo gdisk /dev/sdX"
echo "     sudo mkfs.vfat -F 32 -n EFI /dev/sdX1"
echo ""
echo "  2. Copiez les fichiers recovery sur la clé :"
echo "     sudo mkdir -p /mnt/usb"
echo "     sudo mount /dev/sdX1 /mnt/usb"
echo "     sudo mkdir -p /mnt/usb/com.apple.recovery.boot"
echo "     sudo cp ${RECOVERY_DIR}/BaseSystem.dmg /mnt/usb/com.apple.recovery.boot/"
echo "     sudo cp ${RECOVERY_DIR}/BaseSystem.chunklist /mnt/usb/com.apple.recovery.boot/"
echo ""
echo "  3. Copiez le dossier EFI sur la clé (Guide 6) :"
echo "     sudo cp -R Hackintosh-EFI/EFI /mnt/usb/"
echo ""
echo "  4. Éjectez la clé :"
echo "     sudo umount /mnt/usb"
echo ""
print_warning "L'installation recovery nécessite une connexion Ethernet (~12 Go à télécharger)"
print_success "Consultez le Guide 2 pour la suite."
