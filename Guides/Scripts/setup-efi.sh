#!/bin/bash

# setup-efi.sh
# Script d'automatisation pour créer l'arborescence EFI OpenCore
# Configuration : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia
#
# Usage : chmod +x setup-efi.sh && ./setup-efi.sh

set -euo pipefail

# --- Configuration ---

WORK_DIR="${1:-$(pwd)/Hackintosh-EFI}"
EFI_DIR="${WORK_DIR}/EFI"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Fonctions utilitaires ---

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}========================================${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Télécharger un fichier depuis GitHub releases (latest)
download_github_release() {
    local repo="$1"
    local filter="$2"
    local dest_dir="$3"
    local name="$4"

    print_step "Téléchargement de ${name}..."

    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local data
    data="$(curl -qLs "${api_url}")"

    if [ -z "${data}" ]; then
        print_error "Impossible de récupérer les métadonnées pour ${repo}"
        return 1
    fi

    local dwld_url
    dwld_url="$(echo "${data}" | grep '"browser_download_url":' | \
        grep "${filter}" | head -1 | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null)"

    if [ -z "${dwld_url}" ]; then
        print_error "Impossible de trouver l'URL de téléchargement pour ${name}"
        return 1
    fi

    local tmp_file="${dest_dir}/${name}.zip"

    curl -qLs -o "${tmp_file}" "${dwld_url}"
    if [ $? -ne 0 ]; then
        print_error "Échec du téléchargement de ${name}"
        return 1
    fi

    unzip -q -o -d "${dest_dir}" "${tmp_file}"
    rm -f "${tmp_file}"
    rm -rf "${dest_dir}/__MACOSX" 2>/dev/null

    print_info "${name} téléchargé avec succès"
    return 0
}

# --- Script principal ---

print_header "Setup EFI OpenCore - ASUS Z97-C + i7-4790 + RX 580"

echo -e "Ce script va :"
echo -e "  1. Créer l'arborescence EFI/OC"
echo -e "  2. Télécharger OpenCore (dernière version RELEASE)"
echo -e "  3. Télécharger les Kexts nécessaires"
echo -e "  4. Télécharger les Drivers UEFI"
echo -e "  5. Télécharger les tables ACPI pré-compilées"
echo -e ""
echo -e "Dossier de travail : ${BOLD}${WORK_DIR}${NC}"
echo ""
read -p "Continuer ? (o/N) " confirm
if [[ ! "${confirm}" =~ ^[oOyY]$ ]]; then
    echo "Abandon."
    exit 0
fi

# --- Étape 1 : Créer l'arborescence ---

print_header "Étape 1/5 – Création de l'arborescence EFI"

mkdir -p "${EFI_DIR}/BOOT"
mkdir -p "${EFI_DIR}/OC/ACPI"
mkdir -p "${EFI_DIR}/OC/Drivers"
mkdir -p "${EFI_DIR}/OC/Kexts"
mkdir -p "${EFI_DIR}/OC/Resources"
mkdir -p "${EFI_DIR}/OC/Tools"
mkdir -p "${WORK_DIR}/Downloads"

print_step "Arborescence créée :"
find "${EFI_DIR}" -type d | sed "s|${WORK_DIR}/||"

# --- Étape 2 : Télécharger OpenCore ---

print_header "Étape 2/5 – Téléchargement d'OpenCore"

download_github_release "acidanthera/OpenCorePkg" "RELEASE" "${WORK_DIR}/Downloads" "OpenCore"

# Copier les fichiers essentiels depuis l'archive OpenCore
if [ -d "${WORK_DIR}/Downloads/X64/EFI" ]; then
    cp "${WORK_DIR}/Downloads/X64/EFI/BOOT/BOOTx64.efi" "${EFI_DIR}/BOOT/"
    cp "${WORK_DIR}/Downloads/X64/EFI/OC/OpenCore.efi" "${EFI_DIR}/OC/"
    cp "${WORK_DIR}/Downloads/X64/EFI/OC/Drivers/OpenRuntime.efi" "${EFI_DIR}/OC/Drivers/"
    print_step "BOOTx64.efi, OpenCore.efi, OpenRuntime.efi copiés"

    # Copier le Sample.plist comme base pour le config.plist
    if [ -f "${WORK_DIR}/Downloads/Docs/Sample.plist" ]; then
        cp "${WORK_DIR}/Downloads/Docs/Sample.plist" "${EFI_DIR}/OC/config.plist"
        print_step "Sample.plist copié comme config.plist (à personnaliser)"
    fi

    # Copier ocvalidate si disponible
    if [ -f "${WORK_DIR}/Downloads/Utilities/ocvalidate/ocvalidate" ]; then
        cp "${WORK_DIR}/Downloads/Utilities/ocvalidate/ocvalidate" "${WORK_DIR}/"
        chmod +x "${WORK_DIR}/ocvalidate"
        print_step "ocvalidate copié dans le dossier de travail"
    fi
else
    print_warn "Structure OpenCore non trouvée dans Downloads/X64/EFI"
    print_warn "Vérifiez manuellement l'archive téléchargée"
fi

# --- Étape 3 : Télécharger les Kexts ---

print_header "Étape 3/5 – Téléchargement des Kexts"

KEXTS_TMP="${WORK_DIR}/Downloads/kexts-tmp"
mkdir -p "${KEXTS_TMP}"

# Lilu (framework de base – doit être chargé en premier)
download_github_release "acidanthera/Lilu" "RELEASE" "${KEXTS_TMP}" "Lilu"
[ -d "${KEXTS_TMP}/Lilu.kext" ] && cp -R "${KEXTS_TMP}/Lilu.kext" "${EFI_DIR}/OC/Kexts/"

# VirtualSMC + plugins
download_github_release "acidanthera/VirtualSMC" "RELEASE" "${KEXTS_TMP}" "VirtualSMC"
if [ -d "${KEXTS_TMP}/Kexts" ]; then
    for kext in VirtualSMC SMCProcessor SMCSuperIO; do
        [ -d "${KEXTS_TMP}/Kexts/${kext}.kext" ] && cp -R "${KEXTS_TMP}/Kexts/${kext}.kext" "${EFI_DIR}/OC/Kexts/"
    done
fi

# WhateverGreen (GPU)
download_github_release "acidanthera/WhateverGreen" "RELEASE" "${KEXTS_TMP}" "WhateverGreen"
[ -d "${KEXTS_TMP}/WhateverGreen.kext" ] && cp -R "${KEXTS_TMP}/WhateverGreen.kext" "${EFI_DIR}/OC/Kexts/"

# AppleALC (audio)
download_github_release "acidanthera/AppleALC" "RELEASE" "${KEXTS_TMP}" "AppleALC"
[ -d "${KEXTS_TMP}/AppleALC.kext" ] && cp -R "${KEXTS_TMP}/AppleALC.kext" "${EFI_DIR}/OC/Kexts/"

# IntelMausi (Ethernet Intel I218-V)
download_github_release "acidanthera/IntelMausi" "RELEASE" "${KEXTS_TMP}" "IntelMausi"
[ -d "${KEXTS_TMP}/IntelMausi.kext" ] && cp -R "${KEXTS_TMP}/IntelMausi.kext" "${EFI_DIR}/OC/Kexts/"

# Nettoyage des fichiers temporaires kexts
rm -rf "${KEXTS_TMP}"

print_step "Kexts installés :"
ls -1 "${EFI_DIR}/OC/Kexts/" 2>/dev/null | sed 's/^/  /'

# --- Étape 4 : Télécharger HfsPlus.efi ---

print_header "Étape 4/5 – Téléchargement des Drivers UEFI"

print_step "Téléchargement de HfsPlus.efi..."
curl -qLs -o "${EFI_DIR}/OC/Drivers/HfsPlus.efi" \
    "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi"

if [ -f "${EFI_DIR}/OC/Drivers/HfsPlus.efi" ]; then
    print_info "HfsPlus.efi téléchargé"
else
    print_error "Échec du téléchargement de HfsPlus.efi"
fi

print_step "Drivers installés :"
ls -1 "${EFI_DIR}/OC/Drivers/" 2>/dev/null | sed 's/^/  /'

# --- Étape 5 : Télécharger les tables ACPI ---

print_header "Étape 5/5 – Téléchargement des tables ACPI"

ACPI_BASE="https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled"

print_step "Téléchargement de SSDT-PLUG..."
curl -qLs -o "${EFI_DIR}/OC/ACPI/SSDT-PLUG.aml" \
    "${ACPI_BASE}/SSDT-PLUG-DRTNIA.aml"

print_step "Téléchargement de SSDT-EC-USBX (combiné)..."
curl -qLs -o "${EFI_DIR}/OC/ACPI/SSDT-EC-USBX.aml" \
    "${ACPI_BASE}/SSDT-EC-USBX-DESKTOP.aml"

print_step "Tables ACPI installées :"
ls -1 "${EFI_DIR}/OC/ACPI/" 2>/dev/null | sed 's/^/  /'

# --- Résumé ---

print_header "Terminé !"

echo -e "Arborescence EFI complète :"
echo ""
find "${EFI_DIR}" -type f | sort | sed "s|${WORK_DIR}/||" | while read -r f; do
    echo -e "  ${GREEN}✓${NC} ${f}"
done

echo ""
echo -e "${YELLOW}${BOLD}Prochaines étapes :${NC}"
echo -e "  1. Personnalisez ${BOLD}EFI/OC/config.plist${NC} avec ProperTree (voir Guide 5)"
echo -e "  2. Lancez ${BOLD}OC Snapshot${NC} dans ProperTree pour synchroniser les fichiers"
echo -e "  3. Générez le SMBIOS avec ${BOLD}GenSMBIOS${NC} (modèle : iMac15,1)"
echo -e "  4. Copiez l'EFI sur la partition EFI de votre clé USB (voir Guide 6)"
echo ""
echo -e "${BLUE}Dossier de travail : ${BOLD}${WORK_DIR}${NC}"

# Nettoyage des fichiers temporaires
rm -rf "${WORK_DIR}/Downloads" 2>/dev/null

echo ""
print_info "Script terminé. Consultez les Guides 5 et 6 pour la suite."
