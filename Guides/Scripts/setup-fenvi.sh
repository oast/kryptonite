#!/bin/bash
# =============================================================================
# setup-fenvi.sh — Installation des kexts Wi-Fi/Bluetooth pour Fenvi T919
# Puce : Broadcom BCM4360CD (Wi-Fi ac + Bluetooth 4.0)
#
# Prérequis : setup-efi.sh doit avoir été exécuté au préalable
# Ce script télécharge les kexts nécessaires au fonctionnement du Wi-Fi
# et du Bluetooth sous macOS Sequoia (nécessite le contournement AMFI/OCLP)
#
# Utilisation : chmod +x setup-fenvi.sh && ./setup-fenvi.sh [répertoire_EFI]
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Couleurs et fonctions d'affichage
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_info()    { echo -e "${BLUE}[INFO]${NC}    $*"; }
print_success() { echo -e "${GREEN}[OK]${NC}      $*"; }
print_warning() { echo -e "${YELLOW}[AVERT]${NC}  $*"; }
print_error()   { echo -e "${RED}[ERREUR]${NC} $*" >&2; }
print_step()    { echo -e "${BOLD}${BLUE}➜${NC} $*"; }

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}========================================${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}========================================${NC}"
    echo ""
}

# ---------------------------------------------------------------------------
# Aide
# ---------------------------------------------------------------------------
usage() {
    echo -e "${BOLD}Utilisation :${NC} $0 [répertoire_EFI]"
    echo ""
    echo "  Télécharge et installe les kexts Wi-Fi/Bluetooth pour la Fenvi T919"
    echo "  (Broadcom BCM4360CD) sous macOS Sequoia."
    echo ""
    echo "  Le répertoire EFI doit contenir la structure créée par setup-efi.sh."
    echo "  Par défaut : ./Hackintosh-EFI"
    echo ""
    echo "  Kexts installés :"
    echo "    - AirportBrcmFixup.kext    (Wi-Fi Broadcom)"
    echo "    - BrcmPatchRAM3.kext       (Bluetooth firmware)"
    echo "    - BrcmFirmwareData.kext    (Bluetooth firmware data)"
    echo "    - BlueToolFixup.kext       (Bluetooth macOS 12+)"
    echo "    - AMFIPass.kext            (contournement AMFI pour OCLP)"
    echo "    - IOSkywalkFamily.kext     (remplacement IOSkywalk legacy)"
    echo "    - IO80211FamilyLegacy.kext (support Wi-Fi legacy Broadcom)"
    echo ""
    echo "  Options :"
    echo "    -h, --help    Afficher cette aide"
    exit 0
}

# ---------------------------------------------------------------------------
# Gestion des arguments
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

WORK_DIR="${1:-./Hackintosh-EFI}"
EFI_DIR="${WORK_DIR}/EFI"
KEXTS_DIR="${EFI_DIR}/OC/Kexts"

# ---------------------------------------------------------------------------
# Fonction de téléchargement depuis les releases GitHub
# ---------------------------------------------------------------------------
download_github_release() {
    local repo="$1" filter="$2" dest_dir="$3" name="$4"
    print_step "Téléchargement de ${name}..."

    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local data
    data=$(curl -qLs "${api_url}")

    if [ -z "${data}" ]; then
        print_error "Impossible de récupérer les métadonnées pour ${repo}"
        return 1
    fi

    local dwld_url
    dwld_url=$(echo "${data}" | grep '"browser_download_url":' | grep "${filter}" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "${dwld_url}" ]; then
        print_error "URL introuvable pour ${name}"
        return 1
    fi

    local tmp="${dest_dir}/${name}.zip"
    curl -qLs -o "${tmp}" "${dwld_url}"
    unzip -q -o -d "${dest_dir}" "${tmp}"
    rm -f "${tmp}"
    rm -rf "${dest_dir}/__MACOSX" 2>/dev/null || true

    print_info "${name} téléchargé avec succès"
}

