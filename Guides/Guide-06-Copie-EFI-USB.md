# Guide 6 – Montage et copie de l'EFI sur la clé USB

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- Clé USB d'installation prête (voir [Guide 2](Guide-02-Cle-USB-Bootable.md))
- Dossier EFI complet avec config.plist (voir [Guide 5](Guide-05-Config-Plist.md))

---

## Étape 1 – Identifier la partition EFI de la clé USB

Chaque disque formaté en GPT possède une partition EFI cachée (aussi appelée ESP – EFI System Partition). C'est là que nous devons copier notre dossier EFI.

1. Identifiez votre clé USB :

```bash
diskutil list
```

2. Repérez la partition EFI de votre clé USB :

```
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *16.0 GB    disk2
   1:                        EFI EFI                     209.7 MB   disk2s1
   2:                  Apple_HFS Install macOS Sequoia   15.7 GB    disk2s2
```

La partition EFI est `disk2s1` dans cet exemple.

<!-- 📸 Capture d'écran : sortie diskutil list montrant la partition EFI -->

---

## Étape 2 – Monter la partition EFI

### Méthode A – Via le Terminal (recommandée)

```bash
# Remplacez disk2s1 par l'identifiant de VOTRE partition EFI
sudo diskutil mount disk2s1
```

La partition sera montée dans `/Volumes/EFI/`.

### Méthode B – Via MountEFI (outil graphique)

1. Téléchargez [MountEFI](https://github.com/corpnewt/MountEFI) :

```bash
git clone https://github.com/corpnewt/MountEFI.git
python3 MountEFI/MountEFI.command
```

2. Sélectionnez votre clé USB dans la liste
3. La partition EFI sera montée automatiquement

<!-- 📸 Capture d'écran : MountEFI avec la liste des disques -->

### Vérification du montage

```bash
# Vérifiez que la partition est montée
ls /Volumes/EFI/
```

Vous devriez voir un dossier vide ou contenant un dossier `EFI` existant.

---

## Étape 3 – Copier le dossier EFI

1. Si un ancien dossier EFI existe sur la partition, supprimez-le d'abord :

```bash
# Attention : ne faites cela QUE sur la partition EFI de la clé USB
rm -rf /Volumes/EFI/EFI
```

2. Copiez votre dossier EFI complet :

```bash
cp -R ~/Desktop/Hackintosh-Sequoia/EFI /Volumes/EFI/
```

3. Vérifiez la copie :

```bash
ls -la /Volumes/EFI/EFI/
```

Résultat attendu :

```
drwxr-xr-x  BOOT
drwxr-xr-x  OC
```

---

## Étape 4 – Vérifier l'arborescence

Effectuez une vérification complète de l'arborescence copiée :

```bash
find /Volumes/EFI/EFI -type f | sort
```

Vous devez retrouver exactement les fichiers assemblés dans le Guide 4 :

```
/Volumes/EFI/EFI/BOOT/BOOTx64.efi
/Volumes/EFI/EFI/OC/ACPI/SSDT-EC-USBX.aml
/Volumes/EFI/EFI/OC/ACPI/SSDT-PLUG.aml
/Volumes/EFI/EFI/OC/Drivers/HfsPlus.efi
/Volumes/EFI/EFI/OC/Drivers/OpenRuntime.efi
/Volumes/EFI/EFI/OC/Kexts/AppleALC.kext/Contents/...
/Volumes/EFI/EFI/OC/Kexts/IntelMausi.kext/Contents/...
/Volumes/EFI/EFI/OC/Kexts/Lilu.kext/Contents/...
/Volumes/EFI/EFI/OC/Kexts/SMCProcessor.kext/Contents/...
/Volumes/EFI/EFI/OC/Kexts/SMCSuperIO.kext/Contents/...
/Volumes/EFI/EFI/OC/Kexts/VirtualSMC.kext/Contents/...
/Volumes/EFI/EFI/OC/Kexts/WhateverGreen.kext/Contents/...
/Volumes/EFI/EFI/OC/Kexts/AQtion.kext/Contents/...
/Volumes/EFI/EFI/OC/OpenCore.efi
/Volumes/EFI/EFI/OC/config.plist
```

---

## Étape 5 – Validation avec OpenCore Sanity Checker

L'outil en ligne **OpenCore Sanity Checker** vérifie votre config.plist pour détecter les erreurs courantes.

1. Rendez-vous sur **https://opencore.slowgeek.com/**

2. Glissez-déposez votre fichier `config.plist` sur la page

3. Sélectionnez votre version d'OpenCore et la plateforme **Haswell Desktop**

4. Examinez les résultats :
   - **Vert** : configuration correcte
   - **Jaune** : avertissement (à vérifier)
   - **Rouge** : erreur à corriger

<!-- 📸 Capture d'écran : résultats du Sanity Checker avec les sections vertes -->

> ⚠️ **Corrigez toutes les erreurs rouges** avant de tenter le boot. Les avertissements jaunes sont généralement acceptables pour une première installation.

### Alternative : ocvalidate

L'outil `ocvalidate` est inclus dans l'archive OpenCore :

```bash
# Valider le config.plist avec ocvalidate
~/Downloads/OpenCore-RELEASE/Utilities/ocvalidate/ocvalidate EFI/OC/config.plist
```

---

## Étape 6 – Éjecter proprement la clé USB

```bash
# Démontez la partition EFI
sudo diskutil unmount disk2s1

# Éjectez la clé USB proprement
diskutil eject disk2
```

> ⚠️ **N'arrachez jamais la clé USB** sans l'éjecter proprement. Cela pourrait corrompre le dossier EFI.

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] La partition EFI de la clé USB est montée et accessible
- [ ] Le dossier EFI complet est copié dans `/Volumes/EFI/`
- [ ] L'arborescence contient tous les fichiers (BOOT, OC, config.plist)
- [ ] Le Sanity Checker ou ocvalidate ne signale aucune erreur rouge
- [ ] La clé USB est éjectée proprement

---

## Dépannage

| Problème | Solution |
|----------|----------|
| `diskutil mount` échoue | Vérifiez l'identifiant avec `diskutil list` ; utilisez `sudo` |
| `/Volumes/EFI/` est vide après montage | C'est normal si c'est la première fois – la partition EFI est vide par défaut |
| Erreur de copie « Not enough space » | La partition EFI fait 200 Mo, l'EFI OpenCore ne devrait pas dépasser 50 Mo |
| Sanity Checker signale des erreurs | Consultez le guide Dortania Haswell pour les valeurs correctes |
| Plusieurs partitions EFI sont montées | Vérifiez que vous copiez sur la partition de la **clé USB**, pas du disque interne |

---

## Étape suivante

→ [Guide 7 – Installation de macOS Sequoia](Guide-07-Installation-macOS.md)
