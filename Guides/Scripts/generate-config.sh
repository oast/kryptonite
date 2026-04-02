#!/bin/bash
# =============================================================================
# generate-config.sh – Génère un config.plist complet pour macOS Sequoia
# Configuration : ASUS Z97-C | i7-4790 | RX 580 | Fenvi T919 | AQC113
# SMBIOS : iMac18,1
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
    echo "Usage: $0 [chemin_EFI]"
    echo ""
    echo "Génère un config.plist complet à partir du Sample.plist d'OpenCore."
    echo ""
    echo "Arguments:"
    echo "  chemin_EFI   Chemin vers le dossier de travail (défaut: ./Hackintosh-EFI)"
    echo ""
    echo "Prérequis:"
    echo "  - python3 installé"
    echo "  - setup-efi.sh et setup-fenvi.sh déjà exécutés"
    exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

# --- Paramètres ---
WORK_DIR="${1:-./Hackintosh-EFI}"
EFI_DIR="${WORK_DIR}/EFI"
OC_DIR="${EFI_DIR}/OC"
CONFIG_PLIST="${OC_DIR}/config.plist"

# --- Vérifications ---
print_step "Vérification des prérequis"

if ! command -v python3 &>/dev/null; then
    print_error "python3 est requis mais non installé"
    exit 1
fi
print_info "python3 trouvé : $(python3 --version)"

if [ ! -f "${CONFIG_PLIST}" ]; then
    print_error "config.plist introuvable dans ${OC_DIR}"
    print_info "Exécutez d'abord : ./setup-efi.sh"
    exit 1
fi
print_success "Sample.plist trouvé (copié comme config.plist par setup-efi.sh)"

# --- Vérifier que les kexts existent ---
KEXTS_DIR="${OC_DIR}/Kexts"
REQUIRED_KEXTS=(
    "Lilu.kext"
    "VirtualSMC.kext"
    "SMCProcessor.kext"
    "SMCSuperIO.kext"
    "WhateverGreen.kext"
    "AppleALC.kext"
    "IntelMausi.kext"
    "AQtion.kext"
)

FENVI_KEXTS=(
    "AMFIPass.kext"
    "IOSkywalkFamily.kext"
    "IO80211FamilyLegacy.kext"
    "AirportBrcmFixup.kext"
    "BlueToolFixup.kext"
    "BrcmFirmwareData.kext"
    "BrcmPatchRAM3.kext"
)

missing_base=0
for kext in "${REQUIRED_KEXTS[@]}"; do
    if [ ! -d "${KEXTS_DIR}/${kext}" ]; then
        print_warning "Kext manquant : ${kext} (exécutez setup-efi.sh)"
        missing_base=1
    fi
done

missing_fenvi=0
for kext in "${FENVI_KEXTS[@]}"; do
    if [ ! -d "${KEXTS_DIR}/${kext}" ]; then
        print_warning "Kext Fenvi manquant : ${kext} (exécutez setup-fenvi.sh)"
        missing_fenvi=1
    fi
done

if [ "${missing_base}" -eq 1 ]; then
    print_error "Des kexts de base sont manquants. Exécutez setup-efi.sh d'abord."
    exit 1
fi

if [ "${missing_fenvi}" -eq 1 ]; then
    print_warning "Des kexts Fenvi sont manquants. Le config sera généré sans eux."
    print_info "Exécutez setup-fenvi.sh puis relancez ce script pour un config complet."
fi

# --- Générer le config.plist avec Python ---
print_step "Génération du config.plist"

python3 << PYTHON_EOF
import plistlib
import os
import sys

work_dir = '${WORK_DIR}'
oc_dir = os.path.join(work_dir, "EFI", "OC")
config_path = os.path.join(oc_dir, "config.plist")
kexts_dir = os.path.join(oc_dir, "Kexts")

# Lire le Sample.plist existant
with open(config_path, "rb") as f:
    config = plistlib.load(f)

# ============================================================
# ACPI
# ============================================================
config.setdefault("ACPI", {})
config["ACPI"].setdefault("Add", [])

acpi_entries = [
    {"Comment": "SSDT-PLUG pour gestion alimentation CPU", "Enabled": True, "Path": "SSDT-PLUG-DRTNIA.aml"},
    {"Comment": "SSDT-EC-USBX pour contrôleur embarqué et alimentation USB", "Enabled": True, "Path": "SSDT-EC-USBX-DESKTOP.aml"},
]

# Remplacer les entrées ACPI existantes
config["ACPI"]["Add"] = acpi_entries

