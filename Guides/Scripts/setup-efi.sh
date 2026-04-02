#!/bin/bash
# =============================================================================
# setup-efi.sh — Construction automatique du dossier EFI OpenCore
# Cible : ASUS Z97-C + i7-4790 + RX 580 + Kalea AQC113
# Les kexts Fenvi T919 sont gérés séparément par setup-fenvi.sh
#
# Utilisation : chmod +x setup-efi.sh && ./setup-efi.sh [répertoire_de_travail]
# Par défaut : ./Hackintosh-EFI
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
    echo -e "${BOLD}Utilisation :${NC} $0 [répertoire_de_travail]"
    echo ""
    echo "  Construit un dossier EFI OpenCore complet pour Hackintosh."
    echo "  Par défaut le dossier de travail est ./Hackintosh-EFI"
    echo ""
    echo "  Matériel ciblé :"
    echo "    - Carte mère : ASUS Z97-C"
    echo "    - Processeur : Intel Core i7-4790 (Haswell)"
    echo "    - GPU : AMD Radeon RX 580"
    echo "    - Réseau 10G : Kalea Informatique AQC113"
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

# ---------------------------------------------------------------------------
# Détection du système hôte (macOS vs Linux)
# ---------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin)
            HOST_OS="macOS"
            # Sur macOS, vérifier si gtar est disponible (GNU tar via Homebrew)
            if command -v gtar &>/dev/null; then
                TAR_CMD="gtar"
            else
                TAR_CMD="tar"
            fi
            ;;
        Linux)
            HOST_OS="Linux"
            TAR_CMD="tar"
            ;;
        *)
            print_error "Système non pris en charge : $(uname -s)"
            exit 1
            ;;
    esac
    print_info "Système détecté : ${HOST_OS}"
}

# ---------------------------------------------------------------------------
# Vérification des dépendances
# ---------------------------------------------------------------------------
check_deps() {
    print_step "Vérification des dépendances..."
    local missing=()
    local deps=(curl unzip)

    for cmd in "${deps[@]}"; do
        if ! command -v "${cmd}" &>/dev/null; then
            missing+=("${cmd}")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Dépendances manquantes : ${missing[*]}"
        if [ "${HOST_OS}" = "Linux" ]; then
            print_info "Installation : sudo apt install ${missing[*]}"
        else
            print_info "Installation : brew install ${missing[*]}"
        fi
        exit 1
    fi

    print_success "Toutes les dépendances sont présentes (curl, unzip)"
}

