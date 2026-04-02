---
title: "Guide 4 – Assemblage du dossier EFI"
author: "Projet Kryptonite"
date: "2026-04-01"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 4 – Assemblage du dossier EFI

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- Dossier EFI d'OpenCore préparé (voir [Guide 3](Guide-03-Preparation-OpenCore.md))
- Connexion Internet pour télécharger les composants

---

## Étape 1 – Téléchargement des Kexts

Téléchargez chaque kext depuis sa page de releases GitHub. Prenez toujours la version **RELEASE** (pas DEBUG).

### 1.1 – Lilu (framework de base)

```bash
# Lilu doit être chargé EN PREMIER – tous les autres kexts en dépendent
# Téléchargez depuis : https://github.com/acidanthera/Lilu/releases
cd ~/Desktop/Hackintosh-Sequoia
curl -LO "https://github.com/acidanthera/Lilu/releases/latest/download/Lilu-RELEASE.zip"
unzip Lilu-RELEASE.zip -d Lilu-temp
cp -R Lilu-temp/Lilu.kext EFI/OC/Kexts/
rm -rf Lilu-temp Lilu-RELEASE.zip
```

### 1.2 – VirtualSMC (émulation SMC + monitoring)

```bash
# Téléchargez depuis : https://github.com/acidanthera/VirtualSMC/releases
curl -LO "https://github.com/acidanthera/VirtualSMC/releases/latest/download/VirtualSMC-RELEASE.zip"
unzip VirtualSMC-RELEASE.zip -d VirtualSMC-temp

# Copier les kexts nécessaires
cp -R VirtualSMC-temp/Kexts/VirtualSMC.kext EFI/OC/Kexts/
cp -R VirtualSMC-temp/Kexts/SMCProcessor.kext EFI/OC/Kexts/
cp -R VirtualSMC-temp/Kexts/SMCSuperIO.kext EFI/OC/Kexts/

rm -rf VirtualSMC-temp VirtualSMC-RELEASE.zip
```

### 1.3 – WhateverGreen (patches GPU)

```bash
# Téléchargez depuis : https://github.com/acidanthera/WhateverGreen/releases
curl -LO "https://github.com/acidanthera/WhateverGreen/releases/latest/download/WhateverGreen-RELEASE.zip"
unzip WhateverGreen-RELEASE.zip -d WEG-temp
cp -R WEG-temp/WhateverGreen.kext EFI/OC/Kexts/
rm -rf WEG-temp WhateverGreen-RELEASE.zip
```

### 1.4 – AppleALC (audio Realtek ALC892)

```bash
# Téléchargez depuis : https://github.com/acidanthera/AppleALC/releases
curl -LO "https://github.com/acidanthera/AppleALC/releases/latest/download/AppleALC-RELEASE.zip"
unzip AppleALC-RELEASE.zip -d AppleALC-temp
cp -R AppleALC-temp/AppleALC.kext EFI/OC/Kexts/
rm -rf AppleALC-temp AppleALC-RELEASE.zip
```

### 1.5 – IntelMausi (Ethernet Intel I218-V)

```bash
# Téléchargez depuis : https://github.com/acidanthera/IntelMausi/releases
curl -LO "https://github.com/acidanthera/IntelMausi/releases/latest/download/IntelMausi-RELEASE.zip"
unzip IntelMausi-RELEASE.zip -d IntelMausi-temp
cp -R IntelMausi-temp/IntelMausi.kext EFI/OC/Kexts/
rm -rf IntelMausi-temp IntelMausi-RELEASE.zip
```

### 1.6 – AQC10G (réseau 10 Gigabit Aquantia)

```bash
# Téléchargez depuis : https://github.com/Mieze/AQtion/releases
# Note : le nom du kext peut varier selon la version
curl -LO "https://github.com/Mieze/AQtion/releases/latest/download/AQtion.zip"
unzip AQtion.zip -d AQtion-temp
cp -R AQtion-temp/*.kext EFI/OC/Kexts/
rm -rf AQtion-temp AQtion.zip
```

> ⚠️ **Ordre de chargement des Kexts** : Lilu doit être chargé avant tous les kexts qui en dépendent (VirtualSMC, WhateverGreen, AppleALC). Cet ordre sera configuré dans le `config.plist` (Guide 5).

---

## Étape 2 – Ajout des Drivers UEFI

### 2.1 – OpenRuntime.efi

Ce driver est déjà inclus dans l'archive OpenCore :

```bash
# Vérifier que OpenRuntime.efi est déjà en place
ls EFI/OC/Drivers/OpenRuntime.efi
```

S'il n'est pas présent, copiez-le depuis l'archive :

```bash
cp ~/Downloads/OpenCore-RELEASE/X64/EFI/OC/Drivers/OpenRuntime.efi EFI/OC/Drivers/
```

