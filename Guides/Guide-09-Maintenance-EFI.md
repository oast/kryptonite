---
title: "Guide 9 – Maintenance, mises à jour et sauvegarde de l'EFI"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 9 – Maintenance, mises à jour et sauvegarde de l'EFI

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## 9.1 Sauvegarder votre EFI AVANT toute modification

> **RÈGLE D'OR** : Ne modifiez JAMAIS votre EFI sans sauvegarde fonctionnelle.

### Créer une sauvegarde

```bash
# Monter la partition EFI
sudo diskutil mount disk0s1

# Créer le dossier de sauvegardes
mkdir -p ~/Desktop/EFI-Backups

# Sauvegarder avec la date du jour
cp -R /Volumes/EFI/EFI ~/Desktop/EFI-Backups/EFI-$(date +%Y-%m-%d)
```

### Stratégie de sauvegarde

| Quand sauvegarder | Pourquoi |
|-------------------|----------|
| Avant toute modification du config.plist | Retour arrière possible en cas de no-boot |
| Avant une mise à jour macOS | L'EFI peut devenir incompatible |
| Avant une mise à jour d'OpenCore | Même raison |
| Après une configuration stable et fonctionnelle | Point de restauration fiable |

### Clé USB de secours

**Gardez TOUJOURS une clé USB avec un EFI fonctionnel.** En cas de problème, vous pourrez booter depuis la clé pour réparer l'EFI du disque interne.

```bash
# Copier l'EFI actuel sur la clé USB de secours
sudo diskutil mount disk2s1    # Partition EFI de la clé USB
sudo cp -R /Volumes/EFI/EFI /Volumes/EFI\ 1/
sudo diskutil unmount disk2s1
```

---

## 9.2 Mettre à jour OpenCore

### Vérifier la version actuelle

```bash
nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version
```

### Procédure de mise à jour

1. **Téléchargez** la nouvelle version depuis https://github.com/acidanthera/OpenCorePkg/releases

2. **Mettez à jour fichier par fichier** (ne remplacez PAS tout le dossier EFI) :
   - `EFI/BOOT/BOOTx64.efi`
   - `EFI/OC/OpenCore.efi`
   - `EFI/OC/Drivers/OpenRuntime.efi`

3. **Mettez à jour le config.plist** :
   - Lisez `Differences.pdf` dans l'archive OpenCore (liste les changements)
   - Comparez votre config avec le nouveau `Sample.plist`
   - Ajoutez les nouvelles clés manquantes
   - Exécutez OC Snapshot dans ProperTree (Cmd+R / Ctrl+R)

4. **Validez** :
   ```bash
   # Téléchargez ocvalidate depuis l'archive OpenCore (dossier Utilities)
   ./ocvalidate EFI/OC/config.plist
   ```

> **Ne sautez pas d'étape.** Un config.plist incompatible avec la nouvelle version d'OpenCore peut empêcher le boot.

---

## 9.3 Mettre à jour les kexts

### Vérifier les versions actuelles

```bash
for kext in /Volumes/EFI/EFI/OC/Kexts/*.kext; do
    version=$(defaults read "$kext/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "N/A")
    echo "$(basename $kext): $version"
done
```

### Ordre de mise à jour

1. **Lilu.kext en premier** — c'est le framework dont dépendent VirtualSMC, WhateverGreen, AppleALC, etc.
2. Ensuite les autres kexts dans n'importe quel ordre
3. Exécutez OC Snapshot dans ProperTree après la mise à jour

### Sources des kexts

| Kext | Source |
|------|--------|
| Lilu, VirtualSMC, WhateverGreen, AppleALC, IntelMausi | github.com/acidanthera |
| AQtion | github.com/Mieze/AQtion |
| AirportBrcmFixup, BrcmPatchRAM | github.com/acidanthera |
| AMFIPass, IOSkywalkFamily, IO80211FamilyLegacy | github.com/dortania/OpenCore-Legacy-Patcher |

---

## 9.4 Mises à jour macOS – PROCÉDURE CRITIQUE

### Avant la mise à jour

1. **Sauvegarder l'EFI** (section 9.1)
2. **Vérifier la compatibilité** sur les forums :
   - r/hackintosh
   - InsanelyMac
   - Dortania Discord
3. **Mettre à jour OpenCore** à la dernière version (section 9.2)
4. **Mettre à jour tous les kexts** (section 9.3)
5. **Préparer la clé USB de secours** avec l'EFI actuel fonctionnel

### Installer la mise à jour

- Réglages Système → Général → Mise à jour logicielle
- Ou : `softwareupdate --list` puis `softwareupdate --install`

### APRÈS la mise à jour (OBLIGATOIRE)

> **Les root patches OCLP sont effacées par chaque mise à jour macOS.**