# ---------------------------------------------------------------------------
# Création de l'arborescence EFI
# ---------------------------------------------------------------------------
create_efi_tree() {
    print_header "Étape 1/6 — Création de l'arborescence EFI"

    local dirs=(
        "EFI/BOOT"
        "EFI/OC/ACPI"
        "EFI/OC/Drivers"
        "EFI/OC/Kexts"
        "EFI/OC/Resources"
        "EFI/OC/Tools"
    )

    mkdir -p "${WORK_DIR}/Downloads"
    for d in "${dirs[@]}"; do
        mkdir -p "${WORK_DIR}/${d}"
    done

    print_success "Arborescence EFI créée dans ${WORK_DIR}"
}

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
# Téléchargement et installation d'OpenCore
# ---------------------------------------------------------------------------
setup_opencore() {
    print_header "Étape 2/6 — Téléchargement d'OpenCore (RELEASE)"

    local tmp_dir="${WORK_DIR}/Downloads/opencore"
    mkdir -p "${tmp_dir}"

    download_github_release "acidanthera/OpenCorePkg" "RELEASE" "${tmp_dir}" "OpenCore"

    # Recherche du répertoire X64 extrait
    local oc_x64
    oc_x64=$(find "${tmp_dir}" -type d -name "X64" | head -1)

    if [ -z "${oc_x64}" ]; then
        print_error "Répertoire X64 introuvable dans l'archive OpenCore"
        return 1
    fi

    # Copie des fichiers EFI essentiels
    cp "${oc_x64}/EFI/BOOT/BOOTx64.efi"            "${EFI_DIR}/BOOT/BOOTx64.efi"
    print_success "BOOTx64.efi copié"

    cp "${oc_x64}/EFI/OC/OpenCore.efi"              "${EFI_DIR}/OC/OpenCore.efi"
    print_success "OpenCore.efi copié"

    cp "${oc_x64}/EFI/OC/Drivers/OpenRuntime.efi"   "${EFI_DIR}/OC/Drivers/OpenRuntime.efi"
    print_success "OpenRuntime.efi copié"

    # Copie de ResetNvramEntry.efi (driver de réinitialisation NVRAM)
    local reset_efi
    reset_efi=$(find "${tmp_dir}" -name "ResetNvramEntry.efi" -path "*/X64/*" | head -1)
    if [ -n "${reset_efi}" ]; then
        cp "${reset_efi}" "${EFI_DIR}/OC/Drivers/ResetNvramEntry.efi"
        print_success "ResetNvramEntry.efi copié"
    else
        print_warning "ResetNvramEntry.efi introuvable — vérifiez manuellement"
    fi

    # Copie du Sample.plist comme base pour config.plist
    local sample_plist
    sample_plist=$(find "${tmp_dir}" -name "Sample.plist" | head -1)
    if [ -n "${sample_plist}" ]; then
        cp "${sample_plist}" "${EFI_DIR}/OC/config.plist"
        print_success "Sample.plist copié comme config.plist (à configurer)"
    else
        print_error "Sample.plist introuvable dans l'archive OpenCore"
        return 1
    fi

    # Copie d'ocvalidate si disponible (outil de validation)
    local ocvalidate
    ocvalidate=$(find "${tmp_dir}" -name "ocvalidate" -path "*/Utilities/*" | head -1)
    if [ -n "${ocvalidate}" ]; then
        cp "${ocvalidate}" "${WORK_DIR}/ocvalidate"
        chmod +x "${WORK_DIR}/ocvalidate"
        print_success "ocvalidate copié dans le dossier de travail"
    fi

    print_success "OpenCore installé"
}