### 2.2 – HfsPlus.efi

Ce driver permet à OpenCore de lire les volumes HFS+ (nécessaire pour l'installateur macOS) :

```bash
# Téléchargez depuis OcBinaryData
curl -L "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi" \
    -o EFI/OC/Drivers/HfsPlus.efi
```

### Résultat dans le dossier Drivers/

```
EFI/OC/Drivers/
├── HfsPlus.efi
└── OpenRuntime.efi
```

> ⚠️ **Supprimez les drivers inutiles** s'il y en a d'autres dans le dossier. Seuls `OpenRuntime.efi` et `HfsPlus.efi` sont nécessaires.

---

## Étape 3 – Intégration des tables ACPI

Les tables SSDT permettent à macOS de comprendre correctement votre matériel. Pour Haswell + Z97, trois tables sont nécessaires.

### 3.1 – SSDT-PLUG.aml (gestion alimentation CPU)

Active la gestion d'alimentation native du processeur (XCPM) :

```bash
# Téléchargez les SSDT pré-compilés depuis Dortania
curl -L "https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-PLUG-DRTNIA.aml" \
    -o EFI/OC/ACPI/SSDT-PLUG.aml
```

### 3.2 – SSDT-EC.aml (contrôleur embarqué)

Crée un faux contrôleur embarqué, requis par macOS depuis Catalina :

```bash
curl -L "https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-EC-DESKTOP.aml" \
    -o EFI/OC/ACPI/SSDT-EC.aml
```

### 3.3 – SSDT-USBX.aml (alimentation USB)

Définit les propriétés d'alimentation USB (courant max pour les ports) :

> Ce SSDT est souvent inclus avec SSDT-EC dans le fichier `SSDT-EC-USBX-DESKTOP.aml` de Dortania. Si vous avez téléchargé la version combinée, un seul fichier suffit.

```bash
curl -L "https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-EC-USBX-DESKTOP.aml" \
    -o EFI/OC/ACPI/SSDT-EC-USBX.aml
```

> ⚠️ **Note** : Si vous utilisez `SSDT-EC-USBX-DESKTOP.aml` (combiné), vous pouvez supprimer `SSDT-EC.aml` séparé pour éviter les conflits. Utilisez l'un ou l'autre, pas les deux.

### Résultat dans le dossier ACPI/

```
EFI/OC/ACPI/
├── SSDT-PLUG.aml
└── SSDT-EC-USBX.aml
```

---

## Étape 4 – Vérification de l'arborescence complète

Vérifiez que votre dossier EFI est complet :

```bash
find EFI -type f | sort
```

Résultat attendu :

```
EFI/BOOT/BOOTx64.efi
EFI/OC/ACPI/SSDT-EC-USBX.aml
EFI/OC/ACPI/SSDT-PLUG.aml
EFI/OC/Drivers/HfsPlus.efi
EFI/OC/Drivers/OpenRuntime.efi
EFI/OC/Kexts/AppleALC.kext/Contents/...
EFI/OC/Kexts/IntelMausi.kext/Contents/...
EFI/OC/Kexts/Lilu.kext/Contents/...
EFI/OC/Kexts/SMCProcessor.kext/Contents/...
EFI/OC/Kexts/SMCSuperIO.kext/Contents/...
EFI/OC/Kexts/VirtualSMC.kext/Contents/...
EFI/OC/Kexts/WhateverGreen.kext/Contents/...
EFI/OC/Kexts/AQtion.kext/Contents/...
EFI/OC/OpenCore.efi
```

<!-- 📸 Capture d'écran : arborescence complète du dossier EFI dans le Finder -->

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] Tous les kexts sont dans `EFI/OC/Kexts/` (8 kexts)
- [ ] `OpenRuntime.efi` et `HfsPlus.efi` sont dans `EFI/OC/Drivers/`
- [ ] `SSDT-PLUG.aml` et `SSDT-EC-USBX.aml` sont dans `EFI/OC/ACPI/`
- [ ] `BOOTx64.efi` est dans `EFI/BOOT/`
- [ ] `OpenCore.efi` est dans `EFI/OC/`

---

## Dépannage

| Problème | Solution |
|----------|----------|
| `curl` échoue au téléchargement | Vérifiez votre connexion Internet ; essayez avec un navigateur |
| Le kext n'a pas l'extension `.kext` | Assurez-vous de copier le dossier complet (avec `Contents/`) |
| Fichier `.aml` illisible | C'est normal, les fichiers AML sont compilés (binaires) |
| Doute sur la version d'un kext | Vérifiez le `Info.plist` à l'intérieur du `.kext` |

---

## Étape suivante

→ [Guide 5 – Création et personnalisation du Config.plist](Guide-05-Config-Plist.md)