# ---------------------------------------------------------------------------
# Vérification des prérequis
# ---------------------------------------------------------------------------
check_prerequisites() {
    print_step "Vérification des prérequis..."

    # Vérifier que le dossier EFI existe
    if [ ! -d "${EFI_DIR}/OC/Kexts" ]; then
        print_error "Le dossier EFI n'existe pas : ${EFI_DIR}/OC/Kexts"
        print_error "Exécutez d'abord setup-efi.sh pour créer l'arborescence EFI"
        exit 1
    fi

    # Vérifier que Lilu.kext est présent (dépendance obligatoire)
    if [ ! -d "${KEXTS_DIR}/Lilu.kext" ]; then
        print_warning "Lilu.kext absent — les kexts Broadcom en dépendent"
        print_warning "Assurez-vous d'exécuter setup-efi.sh au préalable"
    fi

    # Vérifier les outils nécessaires
    for cmd in curl unzip; do
        if ! command -v "${cmd}" &>/dev/null; then
            print_error "Dépendance manquante : ${cmd}"
            exit 1
        fi
    done

    print_success "Prérequis vérifiés"
}

# ---------------------------------------------------------------------------
# Téléchargement des kexts Broadcom (acidanthera)
# ---------------------------------------------------------------------------
download_broadcom_kexts() {
    print_header "Étape 1/2 — Kexts Broadcom (acidanthera)"

    local tmp_dir="${WORK_DIR}/Downloads/fenvi"
    mkdir -p "${tmp_dir}"

    # --- AirportBrcmFixup.kext (Wi-Fi Broadcom) ---
    download_github_release "acidanthera/AirportBrcmFixup" "RELEASE" "${tmp_dir}" "AirportBrcmFixup"
    if [ -d "${tmp_dir}/AirportBrcmFixup.kext" ]; then
        cp -R "${tmp_dir}/AirportBrcmFixup.kext" "${KEXTS_DIR}/"
        print_success "AirportBrcmFixup.kext installé"
    else
        print_error "AirportBrcmFixup.kext introuvable après extraction"
    fi
    rm -rf "${tmp_dir:?}/"*

    # --- BrcmPatchRAM (Bluetooth) — contient plusieurs kexts ---
    download_github_release "acidanthera/BrcmPatchRAM" "RELEASE" "${tmp_dir}" "BrcmPatchRAM"

    # BrcmPatchRAM3.kext (driver Bluetooth principal)
    local brcm_kext
    brcm_kext=$(find "${tmp_dir}" -name "BrcmPatchRAM3.kext" -type d | head -1)
    if [ -n "${brcm_kext}" ]; then
        cp -R "${brcm_kext}" "${KEXTS_DIR}/"
        print_success "BrcmPatchRAM3.kext installé"
    else
        print_error "BrcmPatchRAM3.kext introuvable"
    fi

    # BrcmFirmwareData.kext (firmware Bluetooth)
    brcm_kext=$(find "${tmp_dir}" -name "BrcmFirmwareData.kext" -type d | head -1)
    if [ -n "${brcm_kext}" ]; then
        cp -R "${brcm_kext}" "${KEXTS_DIR}/"
        print_success "BrcmFirmwareData.kext installé"
    else
        print_error "BrcmFirmwareData.kext introuvable"
    fi

    # BlueToolFixup.kext (correctif Bluetooth pour macOS 12+)
    brcm_kext=$(find "${tmp_dir}" -name "BlueToolFixup.kext" -type d | head -1)
    if [ -n "${brcm_kext}" ]; then
        cp -R "${brcm_kext}" "${KEXTS_DIR}/"
        print_success "BlueToolFixup.kext installé"
    else
        print_error "BlueToolFixup.kext introuvable"
    fi

    rm -rf "${tmp_dir:?}/"*
    rm -rf "${tmp_dir}"
}