# ---------------------------------------------------------------------------
# Téléchargement des 8 kexts de base
# Nota : les kexts Fenvi sont gérés par setup-fenvi.sh
# ---------------------------------------------------------------------------
download_base_kexts() {
    print_header "Étape 3/6 — Téléchargement des Kexts de base"

    local kexts_dir="${EFI_DIR}/OC/Kexts"
    local tmp_dir="${WORK_DIR}/Downloads/kexts"
    mkdir -p "${tmp_dir}"

    # --- 1. Lilu.kext (framework de base — chargé en premier) ---
    download_github_release "acidanthera/Lilu" "RELEASE" "${tmp_dir}" "Lilu"
    if [ -d "${tmp_dir}/Lilu.kext" ]; then
        cp -R "${tmp_dir}/Lilu.kext" "${kexts_dir}/"
        print_success "Lilu.kext installé"
    else
        print_error "Lilu.kext introuvable après extraction"
    fi
    rm -rf "${tmp_dir:?}/"*

    # --- 2. VirtualSMC + SMCProcessor + SMCSuperIO ---
    download_github_release "acidanthera/VirtualSMC" "RELEASE" "${tmp_dir}" "VirtualSMC"
    # Cherche le sous-dossier Kexts dans l'archive
    local vsmc_kexts
    vsmc_kexts=$(find "${tmp_dir}" -type d -name "Kexts" | head -1)
    if [ -n "${vsmc_kexts}" ]; then
        cp -R "${vsmc_kexts}/VirtualSMC.kext"    "${kexts_dir}/"
        cp -R "${vsmc_kexts}/SMCProcessor.kext"   "${kexts_dir}/"
        cp -R "${vsmc_kexts}/SMCSuperIO.kext"     "${kexts_dir}/"
    else
        # Structure alternative : kexts directement à la racine
        find "${tmp_dir}" -maxdepth 2 -name "VirtualSMC.kext"   -exec cp -R {} "${kexts_dir}/" \;
        find "${tmp_dir}" -maxdepth 2 -name "SMCProcessor.kext"  -exec cp -R {} "${kexts_dir}/" \;
        find "${tmp_dir}" -maxdepth 2 -name "SMCSuperIO.kext"    -exec cp -R {} "${kexts_dir}/" \;
    fi
    print_success "VirtualSMC + SMCProcessor + SMCSuperIO installés"
    rm -rf "${tmp_dir:?}/"*

    # --- 3. WhateverGreen.kext (gestion GPU RX 580) ---
    download_github_release "acidanthera/WhateverGreen" "RELEASE" "${tmp_dir}" "WhateverGreen"
    if [ -d "${tmp_dir}/WhateverGreen.kext" ]; then
        cp -R "${tmp_dir}/WhateverGreen.kext" "${kexts_dir}/"
        print_success "WhateverGreen.kext installé"
    else
        print_error "WhateverGreen.kext introuvable après extraction"
    fi
    rm -rf "${tmp_dir:?}/"*

    # --- 4. AppleALC.kext (audio ALC892, layout-id=1) ---
    download_github_release "acidanthera/AppleALC" "RELEASE" "${tmp_dir}" "AppleALC"
    if [ -d "${tmp_dir}/AppleALC.kext" ]; then
        cp -R "${tmp_dir}/AppleALC.kext" "${kexts_dir}/"
        print_success "AppleALC.kext installé"
    else
        print_error "AppleALC.kext introuvable après extraction"
    fi
    rm -rf "${tmp_dir:?}/"*

    # --- 5. IntelMausi.kext (Ethernet Intel I218-V intégré au Z97-C) ---
    download_github_release "acidanthera/IntelMausi" "RELEASE" "${tmp_dir}" "IntelMausi"
    if [ -d "${tmp_dir}/IntelMausi.kext" ]; then
        cp -R "${tmp_dir}/IntelMausi.kext" "${kexts_dir}/"
        print_success "IntelMausi.kext installé"
    else
        print_error "IntelMausi.kext introuvable après extraction"
    fi
    rm -rf "${tmp_dir:?}/"*

    # --- 6. AQtion.kext (réseau 10G Kalea AQC113) ---
    download_github_release "Mieze/AQtion" "RELEASE" "${tmp_dir}" "AQtion"
    local aqtion_kext
    aqtion_kext=$(find "${tmp_dir}" -name "AQtion.kext" -type d | head -1)
    if [ -n "${aqtion_kext}" ]; then
        cp -R "${aqtion_kext}" "${kexts_dir}/"
        print_success "AQtion.kext installé"
    else
        print_warning "AQtion.kext introuvable — téléchargement manuel peut être nécessaire"
    fi
    rm -rf "${tmp_dir:?}/"*

    rm -rf "${tmp_dir}"

    # Résumé des kexts installés
    print_info "Kexts installés :"
    ls -1 "${kexts_dir}/" 2>/dev/null | sed 's/^/    /'
}

# ---------------------------------------------------------------------------
# Téléchargement de HfsPlus.efi depuis OcBinaryData
# ---------------------------------------------------------------------------
download_hfsplus() {
    print_header "Étape 4/6 — Téléchargement de HfsPlus.efi"

    local url="https://raw.githubusercontent.com/acidanthera/OcBinaryData/master/Drivers/HfsPlus.efi"
    print_step "Téléchargement de HfsPlus.efi depuis OcBinaryData..."

    curl -qLs -o "${EFI_DIR}/OC/Drivers/HfsPlus.efi" "${url}"

    if [ -f "${EFI_DIR}/OC/Drivers/HfsPlus.efi" ]; then
        print_success "HfsPlus.efi téléchargé"
    else
        print_error "Échec du téléchargement de HfsPlus.efi"
        return 1
    fi

    # Résumé des drivers installés
    print_info "Drivers UEFI installés :"
    ls -1 "${EFI_DIR}/OC/Drivers/" 2>/dev/null | sed 's/^/    /'
}

