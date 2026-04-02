---
title: "Guide 6 – Montage et copie de l'EFI sur la clé USB"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 6 – Montage et copie de l'EFI sur la clé USB

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## Prérequis

- Clé USB d'installation prête (voir [Guide 2](Guide-02-Cle-USB-Bootable.md))
- Dossier EFI complet avec config.plist (voir [Guide 5](Guide-05-Config-Plist.md))

---

## 6.1 Identifier la partition EFI de la clé USB

Chaque disque formaté en GPT possède une partition EFI cachée (ESP). C'est là qu'on copie le dossier EFI.

### Sur macOS

1. Ouvrez le Terminal.
2. Listez les disques :

```bash
diskutil list
```

3. Repérez la partition EFI de votre clé USB :

```
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *16.0 GB    disk2
   1:                        EFI EFI                     209.7 MB   disk2s1
   2:                  Apple_HFS Install macOS Sequoia   15.7 GB    disk2s2
```

- La partition EFI est **disk2s1** dans cet exemple.
- Votre numéro de disque peut varier (`disk3s1`, `disk4s1`...).

> **Astuce** : repérez la taille totale du disque pour identifier votre clé USB.

### Sur Linux

1. Ouvrez un terminal.
2. Listez les disques :

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
```

3. Repérez votre clé USB (ex. `sdb`).
4. La partition EFI est la **première partition** : `sdb1`.

```
NAME   SIZE TYPE MOUNTPOINT FSTYPE
sdb   14.9G disk
├─sdb1  200M part          vfat       ← Partition EFI
└─sdb2 14.7G part          hfsplus
```

---

## 6.2 Monter la partition EFI

### Sur macOS — Méthode Terminal (recommandée)

```bash
# Remplacez disk2s1 par VOTRE identifiant
sudo diskutil mount disk2s1
# Résultat : "Volume EFI on disk2s1 mounted"
# Montée dans /Volumes/EFI/
```

### Sur macOS — Méthode MountEFI (alternative graphique)

```bash
git clone https://github.com/corpnewt/MountEFI.git
python3 MountEFI/MountEFI.command
```

- Sélectionnez votre clé USB dans la liste.
- La partition EFI sera montée automatiquement.

### Sur Linux

```bash
sudo mkdir -p /mnt/efi
sudo mount /dev/sdX1 /mnt/efi
# Remplacez sdX1 par VOTRE identifiant (ex. sdb1)
```

### Vérification du montage

```bash
# macOS
ls /Volumes/EFI/

# Linux
ls /mnt/efi/
```

- Vous devriez voir un dossier vide ou un ancien dossier `EFI`.

---

## 6.3 Copier le dossier EFI

### Sur macOS

1. Supprimez l'ancien dossier EFI (si présent) :

```bash
# UNIQUEMENT sur la partition EFI de la clé USB
rm -rf /Volumes/EFI/EFI
```

2. Copiez le nouveau dossier EFI :

```bash
cp -R ~/Desktop/Hackintosh-EFI/EFI /Volumes/EFI/
```

3. Vérification rapide :

```bash
ls -la /Volumes/EFI/EFI/
```

Résultat attendu :

```
drwxr-xr-x  BOOT
drwxr-xr-x  OC
```

### Sur Linux

1. Supprimez l'ancien dossier EFI (si présent) :

```bash
sudo rm -rf /mnt/efi/EFI
```

2. Copiez le nouveau dossier EFI :

```bash
sudo cp -R Hackintosh-EFI/EFI /mnt/efi/
```

3. Vérification rapide :

```bash
ls -la /mnt/efi/EFI/
```

---

## 6.4 Vérifier la structure

Lancez la commande `find` pour lister tous les fichiers copiés.

### Sur macOS

```bash
find /Volumes/EFI/EFI -type f | sort
```

### Sur Linux

```bash
find /mnt/efi/EFI -type f | sort
```

### Arborescence attendue (tous les fichiers)

```
EFI/BOOT/BOOTx64.efi
EFI/OC/ACPI/SSDT-EC-USBX.aml
EFI/OC/ACPI/SSDT-PLUG.aml
EFI/OC/Drivers/HfsPlus.efi
EFI/OC/Drivers/OpenRuntime.efi
EFI/OC/Kexts/AMFIPass.kext/Contents/...
EFI/OC/Kexts/AQtion.kext/Contents/...
EFI/OC/Kexts/AirportBrcmFixup.kext/Contents/...
EFI/OC/Kexts/AppleALC.kext/Contents/...
EFI/OC/Kexts/BlueToolFixup.kext/Contents/...
EFI/OC/Kexts/BrcmFirmwareData.kext/Contents/...
EFI/OC/Kexts/BrcmPatchRAM3.kext/Contents/...
EFI/OC/Kexts/IO80211FamilyLegacy.kext/Contents/...
EFI/OC/Kexts/IOSkywalkFamily.kext/Contents/...
EFI/OC/Kexts/IntelMausi.kext/Contents/...
EFI/OC/Kexts/Lilu.kext/Contents/...
EFI/OC/Kexts/SMCProcessor.kext/Contents/...
EFI/OC/Kexts/SMCSuperIO.kext/Contents/...
EFI/OC/Kexts/VirtualSMC.kext/Contents/...
EFI/OC/Kexts/WhateverGreen.kext/Contents/...
EFI/OC/OpenCore.efi
EFI/OC/config.plist
```

### Checklist rapide

| Element | Attendu | Commande de vérif |
|---------|---------|-------------------|
| `config.plist` | Présent dans `EFI/OC/` | `ls EFI/OC/config.plist` |
| Kexts | **15 kexts** | `ls EFI/OC/Kexts/ \| wc -l` |
| Drivers | 2 fichiers `.efi` | `ls EFI/OC/Drivers/` |
| ACPI | 2 fichiers `.aml` | `ls EFI/OC/ACPI/` |
| BOOTx64.efi | Présent dans `EFI/BOOT/` | `ls EFI/BOOT/BOOTx64.efi` |

> **15 kexts attendus** : Lilu, VirtualSMC, SMCProcessor, SMCSuperIO, WhateverGreen, AppleALC, IntelMausi, AQtion, AMFIPass, IOSkywalkFamily, IO80211FamilyLegacy, AirportBrcmFixup, BlueToolFixup, BrcmFirmwareData, BrcmPatchRAM3.

---

## 6.5 Validation avec ocvalidate

L'outil `ocvalidate` verifie que le config.plist ne contient aucune erreur.

### Sur macOS

```bash
# Depuis le dossier OpenCore telecharge
~/Downloads/OpenCore-RELEASE/Utilities/ocvalidate/ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