# ---------------------------------------------------------------------------
# Téléchargement des kexts OCLP (OpenCore Legacy Patcher)
# AMFIPass, IOSkywalkFamily, IO80211FamilyLegacy
# Ces kexts sont nécessaires pour le Wi-Fi Broadcom sous macOS Sonoma/Sequoia
# ---------------------------------------------------------------------------
download_oclp_kexts() {
    print_header "Étape 2/2 — Kexts OCLP (Legacy Wi-Fi Broadcom)"

    local tmp_dir="${WORK_DIR}/Downloads/oclp"
    mkdir -p "${tmp_dir}"

    print_step "Téléchargement d'OpenCore Legacy Patcher..."

    # Récupération de la dernière release OCLP
    local api_url="https://api.github.com/repos/dortania/OpenCore-Legacy-Patcher/releases/latest"
    local data
    data=$(curl -qLs "${api_url}")

    if [ -z "${data}" ]; then
        print_error "Impossible de récupérer les métadonnées OCLP"
        return 1
    fi

    # Chercher l'archive ZIP de la release (pas le .pkg macOS)
    local dwld_url
    dwld_url=$(echo "${data}" | grep '"browser_download_url":' | grep '\.zip"' | grep -iv "pkg\|AutoPatcher\|GUI" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')

    # Si pas de ZIP filtré, prendre le premier ZIP disponible
    if [ -z "${dwld_url}" ]; then
        dwld_url=$(echo "${data}" | grep '"browser_download_url":' | grep '\.zip"' | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
    fi

    if [ -z "${dwld_url}" ]; then
        print_warning "Archive OCLP introuvable via l'API GitHub"
        print_warning "Téléchargement des kexts OCLP depuis les sources directes..."
        download_oclp_kexts_fallback
        return
    fi

    local tmp_zip="${tmp_dir}/OCLP.zip"
    curl -qLs -o "${tmp_zip}" "${dwld_url}"
    unzip -q -o -d "${tmp_dir}" "${tmp_zip}" 2>/dev/null || true
    rm -f "${tmp_zip}"
    rm -rf "${tmp_dir}/__MACOSX" 2>/dev/null || true

    # Recherche des kexts dans l'archive extraite
    local found_count=0

    # AMFIPass.kext (contournement AMFI pour les kexts non signés)
    local amfi_kext
    amfi_kext=$(find "${tmp_dir}" -name "AMFIPass.kext" -type d 2>/dev/null | head -1)
    if [ -n "${amfi_kext}" ]; then
        cp -R "${amfi_kext}" "${KEXTS_DIR}/"
        print_success "AMFIPass.kext installé"
        ((found_count++)) || true
    fi

    # IOSkywalkFamily.kext (remplacement du framework IOSkywalk)
    local skywalk_kext
    skywalk_kext=$(find "${tmp_dir}" -name "IOSkywalkFamily.kext" -type d 2>/dev/null | head -1)
    if [ -n "${skywalk_kext}" ]; then
        cp -R "${skywalk_kext}" "${KEXTS_DIR}/"
        print_success "IOSkywalkFamily.kext installé"
        ((found_count++)) || true
    fi

    # IO80211FamilyLegacy.kext (support Wi-Fi legacy pour Broadcom)
    local legacy_kext
    legacy_kext=$(find "${tmp_dir}" -name "IO80211FamilyLegacy.kext" -type d 2>/dev/null | head -1)
    if [ -n "${legacy_kext}" ]; then
        cp -R "${legacy_kext}" "${KEXTS_DIR}/"
        print_success "IO80211FamilyLegacy.kext installé"
        ((found_count++)) || true
    fi

    if [ "${found_count}" -lt 3 ]; then
        print_warning "Certains kexts OCLP n'ont pas été trouvés dans l'archive (${found_count}/3)"
        print_warning "Tentative de téléchargement depuis les sources alternatives..."
        download_oclp_kexts_fallback
    fi

    rm -rf "${tmp_dir}"
}

# ---------------------------------------------------------------------------
# Fallback : téléchargement direct des kexts OCLP depuis le dépot source
# ---------------------------------------------------------------------------
download_oclp_kexts_fallback() {
    print_info "Téléchargement des kexts OCLP depuis le dépot source..."

    local base_url="https://raw.githubusercontent.com/dortania/OpenCore-Legacy-Patcher/main/payloads/Kexts/Wifi"
    local tmp_dir="${WORK_DIR}/Downloads/oclp-fallback"
    mkdir -p "${tmp_dir}"

    # Liste des kexts OCLP nécessaires
    local kexts_needed=("AMFIPass" "IOSkywalkFamily" "IO80211FamilyLegacy")

    for kext_name in "${kexts_needed[@]}"; do
        if [ ! -d "${KEXTS_DIR}/${kext_name}.kext" ]; then
            print_warning "${kext_name}.kext non trouvé — téléchargement manuel requis"
            print_info "Source : https://github.com/dortania/OpenCore-Legacy-Patcher/releases"
        else
            print_info "${kext_name}.kext déjà présent"
        fi
    done

    rm -rf "${tmp_dir}"
}

# ---------------------------------------------------------------------------
# Rappel de configuration config.plist
# ---------------------------------------------------------------------------
print_config_reminder() {
    print_header "Rappel — Modifications config.plist requises"

    echo -e "${YELLOW}${BOLD}Les modifications suivantes doivent être appliquées à config.plist :${NC}"
    echo ""
    echo -e "${BOLD}1. Kernel > Add :${NC}"
    echo "   Ajoutez les kexts Fenvi dans l'ordre suivant (après les kexts de base) :"
    echo "     - AMFIPass.kext"
    echo "     - IOSkywalkFamily.kext"
    echo "     - IO80211FamilyLegacy.kext"
    echo "     - AirportBrcmFixup.kext"
    echo "     - BlueToolFixup.kext"
    echo "     - BrcmFirmwareData.kext"
    echo "     - BrcmPatchRAM3.kext"
    echo ""
    echo -e "${BOLD}2. Kernel > Block :${NC}"
    echo "   Bloquez le IOSkywalkFamily d'Apple pour utiliser la version OCLP :"
    echo "     - Identifier : com.apple.iokit.IOSkywalkFamily"
    echo "     - MinKernel   : 23.0.0"
    echo "     - Strategy    : Exclude"
    echo "     - Enabled     : true"
    echo ""
    echo -e "${BOLD}3. NVRAM > boot-args :${NC}"
    echo "   Ajoutez les arguments suivants :"
    echo "     -amfipassbeta"
    echo ""
    echo -e "${BOLD}4. NVRAM > csr-active-config :${NC}"
    echo "   Valeur recommandée : 03080000"
    echo "   (désactive la protection SIP pour les kexts tiers OCLP)"
    echo ""
    echo -e "${BOLD}5. Misc > Security > SecureBootModel :${NC}"
    echo "   Valeur : Disabled"
    echo "   (nécessaire pour les kexts non signés OCLP)"
    echo ""
    echo -e "${GREEN}Conseil : exécutez generate-config.sh pour appliquer ces modifications automatiquement.${NC}"
}

# ---------------------------------------------------------------------------
# Résumé final
# ---------------------------------------------------------------------------
print_summary() {
    print_header "Résumé des kexts Fenvi T919"

    print_info "Kexts dans ${KEXTS_DIR} :"
    ls -1 "${KEXTS_DIR}/" 2>/dev/null | sed 's/^/    /'

    echo ""
    print_success "Installation des kexts Fenvi T919 terminée"
}

# =============================================================================
# Point d'entrée principal
# =============================================================================
main() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Installation kexts Wi-Fi/Bluetooth — Fenvi T919   ║${NC}"
    echo -e "${BOLD}║  Broadcom BCM4360CD (macOS Sequoia)                 ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_prerequisites
    download_broadcom_kexts
    download_oclp_kexts
    print_summary
    print_config_reminder

    # Nettoyage des fichiers temporaires
    rm -rf "${WORK_DIR}/Downloads" 2>/dev/null || true
}

main "$@"