# ---------------------------------------------------------------------------
# Téléchargement des SSDTs compilés depuis Dortania
# ---------------------------------------------------------------------------
download_ssdts() {
    print_header "Étape 5/6 — Téléchargement des tables ACPI (SSDTs)"

    local base_url="https://raw.githubusercontent.com/dortania/Getting-Started-With-ACPI/master/extra-files/compiled"

    # SSDT-PLUG pour la gestion de l'énergie CPU (Haswell)
    print_step "Téléchargement de SSDT-PLUG-DRTNIA.aml..."
    curl -qLs -o "${EFI_DIR}/OC/ACPI/SSDT-PLUG-DRTNIA.aml" \
        "${base_url}/SSDT-PLUG-DRTNIA.aml"

    if [ -f "${EFI_DIR}/OC/ACPI/SSDT-PLUG-DRTNIA.aml" ]; then
        print_success "SSDT-PLUG-DRTNIA.aml téléchargé"
    else
        print_error "Échec du téléchargement de SSDT-PLUG-DRTNIA.aml"
    fi

    # SSDT-EC-USBX pour le contrôleur embarqué et l'alimentation USB
    print_step "Téléchargement de SSDT-EC-USBX-DESKTOP.aml..."
    curl -qLs -o "${EFI_DIR}/OC/ACPI/SSDT-EC-USBX-DESKTOP.aml" \
        "${base_url}/SSDT-EC-USBX-DESKTOP.aml"

    if [ -f "${EFI_DIR}/OC/ACPI/SSDT-EC-USBX-DESKTOP.aml" ]; then
        print_success "SSDT-EC-USBX-DESKTOP.aml téléchargé"
    else
        print_error "Échec du téléchargement de SSDT-EC-USBX-DESKTOP.aml"
    fi

    # Résumé des tables ACPI
    print_info "Tables ACPI installées :"
    ls -1 "${EFI_DIR}/OC/ACPI/" 2>/dev/null | sed 's/^/    /'
}

# ---------------------------------------------------------------------------
# Vérification finale — affichage de l'arborescence complète
# ---------------------------------------------------------------------------
print_final_tree() {
    print_header "Étape 6/6 — Vérification de l'arborescence"

    if command -v tree &>/dev/null; then
        tree "${EFI_DIR}"
    else
        # Affichage alternatif si 'tree' n'est pas installé
        print_info "Contenu du dossier EFI :"
        find "${EFI_DIR}" -type f | sort | while read -r f; do
            echo -e "  ${GREEN}✓${NC} ${f#${WORK_DIR}/}"
        done
    fi

    echo ""
    print_success "Construction du dossier EFI terminée avec succès !"
    echo ""
    echo -e "${YELLOW}${BOLD}Prochaines étapes :${NC}"
    echo -e "  1. Exécutez ${BOLD}setup-fenvi.sh${NC} pour les kexts Wi-Fi/Bluetooth Fenvi T919"
    echo -e "  2. Exécutez ${BOLD}generate-config.sh${NC} pour configurer config.plist"
    echo -e "  3. Générez vos numéros de série avec ${BOLD}GenSMBIOS${NC} (modèle iMac18,1)"
    echo -e "  4. Copiez le dossier EFI sur la partition EFI de votre clé USB"
    echo ""
    echo -e "${BLUE}Dossier de travail : ${BOLD}${WORK_DIR}${NC}"
}

# =============================================================================
# Point d'entrée principal
# =============================================================================
main() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║  Construction du dossier EFI OpenCore (Hackintosh)  ║${NC}"
    echo -e "${BOLD}║  ASUS Z97-C | i7-4790 | RX 580 | Kalea AQC113      ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Dossier de travail : ${BOLD}${WORK_DIR}${NC}"
    echo ""

    detect_os
    check_deps
    create_efi_tree
    setup_opencore
    download_base_kexts
    download_hfsplus
    download_ssdts

    # Nettoyage des fichiers temporaires de téléchargement
    rm -rf "${WORK_DIR}/Downloads" 2>/dev/null || true

    print_final_tree
}

main "$@"
