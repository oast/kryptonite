---
title: "Guides d'installation – macOS Sequoia Tahoe sur ASUS Z97-C"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guides d'installation -- macOS Sequoia Tahoe sur ASUS Z97-C

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : derniere version stable

Serie de 9 guides pas-a-pas pour installer macOS Sequoia Tahoe via OpenCore sur un PC de bureau Intel Haswell (Z97). Chaque guide est autonome, illustre et adapte aux debutants.

---

## Configuration materielle

| Composant | Modele | Kext / Driver |
|-----------|--------|---------------|
| Carte mere | ASUS Z97-C (chipset Intel Z97) | -- |
| Processeur | Intel Core i7-4790 (Haswell, 4C/8T) | -- |
| GPU | AMD Radeon RX 580 8 Go (Polaris) | WhateverGreen.kext |
| Wi-Fi / Bluetooth | Fenvi T919 (Broadcom BCM4360CD) | OCLP patches (7 kexts) |
| Ethernet | Intel I218-V (integre) | IntelMausi.kext |
| Ethernet 10G | Kalea Informatique (Aquantia AQC113) | AQtion.kext + ForceAquantiaEthernet |
| Audio | Realtek ALC892 (integre) | AppleALC.kext (alcid=1) |
| RAM | 2x8 Go + 2x4 Go DDR3 (24 Go mixte) | -- |
| Stockage | SSD SATA (mode AHCI) | TRIM natif |
| SMBIOS | **iMac18,1** (Coffee Lake spoof) | -- |
| Bootloader | OpenCore (derniere version stable) | -- |

### Pourquoi iMac18,1 et pas iMac15,1 ?

iMac15,1 (SMBIOS natif Haswell) a ete abandonne dans macOS Ventura (13.0). Pour installer Sequoia, il faut utiliser **iMac18,1** (Coffee Lake). OpenCore fait croire a macOS que le Haswell est un Coffee Lake.

### Pourquoi OCLP ?

Apple a supprime le support du Wi-Fi Broadcom depuis macOS Sonoma (14.0). Le Fenvi T919 necessite des patches OCLP (OpenCore Legacy Patcher) pour fonctionner sous Sequoia. Les root patches doivent etre reappliquees apres chaque mise a jour macOS.

---

## Prerequis globaux

- Un Mac fonctionnel **OU** un PC sous Ubuntu 25.10+ (les deux workflows sont documentes)
- Une cle USB de 16 Go minimum (32 Go recommande)
- Connexion Internet stable
- Patience et rigueur dans le suivi des etapes

---

## Table des matieres

