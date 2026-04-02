---
title: "Guide 3 – Préparation et assemblage du dossier EFI"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 3 – Préparation et assemblage du dossier EFI

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## 3.1 Comprendre la structure EFI

Le dossier EFI est le **coeur** d'OpenCore. Il contient tout ce qui permet au Hackintosh de démarrer.

### Arborescence complète

```
EFI/
├── BOOT/
│   └── BOOTx64.efi              ← Chargeur UEFI générique
└── OC/
    ├── OpenCore.efi             ← Chargeur OpenCore principal
    ├── config.plist             ← Configuration complète
    ├── ACPI/
    │   ├── SSDT-PLUG-DRTNIA.aml ← Gestion de l'alimentation CPU
    │   └── SSDT-EC-USBX-DESKTOP.aml ← Contrôleur embarqué + USB
    ├── Drivers/
    │   ├── HfsPlus.efi          ← Lecture des partitions HFS+
    │   ├── OpenRuntime.efi      ← Runtime OpenCore (inclus)
    │   └── ResetNvramEntry.efi  ← Reset NVRAM depuis le menu (inclus)
    └── Kexts/
        ├── Lilu.kext            ← Framework de patches (requis en premier)
        ├── VirtualSMC.kext      ← Émulation SMC (requis)
        ├── SMCProcessor.kext    ← Monitoring CPU
        ├── SMCSuperIO.kext      ← Monitoring ventilateurs
        ├── WhateverGreen.kext   ← Patches GPU (stabilité RX 580)
        ├── AppleALC.kext        ← Audio (codec ALC892)
        ├── IntelMausi.kext      ← Ethernet Intel I218-V
        ├── AQtion.kext          ← Ethernet 10G Kalea AQC113
        ├── AMFIPass.kext        ← Contournement AMFI pour OCLP
        ├── IOSkywalkFamily.kext ← Framework réseau (OCLP/Fenvi)
        ├── IO80211FamilyLegacy.kext ← Wi-Fi legacy (OCLP/Fenvi)
        ├── AirportBrcmFixup.kext    ← Patches Wi-Fi Broadcom (Fenvi)
        ├── BlueToolFixup.kext       ← Patches Bluetooth (Fenvi)
        ├── BrcmFirmwareData.kext    ← Firmware Bluetooth Broadcom
        └── BrcmPatchRAM3.kext       ← Injection firmware BT
```

<!-- CAPTURE D'ÉCRAN : arborescence EFI dans le Finder ou terminal -->

### Rôle de chaque dossier

| Dossier | Contenu | Rôle |
|---------|---------|------|
| `BOOT/` | `BOOTx64.efi` | Point d'entrée UEFI. Le BIOS charge ce fichier en premier. |
| `OC/` | Tout le reste | Dossier principal d'OpenCore. |
| `OC/ACPI/` | Fichiers `.aml` | Tables ACPI personnalisées (SSDTs). |
| `OC/Drivers/` | Fichiers `.efi` | Pilotes UEFI chargés avant macOS. |
| `OC/Kexts/` | Dossiers `.kext` | Extensions noyau chargées par OpenCore. |

### Les 15 kexts et leur rôle