1. macOS redémarre normalement
2. **Le Wi-Fi Fenvi ne fonctionne plus** — c'est attendu
3. Ouvrir **OCLP** → **Post-Install Root Patch**
4. Laisser les patches s'installer (2-5 min)
5. **Redémarrer**
6. Le Wi-Fi est rétabli

### Types de mises à jour

| Type | Exemple | Risque | Recommandation |
|------|---------|--------|----------------|
| Mise à jour de sécurité | 15.1 → 15.1.1 | Faible | Généralement sûr, appliquer |
| Mise à jour mineure | 15.1 → 15.2 | Moyen | Attendre 48h les retours communauté |
| Mise à jour majeure | 15.x → 16.x | Élevé | Attendre les retours, tester sur USB d'abord |

---

## 9.5 Retirer le mode verbose (quand stable)

Une fois le système stable pendant **1-2 semaines** :

### boot-args de débogage à retirer

```
-v keepsyms=1 debug=0x100
```

### boot-args à CONSERVER

```
alcid=1 -amfipassbeta
```

### Procédure

1. Montez l'EFI : `sudo diskutil mount disk0s1`
2. Ouvrez le config.plist dans ProperTree
3. NVRAM → Add → 7C436110... → boot-args
4. Changez la valeur de :
   ```
   -v keepsyms=1 debug=0x100 alcid=1 -amfipassbeta
   ```
   en :
   ```
   alcid=1 -amfipassbeta
   ```
5. Sauvegardez et redémarrez

> **NE PAS ajouter** `agdpmod=pikera`. Ce paramètre est uniquement pour les GPU Navi (RX 5xxx/6xxx/7xxx). La RX 580 est un GPU Polaris qui fonctionne nativement.

---

## 9.6 Calendrier de maintenance

| Fréquence | Action |
|-----------|--------|
| **Mensuelle** | Vérifier les mises à jour des kexts sur GitHub |
| **Trimestrielle** | Mettre à jour OpenCore si nouvelle version stable |
| **Avant chaque MAJ macOS** | Sauvegarder EFI + MAJ OpenCore + MAJ kexts |
| **Après chaque MAJ macOS** | Réappliquer les root patches OCLP |
| **Semestrielle** | Vérifier les mises à jour OCLP |
| **Annuelle** | Nettoyer les anciennes sauvegardes EFI |

---

## 9.7 Dépannage courant

| Problème | Solution |
|----------|----------|
| No boot après MAJ OpenCore | Bootez sur la clé USB de secours, restaurez l'ancien EFI |
| Wi-Fi perdu après MAJ macOS | Réappliquez les root patches OCLP |
| Kernel panic après MAJ kext | Restaurez l'ancienne version du kext depuis la sauvegarde |
| « OC: Failed to load » | config.plist incompatible, validez avec ocvalidate |
| Boot lent | Retirez le mode verbose (-v) |
| Erreur « Vault mismatch » | Vérifiez Misc > Security > Vault = Optional |

---

## 9.8 Ressources

- [Dortania OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [Dortania Haswell Config](https://dortania.github.io/OpenCore-Install-Guide/config.plist/haswell.html)
- [OpenCore Changelog](https://github.com/acidanthera/OpenCorePkg/blob/master/Changelog.md)
- [OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher/releases)
- [r/hackintosh](https://www.reddit.com/r/hackintosh/)
- [InsanelyMac](https://www.insanelymac.com/)
- [Hackintool](https://github.com/benbaker76/Hackintool)

---

## Récapitulatif de la série

| Guide | Contenu | Statut |
|-------|---------|--------|
| [Guide 1](Guide-01-Telechargement-macOS.md) | Téléchargement de macOS Sequoia | ✅ |
| [Guide 2](Guide-02-Cle-USB-Bootable.md) | Création de la clé USB bootable | ✅ |
| [Guide 3](Guide-03-Preparation-EFI.md) | Préparation du dossier EFI | ✅ |
| [Guide 4](Guide-04-Config-Plist.md) | Configuration du Config.plist | ✅ |
| [Guide 5](Guide-05-Fenvi-WiFi-Bluetooth.md) | Wi-Fi et Bluetooth Fenvi T919 | ✅ |
| [Guide 6](Guide-06-Copie-EFI-USB.md) | Copie de l'EFI sur la clé USB | ✅ |
| [Guide 7](Guide-07-BIOS-Installation.md) | BIOS et installation macOS | ✅ |
| [Guide 8](Guide-08-Post-Installation.md) | Post-installation et OCLP | ✅ |
| [Guide 9](Guide-09-Maintenance-EFI.md) | Maintenance et mises à jour | ✅ |

---

← Retour à l'[index des guides](README.md)

← Guide précédent : [Guide 8 – Post-installation et OCLP](Guide-08-Post-Installation.md)