| # | Guide | Description |
|---|-------|-------------|
| 1 | [Telechargement de macOS Sequoia](Guide-01-Telechargement-macOS.md) | Verifier la compatibilite et telecharger macOS |
| 2 | [Creation de la cle USB bootable](Guide-02-Cle-USB-Bootable.md) | Formater et preparer le support d'installation |
| 3 | [Preparation du dossier EFI](Guide-03-Preparation-EFI.md) | Telecharger OpenCore, kexts, drivers et ACPI |
| 4 | [Config.plist complet](Guide-04-Config-Plist.md) | Configurer OpenCore pour votre materiel |
| 5 | [Wi-Fi / Bluetooth Fenvi T919](Guide-05-Fenvi-WiFi-Bluetooth.md) | Patchs OCLP pour Wi-Fi et Bluetooth |
| 6 | [Copie de l'EFI sur la cle USB](Guide-06-Copie-EFI-USB.md) | Monter et copier le dossier EFI |
| 7 | [BIOS + Installation macOS](Guide-07-BIOS-Installation.md) | Configurer le BIOS et installer macOS |
| 8 | [Post-installation et OCLP](Guide-08-Post-Installation.md) | Root patches, mappage USB, optimisations |
| 9 | [Maintenance et mises a jour](Guide-09-Maintenance-EFI.md) | Maintenir l'EFI, OpenCore et OCLP a jour |

---

## Scripts d'automatisation

Quatre scripts bash pour automatiser le processus :

| Script | Role | Commande |
|--------|------|----------|
| `setup-efi.sh` | Cree l'arborescence EFI + telecharge OpenCore et les 8 kexts de base | `./Scripts/setup-efi.sh` |
| `setup-fenvi.sh` | Telecharge les 7 kexts Fenvi/OCLP | `./Scripts/setup-fenvi.sh` |
| `generate-config.sh` | Genere un config.plist complet et pret a l'emploi | `./Scripts/generate-config.sh` |
| `macrecovery-download.sh` | Telecharge macOS Recovery depuis Linux | `./Scripts/macrecovery-download.sh` |

```bash
# Workflow complet automatise
cd Guides
chmod +x Scripts/*.sh
./Scripts/setup-efi.sh          # EFI de base
./Scripts/setup-fenvi.sh        # Kexts Fenvi
./Scripts/generate-config.sh    # Config.plist
```

---

## Liste complete des kexts (15 au total)

| # | Kext | Role | Source |
|---|------|------|--------|
| 1 | Lilu.kext | Framework de patches (DOIT etre charge en premier) | acidanthera/Lilu |
| 2 | VirtualSMC.kext | Emulation SMC Apple | acidanthera/VirtualSMC |
| 3 | SMCProcessor.kext | Monitoring CPU | acidanthera/VirtualSMC |
| 4 | SMCSuperIO.kext | Monitoring ventilateurs | acidanthera/VirtualSMC |
| 5 | WhateverGreen.kext | Patches GPU et framebuffer | acidanthera/WhateverGreen |
| 6 | AppleALC.kext | Audio Realtek ALC892 | acidanthera/AppleALC |
| 7 | IntelMausi.kext | Ethernet Intel I218-V | acidanthera/IntelMausi |
| 8 | AQtion.kext | Ethernet 10G Aquantia AQC113 | Mieze/AQtion |
| 9 | AMFIPass.kext | Bypass AMFI pour OCLP | dortania/OCLP |
| 10 | IOSkywalkFamily.kext | Remplacement IOSkywalk (OCLP) | dortania/OCLP |
| 11 | IO80211FamilyLegacy.kext | Framework Wi-Fi legacy | dortania/OCLP |
| 12 | AirportBrcmFixup.kext | Patches Wi-Fi Broadcom | acidanthera/AirportBrcmFixup |
| 13 | BlueToolFixup.kext | Fix Bluetooth Monterey+ | acidanthera/BrcmPatchRAM |
| 14 | BrcmFirmwareData.kext | Firmware Bluetooth | acidanthera/BrcmPatchRAM |
| 15 | BrcmPatchRAM3.kext | Patching Bluetooth RAM | acidanthera/BrcmPatchRAM |

---

## Conversion en PDF

Chaque guide inclut un en-tete YAML compatible avec pandoc :

```bash
# Convertir un guide en PDF
pandoc Guide-01-Telechargement-macOS.md -o Guide-01.pdf --pdf-engine=xelatex

# Convertir tous les guides
for f in Guide-*.md; do pandoc "$f" -o "${f%.md}.pdf" --pdf-engine=xelatex; done
```

---

## Ressources utiles

- [Dortania OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [Dortania Haswell Config](https://dortania.github.io/OpenCore-Install-Guide/config.plist/haswell.html)
- [OpenCore Releases](https://github.com/acidanthera/OpenCorePkg/releases)
- [OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher/releases)
- [ProperTree](https://github.com/corpnewt/ProperTree)
- [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS)
- [Hackintool](https://github.com/benbaker76/Hackintool)
- [USBToolBox](https://github.com/USBToolBox/tool)

---

## Licence

Ces guides sont fournis a titre educatif. macOS est une marque deposee d'Apple Inc.