### Sur Linux

```bash
# Rendez l'outil executable si necessaire
chmod +x ~/OpenCore-RELEASE/Utilities/ocvalidate/ocvalidate
~/OpenCore-RELEASE/Utilities/ocvalidate/ocvalidate /mnt/efi/EFI/OC/config.plist
```

### Resultat attendu

```
Completed validating EFI/OC/config.plist in 0 ms. No issues found.
```

- **Aucune erreur** = vous pouvez continuer.
- **Des erreurs apparaissent** = corrigez-les dans le config.plist avant de booter.

> **Astuce** : si `ocvalidate` signale des warnings sur les kexts OCLP (AMFIPass, IOSkywalkFamily...), c'est normal. Seules les **erreurs** sont bloquantes.

---

## 6.6 Ejecter proprement

### Sur macOS

```bash
# Demonter la partition EFI
sudo diskutil unmount disk2s1

# Ejecter la cle USB
diskutil eject disk2
```

### Sur Linux

```bash
sudo umount /mnt/efi
# Optionnel : ejecter physiquement
sudo eject /dev/sdX
```

> **Ne jamais arracher la cle USB** sans la demonter. Cela peut corrompre le dossier EFI et rendre la cle non bootable.

---

## Checklist de verification

Avant de passer au Guide 7, verifiez :

- [ ] La partition EFI de la cle USB est identifiee et montee
- [ ] Le dossier EFI est copie dans la racine de la partition EFI
- [ ] L'arborescence contient : `BOOT/`, `OC/`, `config.plist`, 15 kexts, 2 drivers, 2 ACPI
- [ ] `ocvalidate` ne signale aucune erreur
- [ ] Le `config.plist` est present et valide
- [ ] La cle USB est ejected proprement

---

## Depannage

| Probleme | Cause probable | Solution |
|----------|---------------|----------|
| `diskutil mount` echoue | Mauvais identifiant de disque | Relancez `diskutil list` et verifiez le numero |
| `/Volumes/EFI/` est vide | Normal a la premiere utilisation | Copiez simplement le dossier EFI dedans |
| Erreur « Not enough space » | Partition EFI trop petite | L'EFI OpenCore fait ~50 Mo. La partition EFI standard fait 200 Mo. Suffisant. |
| `ocvalidate` signale des erreurs | Probleme dans le config.plist | Relisez le [Guide 5](Guide-05-Config-Plist.md) et corrigez les valeurs |
| Plusieurs partitions EFI montees | Confusion entre disque interne et USB | Verifiez que vous copiez sur la partition de la **cle USB**, pas du disque interne |
| `find` ne montre pas 15 kexts | Kexts manquants | Retournez au [Guide 4](Guide-04-Config-Plist.md) et verifiez l'assemblage |
| Permission denied (Linux) | Droits insuffisants | Utilisez `sudo` pour monter et copier |

---

## Etape suivante

→ [Guide 7 – Configuration BIOS et installation de macOS Sequoia](Guide-07-BIOS-Installation.md)