# ============================================================
# Booter
# ============================================================
config.setdefault("Booter", {})
config["Booter"].setdefault("Quirks", {})

booter_quirks = {
    "AvoidRuntimeDefrag": True,
    "EnableSafeModeSlide": True,
    "EnableWriteUnprotector": True,
    "ProvideCustomSlide": True,
    "RebuildAppleMemoryMap": True,
    "SetupVirtualMap": True,
    "SyncRuntimePermissions": True,
}

for key, value in booter_quirks.items():
    config["Booter"]["Quirks"][key] = value

# ============================================================
# DeviceProperties
# ============================================================
config.setdefault("DeviceProperties", {})
config["DeviceProperties"].setdefault("Add", {})

# Audio ALC892 – layout-id 1
config["DeviceProperties"]["Add"]["PciRoot(0x0)/Pci(0x1B,0x0)"] = {
    "layout-id": b"\x01\x00\x00\x00",
}

# ============================================================
# Kernel
# ============================================================
config.setdefault("Kernel", {})

# --- Kernel > Add (15 kexts dans l'ordre) ---
kext_list = [
    ("Lilu.kext", "Framework de patches – doit être chargé en premier"),
    ("VirtualSMC.kext", "Émulation SMC Apple"),
    ("SMCProcessor.kext", "Monitoring processeur"),
    ("SMCSuperIO.kext", "Monitoring ventilateurs"),
    ("WhateverGreen.kext", "Patches GPU et framebuffer"),
    ("AppleALC.kext", "Audio Realtek ALC892"),
    ("IntelMausi.kext", "Ethernet Intel I218-V"),
    ("AQtion.kext", "Ethernet 10G Aquantia AQC113"),
    ("AMFIPass.kext", "Contourne AMFI pour OCLP"),
    ("IOSkywalkFamily.kext", "Remplacement IOSkywalk OCLP"),
    ("IO80211FamilyLegacy.kext", "Framework Wi-Fi legacy OCLP"),
    ("AirportBrcmFixup.kext", "Patches Wi-Fi Broadcom"),
    ("BlueToolFixup.kext", "Fix Bluetooth Monterey+"),
    ("BrcmFirmwareData.kext", "Firmware Bluetooth"),
    ("BrcmPatchRAM3.kext", "Patching Bluetooth RAM"),
]

kernel_add = []
for bundle_path, comment in kext_list:
    kext_path = os.path.join(kexts_dir, bundle_path)
    if not os.path.isdir(kext_path):
        continue

    # Lire le CFBundleIdentifier depuis Info.plist
    info_plist_path = os.path.join(kext_path, "Contents", "Info.plist")
    bundle_id = ""
    executable = ""
    if os.path.exists(info_plist_path):
        with open(info_plist_path, "rb") as f:
            info = plistlib.load(f)
            bundle_id = info.get("CFBundleIdentifier", "")
            executable = info.get("CFBundleExecutable", "")

    entry = {
        "Arch": "x86_64",
        "BundlePath": bundle_path,
        "Comment": comment,
        "Enabled": True,
        "ExecutablePath": f"Contents/MacOS/{executable}" if executable else "",
        "MaxKernel": "",
        "MinKernel": "",
        "PlistPath": "Contents/Info.plist",
    }
    kernel_add.append(entry)

config["Kernel"]["Add"] = kernel_add

# --- Kernel > Block ---
config["Kernel"]["Block"] = [
    {
        "Arch": "Any",
        "Comment": "Block IOSkywalkFamily pour OCLP Wi-Fi",
        "Enabled": True,
        "Identifier": "com.apple.iokit.IOSkywalkFamily",
        "MaxKernel": "",
        "MinKernel": "23.0.0",
        "Strategy": "Exclude",
    }
]

# --- Kernel > Quirks ---
config["Kernel"].setdefault("Quirks", {})
kernel_quirks = {
    "AppleCpuPmCfgLock": True,
    "AppleXcpmCfgLock": True,
    "DisableIoMapper": True,
    "DisableLinkeditJettison": True,
    "ForceAquantiaEthernet": True,
    "IgnoreInvalidFlexRatio": True,
    "PanicNoKextDump": True,
    "PowerTimeoutKernelPanic": True,
    "XhciPortLimit": False,
}

for key, value in kernel_quirks.items():
    config["Kernel"]["Quirks"][key] = value

# ============================================================
# Misc
# ============================================================
config.setdefault("Misc", {})

# Boot
config["Misc"].setdefault("Boot", {})
config["Misc"]["Boot"]["ShowPicker"] = True
config["Misc"]["Boot"]["Timeout"] = 5
config["Misc"]["Boot"]["PickerMode"] = "Builtin"