| # | Kext | Rôle | Source |
|---|------|------|--------|
| 1 | **Lilu** | Framework de patches noyau. Requis par la plupart des autres kexts. | [acidanthera/Lilu](https://github.com/acidanthera/Lilu/releases) |
| 2 | **VirtualSMC** | Émule la puce SMC Apple. Indispensable. | [acidanthera/VirtualSMC](https://github.com/acidanthera/VirtualSMC/releases) |
| 3 | **SMCProcessor** | Monitoring température/fréquence CPU. | Inclus dans VirtualSMC. |
| 4 | **SMCSuperIO** | Monitoring vitesse des ventilateurs. | Inclus dans VirtualSMC. |
| 5 | **WhateverGreen** | Patches GPU. Stabilité de la RX 580 (Polaris). | [acidanthera/WhateverGreen](https://github.com/acidanthera/WhateverGreen/releases) |
| 6 | **AppleALC** | Audio natif. Codec ALC892 via `alcid=1`. | [acidanthera/AppleALC](https://github.com/acidanthera/AppleALC/releases) |
| 7 | **IntelMausi** | Ethernet Intel I218-V (intégré à la carte mère). | [acidanthera/IntelMausi](https://github.com/acidanthera/IntelMausi/releases) |
| 8 | **AQtion** | Ethernet 10G pour la carte Kalea AQC113. | [Mieze/AQtion](https://github.com/Mieze/AQtion/releases) |
| 9 | **AMFIPass** | Contournement AMFI pour les patchs OCLP. | [dortania/OpenCore-Legacy-Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher) |
| 10 | **IOSkywalkFamily** | Framework réseau requis par OCLP pour le Wi-Fi. | Extrait via OCLP. |
| 11 | **IO80211FamilyLegacy** | Support Wi-Fi legacy pour cartes Broadcom (Fenvi). | Extrait via OCLP. |
| 12 | **AirportBrcmFixup** | Patches Wi-Fi Broadcom pour le Fenvi T919. | [acidanthera/AirportBrcmFixup](https://github.com/acidanthera/AirportBrcmFixup/releases) |
| 13 | **BlueToolFixup** | Patches Bluetooth pour le Fenvi T919. | [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM/releases) |
| 14 | **BrcmFirmwareData** | Données firmware Bluetooth Broadcom. | Inclus dans BrcmPatchRAM. |
| 15 | **BrcmPatchRAM3** | Injection du firmware Bluetooth au démarrage. | Inclus dans BrcmPatchRAM. |

> **Ordre de chargement** : Lilu doit toujours se charger **en premier**. VirtualSMC en second. Le reste n'a pas d'ordre strict.

---

## 3.2 Méthode automatisée (recommandée)

Trois scripts font tout le travail. Exécuter dans cet ordre.

### Étape 1 : Télécharger OpenCore et les kexts de base

```bash
./Scripts/setup-efi.sh
```

Ce script :
- Télécharge la dernière version stable d'OpenCore.
- Extrait `BOOTx64.efi`, `OpenCore.efi`, `OpenRuntime.efi`, `ResetNvramEntry.efi`.
- Télécharge `HfsPlus.efi` depuis OcBinaryData.
- Télécharge les SSDTs : `SSDT-PLUG-DRTNIA.aml`, `SSDT-EC-USBX-DESKTOP.aml`.
- Télécharge les kexts de base : Lilu, VirtualSMC (+ plugins), WhateverGreen, AppleALC, IntelMausi, AQtion, AMFIPass.
- Assemble le dossier `EFI/` complet.

<!-- CAPTURE D'ÉCRAN : exécution de setup-efi.sh -->

### Étape 2 : Ajouter les kexts Fenvi T919

```bash
./Scripts/setup-fenvi.sh
```

Ce script :
- Télécharge AirportBrcmFixup, BlueToolFixup, BrcmFirmwareData, BrcmPatchRAM3.
- Télécharge IOSkywalkFamily et IO80211FamilyLegacy (via OCLP).
- Copie tout dans `EFI/OC/Kexts/`.

### Étape 3 : Générer le config.plist

```bash
./Scripts/generate-config.sh
```

Ce script :
- Génère un `config.plist` adapté à notre configuration.
- Configure le SMBIOS **iMac18,1**.
- Définit les boot-args : `-v keepsyms=1 debug=0x100 alcid=1 -amfipassbeta`.
- Active le quirk `ForceAquantiaEthernet` pour l'AQC113.
- Place le fichier dans `EFI/OC/config.plist`.

<!-- CAPTURE D'ÉCRAN : exécution de generate-config.sh -->

---

## 3.3 Méthode manuelle (pour comprendre)

Pour ceux qui veulent comprendre chaque étape.

### Étape 1 : Créer l'arborescence

```bash
mkdir -p EFI/BOOT
mkdir -p EFI/OC/{ACPI,Drivers,Kexts}
```

### Étape 2 : Télécharger OpenCore

```bash
# Récupérer la dernière release stable
curl -L -o OpenCore.zip \
  "https://github.com/acidanthera/OpenCorePkg/releases/latest/download/OpenCore-1.0.4-RELEASE.zip"
unzip OpenCore.zip -d OpenCore-temp

# Copier les fichiers essentiels
cp OpenCore-temp/X64/EFI/BOOT/BOOTx64.efi EFI/BOOT/
cp OpenCore-temp/X64/EFI/OC/OpenCore.efi EFI/OC/
cp OpenCore-temp/X64/EFI/OC/Drivers/OpenRuntime.efi EFI/OC/Drivers/
cp OpenCore-temp/X64/EFI/OC/Drivers/ResetNvramEntry.efi EFI/OC/Drivers/

# Nettoyer
rm -rf OpenCore-temp OpenCore.zip
```

> **Note** : adapter le numéro de version (`1.0.4`) à la dernière release stable.

### Étape 3 : Télécharger HfsPlus.efi

```bash
curl -L -o EFI/OC/Drivers/HfsPlus.efi \
  "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi"
```

### Étape 4 : Télécharger les SSDTs

```bash
curl -L -o EFI/OC/ACPI/SSDT-PLUG-DRTNIA.aml \
  "https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PLUG-DRTNIA.aml"

curl -L -o EFI/OC/ACPI/SSDT-EC-USBX-DESKTOP.aml \
  "https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-EC-USBX-DESKTOP.aml"
```

### Étape 5 : Télécharger les kexts (base)

```bash
# Lilu (toujours en premier)
curl -L -o Lilu.zip \
  "https://github.com/acidanthera/Lilu/releases/latest/download/Lilu-1.7.4-RELEASE.zip"
unzip Lilu.zip -d EFI/OC/Kexts/ && rm Lilu.zip

# VirtualSMC (+ SMCProcessor + SMCSuperIO)
curl -L -o VirtualSMC.zip \
  "https://github.com/acidanthera/VirtualSMC/releases/latest/download/VirtualSMC-1.3.4-RELEASE.zip"
unzip VirtualSMC.zip -d VirtualSMC-temp
cp -R VirtualSMC-temp/Kexts/VirtualSMC.kext EFI/OC/Kexts/
cp -R VirtualSMC-temp/Kexts/SMCProcessor.kext EFI/OC/Kexts/
cp -R VirtualSMC-temp/Kexts/SMCSuperIO.kext EFI/OC/Kexts/
rm -rf VirtualSMC-temp VirtualSMC.zip

# WhateverGreen
curl -L -o WhateverGreen.zip \
  "https://github.com/acidanthera/WhateverGreen/releases/latest/download/WhateverGreen-1.6.8-RELEASE.zip"
unzip WhateverGreen.zip -d EFI/OC/Kexts/ && rm WhateverGreen.zip

# AppleALC
curl -L -o AppleALC.zip \
  "https://github.com/acidanthera/AppleALC/releases/latest/download/AppleALC-1.9.3-RELEASE.zip"
unzip AppleALC.zip -d EFI/OC/Kexts/ && rm AppleALC.zip

# IntelMausi
curl -L -o IntelMausi.zip \
  "https://github.com/acidanthera/IntelMausi/releases/latest/download/IntelMausi-1.0.8-RELEASE.zip"
unzip IntelMausi.zip -d EFI/OC/Kexts/ && rm IntelMausi.zip

# AQtion (Ethernet 10G AQC113)
curl -L -o AQtion.zip \
  "https://github.com/Mieze/AQtion/releases/latest/download/AQtion.zip"
unzip AQtion.zip -d EFI/OC/Kexts/ && rm AQtion.zip

# AMFIPass
curl -L -o AMFIPass.zip \
  "https://github.com/dortania/OpenCore-Legacy-Patcher/raw/main/payloads/Kexts/Acidanthera/AMFIPass-v1.4.1-RELEASE.zip"
unzip AMFIPass.zip -d EFI/OC/Kexts/ && rm AMFIPass.zip
```

> **Note** : adapter les numéros de version aux dernières releases disponibles.

### Étape 6 : Télécharger les kexts Fenvi T919

```bash
# AirportBrcmFixup
curl -L -o AirportBrcmFixup.zip \
  "https://github.com/acidanthera/AirportBrcmFixup/releases/latest/download/AirportBrcmFixup-2.1.9-RELEASE.zip"
unzip AirportBrcmFixup.zip -d EFI/OC/Kexts/ && rm AirportBrcmFixup.zip

# BrcmPatchRAM (inclut BlueToolFixup, BrcmFirmwareData, BrcmPatchRAM3)
curl -L -o BrcmPatchRAM.zip \
  "https://github.com/acidanthera/BrcmPatchRAM/releases/latest/download/BrcmPatchRAM-2.6.9-RELEASE.zip"
unzip BrcmPatchRAM.zip -d BrcmPatchRAM-temp
cp -R BrcmPatchRAM-temp/BlueToolFixup.kext EFI/OC/Kexts/
cp -R BrcmPatchRAM-temp/BrcmFirmwareData.kext EFI/OC/Kexts/
cp -R BrcmPatchRAM-temp/BrcmPatchRAM3.kext EFI/OC/Kexts/
rm -rf BrcmPatchRAM-temp BrcmPatchRAM.zip

# IOSkywalkFamily et IO80211FamilyLegacy
# Ces kexts sont extraits via OCLP. Voir le script setup-fenvi.sh ou Guide 5.
```

> **Important** : IOSkywalkFamily et IO80211FamilyLegacy proviennent d'OCLP. Utiliser le script `./Scripts/setup-fenvi.sh` ou suivre le **Guide 5** pour les obtenir.

---

## 3.4 Vérification de l'arborescence

Lancer cette commande pour vérifier que tout est en place :

```bash
find EFI -type f | sort
```

### Sortie attendue (complète)

```
EFI/BOOT/BOOTx64.efi
EFI/OC/ACPI/SSDT-EC-USBX-DESKTOP.aml
EFI/OC/ACPI/SSDT-PLUG-DRTNIA.aml
EFI/OC/Drivers/HfsPlus.efi
EFI/OC/Drivers/OpenRuntime.efi
EFI/OC/Drivers/ResetNvramEntry.efi
EFI/OC/Kexts/AMFIPass.kext/...
EFI/OC/Kexts/AQtion.kext/...
EFI/OC/Kexts/AirportBrcmFixup.kext/...
EFI/OC/Kexts/AppleALC.kext/...
EFI/OC/Kexts/BlueToolFixup.kext/...
EFI/OC/Kexts/BrcmFirmwareData.kext/...
EFI/OC/Kexts/BrcmPatchRAM3.kext/...
EFI/OC/Kexts/IO80211FamilyLegacy.kext/...
EFI/OC/Kexts/IOSkywalkFamily.kext/...
EFI/OC/Kexts/IntelMausi.kext/...
EFI/OC/Kexts/Lilu.kext/...
EFI/OC/Kexts/SMCProcessor.kext/...
EFI/OC/Kexts/SMCSuperIO.kext/...
EFI/OC/Kexts/VirtualSMC.kext/...
EFI/OC/Kexts/WhateverGreen.kext/...
EFI/OC/OpenCore.efi
EFI/OC/config.plist
```

### Comptage rapide

| Catégorie | Nombre attendu | Fichiers |
|-----------|---------------|----------|
| **BOOT** | 1 | BOOTx64.efi |
| **OpenCore** | 1 | OpenCore.efi |
| **config.plist** | 1 | config.plist |
| **Drivers** | 3 | HfsPlus, OpenRuntime, ResetNvramEntry |
| **SSDTs** | 2 | SSDT-PLUG-DRTNIA, SSDT-EC-USBX-DESKTOP |
| **Kexts** | 15 | Voir tableau section 3.1 |
| **Total fichiers clés** | **23** | |

```bash
# Compter les kexts
ls -d EFI/OC/Kexts/*.kext | wc -l
# Résultat attendu : 15
```

---

## Checklist de vérification

Avant de passer au Guide 4, vérifiez chaque point :

- [ ] `EFI/BOOT/BOOTx64.efi` existe
- [ ] `EFI/OC/OpenCore.efi` existe
- [ ] **3 drivers** dans `EFI/OC/Drivers/` : HfsPlus, OpenRuntime, ResetNvramEntry
- [ ] **2 SSDTs** dans `EFI/OC/ACPI/` : SSDT-PLUG-DRTNIA, SSDT-EC-USBX-DESKTOP
- [ ] **15 kexts** dans `EFI/OC/Kexts/` (vérifier avec `ls -d EFI/OC/Kexts/*.kext | wc -l`)
- [ ] Lilu.kext est bien présent (les autres kexts en dépendent)
- [ ] VirtualSMC.kext est bien présent (indispensable au boot)
- [ ] AQtion.kext est bien présent (pour l'Ethernet 10G AQC113)
- [ ] Les kexts Fenvi sont bien présents (6 kexts Wi-Fi/BT)
- [ ] `config.plist` sera généré/configuré dans le Guide suivant

---

## Dépannage

| Problème | Cause probable | Solution |
|----------|---------------|----------|
| `curl` erreur 404 | URL de release changée | Vérifier la dernière version sur la page GitHub du projet |
| `unzip` erreur | Archive corrompue | Retélécharger le fichier |
| Kext manquant après extraction | Mauvais dossier de destination | Vérifier le chemin de destination dans la commande `cp` |
| `setup-efi.sh` permission denied | Script non exécutable | `chmod +x ./Scripts/setup-efi.sh` |
| IOSkywalkFamily introuvable | Pas disponible en téléchargement direct | Utiliser `./Scripts/setup-fenvi.sh` ou OCLP (Guide 5) |
| 14 kexts au lieu de 15 | Un kext oublié | Comparer avec le tableau de la section 3.1 un par un |

---

## Rappel des boot-args

Pour référence (sera configuré dans le config.plist) :

```
-v keepsyms=1 debug=0x100 alcid=1 -amfipassbeta
```

| Argument | Rôle |
|----------|------|
| `-v` | Mode verbose (affiche les logs au boot) |
| `keepsyms=1` | Conserve les symboles pour le débogage |
| `debug=0x100` | Empêche le reboot automatique en cas de kernel panic |
| `alcid=1` | Layout audio pour AppleALC (codec ALC892) |
| `-amfipassbeta` | Active AMFIPass pour les patchs OCLP |

> **Rappel** : pas de `agdpmod=pikera`. La RX 580 (Polaris) n'en a pas besoin. Ce flag est réservé aux GPU **Navi** (RX 5000/6000/7000).

---

## Étape suivante

Le dossier EFI est assemblé. Direction le **[Guide 4 – Configuration du config.plist](Guide-05-Config-Plist.md)** pour configurer OpenCore.