# Debug
config["Misc"].setdefault("Debug", {})
config["Misc"]["Debug"]["AppleDebug"] = True
config["Misc"]["Debug"]["DisableWatchDog"] = True
config["Misc"]["Debug"]["Target"] = 67

# Security
config["Misc"].setdefault("Security", {})
config["Misc"]["Security"]["AllowSetDefault"] = True
config["Misc"]["Security"]["SecureBootModel"] = "Disabled"
config["Misc"]["Security"]["ScanPolicy"] = 0
config["Misc"]["Security"]["Vault"] = "Optional"

# ============================================================
# NVRAM
# ============================================================
config.setdefault("NVRAM", {})
config["NVRAM"].setdefault("Add", {})

nvram_guid = "7C436110-AB2A-4BBB-A880-FE41995C9F82"
config["NVRAM"]["Add"].setdefault(nvram_guid, {})

config["NVRAM"]["Add"][nvram_guid]["boot-args"] = "-v keepsyms=1 debug=0x100 alcid=1 -amfipassbeta"
config["NVRAM"]["Add"][nvram_guid]["csr-active-config"] = b"\x03\x08\x00\x00"
config["NVRAM"]["Add"][nvram_guid]["prev-lang:kbd"] = "fr-FR:252"

# ============================================================
# PlatformInfo
# ============================================================
config.setdefault("PlatformInfo", {})
config["PlatformInfo"].setdefault("Generic", {})

config["PlatformInfo"]["Generic"]["SystemProductName"] = "iMac18,1"
config["PlatformInfo"]["Generic"]["MLB"] = "CHANGEME"
config["PlatformInfo"]["Generic"]["SystemSerialNumber"] = "CHANGEME"
config["PlatformInfo"]["Generic"]["SystemUUID"] = "CHANGEME"
config["PlatformInfo"]["Generic"]["ROM"] = b"\x00\x00\x00\x00\x00\x00"

config["PlatformInfo"]["Automatic"] = True
config["PlatformInfo"]["UpdateDataHub"] = True
config["PlatformInfo"]["UpdateNVRAM"] = True
config["PlatformInfo"]["UpdateSMBIOS"] = True
config["PlatformInfo"]["UpdateSMBIOSMode"] = "Create"

# ============================================================
# UEFI
# ============================================================
config.setdefault("UEFI", {})

# Drivers
drivers = [
    {"Arguments": "", "Comment": "Système de fichiers HFS+", "Enabled": True, "Path": "HfsPlus.efi"},
    {"Arguments": "", "Comment": "Runtime OpenCore", "Enabled": True, "Path": "OpenRuntime.efi"},
    {"Arguments": "", "Comment": "Reset NVRAM depuis le picker", "Enabled": True, "Path": "ResetNvramEntry.efi"},
]
config["UEFI"]["Drivers"] = drivers

# Quirks
config["UEFI"].setdefault("Quirks", {})
config["UEFI"]["Quirks"]["RequestBootVarRouting"] = True

# Sauvegarder
with open(config_path, "wb") as f:
    plistlib.dump(config, f, sort_keys=False)

print(f'Config.plist généré avec succès : {config_path}')
print(f'Kexts configurés : {len(kernel_add)}')
PYTHON_EOF

if [ $? -eq 0 ]; then
    print_success "config.plist généré avec succès"
else
    print_error "Échec de la génération du config.plist"
    exit 1
fi

# --- Rappels ---
print_step "Actions restantes"

echo ""
print_warning "IMPORTANT : Les valeurs SMBIOS doivent être personnalisées !"
echo ""
echo "  Ouvrez le config.plist dans ProperTree et remplacez les 'CHANGEME' :"
echo ""
echo "  PlatformInfo > Generic :"
echo "    - SystemSerialNumber  → Généré par GenSMBIOS (modèle iMac18,1)"
echo "    - MLB                 → Généré par GenSMBIOS"
echo "    - SystemUUID          → Généré par GenSMBIOS"
echo "    - ROM                 → Adresse MAC de votre carte Ethernet"
echo ""
echo "  Commande GenSMBIOS :"
echo "    git clone https://github.com/corpnewt/GenSMBIOS.git"
echo "    cd GenSMBIOS && python3 GenSMBIOS.command"
echo "    → Option 1 : Download MacSerial"
echo "    → Option 3 : Generate SMBIOS → iMac18,1"
echo ""
print_warning "Vérifiez que le numéro de série est INVALIDE sur checkcoverage.apple.com"
echo ""
print_success "Génération terminée ! Consultez le Guide 4 pour les détails."
