# Guide 9 – Maintenance et mise à jour de l'EFI

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- macOS Sequoia installé et fonctionnel (voir guides précédents)
- Boot autonome depuis le disque interne (voir [Guide 8](Guide-08-Post-Installation-USB.md))

---

## Étape 1 – Sauvegarder votre EFI avant toute modification

> ⚠️ **Règle d'or** : ne modifiez JAMAIS votre EFI sans avoir une sauvegarde fonctionnelle.

### 1.1 – Créer une sauvegarde

```bash
# Monter la partition EFI
sudo diskutil mount disk0s1

# Créer un dossier de sauvegardes daté
mkdir -p ~/Desktop/EFI-Backups
cp -R /Volumes/EFI/EFI ~/Desktop/EFI-Backups/EFI-$(date +%Y-%m-%d)

# Vérifier la sauvegarde
ls ~/Desktop/EFI-Backups/
```

### 1.2 – Stratégie de sauvegarde recommandée

| Quand sauvegarder | Pourquoi |
|-------------------|----------|
| Avant chaque mise à jour de macOS | Les MAJ peuvent casser la compatibilité |
| Avant chaque modification de l'EFI | Pour pouvoir revenir en arrière |
| Après chaque modification réussie | Pour avoir une référence stable |
| Sur un support externe (clé USB) | En cas de panne du disque interne |

### 1.3 – Garder une clé USB de secours

Conservez toujours votre clé USB d'installation avec un EFI fonctionnel. En cas de problème avec l'EFI du disque interne, vous pourrez booter depuis la clé USB et corriger.

```bash
# Copier l'EFI fonctionnel sur la clé USB de secours
sudo diskutil mount disk2s1    # Partition EFI de la clé USB
sudo cp -R /Volumes/EFI/EFI /Volumes/EFI\ 1/
```

---

## Étape 2 – Mettre à jour OpenCore

### 2.1 – Vérifier la version actuelle

```bash
# Dans le Terminal, vérifiez la version d'OpenCore
nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version
```

### 2.2 – Télécharger la nouvelle version

1. Consultez les [releases OpenCore](https://github.com/acidanthera/OpenCorePkg/releases)
2. Lisez les **notes de version** pour les changements importants
3. Téléchargez la version RELEASE

```bash
cd ~/Desktop
curl -LO "https://github.com/acidanthera/OpenCorePkg/releases/latest/download/OpenCore-RELEASE.zip"
unzip OpenCore-RELEASE.zip -d OpenCore-NEW
```

### 2.3 – Mettre à jour les fichiers

> ⚠️ **Ne remplacez pas tout le dossier EFI d'un coup.** Mettez à jour fichier par fichier.

```bash
# Monter la partition EFI
sudo diskutil mount disk0s1

# Mettre à jour les fichiers OpenCore de base
cp OpenCore-NEW/X64/EFI/BOOT/BOOTx64.efi /Volumes/EFI/EFI/BOOT/
cp OpenCore-NEW/X64/EFI/OC/OpenCore.efi /Volumes/EFI/EFI/OC/
cp OpenCore-NEW/X64/EFI/OC/Drivers/OpenRuntime.efi /Volumes/EFI/EFI/OC/Drivers/
```

### 2.4 – Mettre à jour le config.plist

Chaque version d'OpenCore peut introduire de nouvelles clés dans le config.plist :

1. Consultez le fichier `Differences.pdf` inclus dans l'archive
2. Ouvrez votre config.plist existant dans ProperTree
3. Comparez avec le nouveau `Sample.plist`
4. Ajoutez les nouvelles clés et supprimez les clés obsolètes

```bash
# Comparer les deux fichiers (optionnel, pour les utilisateurs avancés)
diff <(plutil -convert xml1 -o - /Volumes/EFI/EFI/OC/config.plist | sort) \
     <(plutil -convert xml1 -o - OpenCore-NEW/Docs/Sample.plist | sort)
```

5. Lancez **OC Snapshot** dans ProperTree pour synchroniser
6. Validez avec `ocvalidate` :

```bash
OpenCore-NEW/Utilities/ocvalidate/ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

---

## Étape 3 – Mettre à jour les Kexts

### 3.1 – Vérifier les versions installées

```bash
# Lister les kexts et leurs versions
for kext in /Volumes/EFI/EFI/OC/Kexts/*.kext; do
    version=$(defaults read "$kext/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "N/A")
    echo "$(basename $kext): $version"
done
```

### 3.2 – Télécharger les nouvelles versions

Mettez à jour chaque kext individuellement :

```bash
cd ~/Desktop

# Lilu
curl -LO "https://github.com/acidanthera/Lilu/releases/latest/download/Lilu-RELEASE.zip"

# VirtualSMC
curl -LO "https://github.com/acidanthera/VirtualSMC/releases/latest/download/VirtualSMC-RELEASE.zip"

# WhateverGreen
curl -LO "https://github.com/acidanthera/WhateverGreen/releases/latest/download/WhateverGreen-RELEASE.zip"

# AppleALC
curl -LO "https://github.com/acidanthera/AppleALC/releases/latest/download/AppleALC-RELEASE.zip"

# IntelMausi
curl -LO "https://github.com/acidanthera/IntelMausi/releases/latest/download/IntelMausi-RELEASE.zip"
```

### 3.3 – Remplacer les kexts

```bash
# Exemple pour Lilu (répétez pour chaque kext)
unzip Lilu-RELEASE.zip -d Lilu-temp
rm -rf /Volumes/EFI/EFI/OC/Kexts/Lilu.kext
cp -R Lilu-temp/Lilu.kext /Volumes/EFI/EFI/OC/Kexts/
rm -rf Lilu-temp Lilu-RELEASE.zip
```

> ⚠️ **Mettez à jour Lilu en premier**, car c'est le framework dont dépendent les autres kexts. En cas d'incompatibilité, vous saurez que le problème vient de Lilu.

### 3.4 – Synchroniser le config.plist

Après avoir mis à jour les kexts :

1. Ouvrez le config.plist dans ProperTree
2. Lancez **OC Snapshot** (`File > OC Snapshot`)
3. Sauvegardez

---

## Étape 4 – Mises à jour macOS

### 4.1 – Avant de mettre à jour macOS

1. **Sauvegardez votre EFI** (Étape 1)
2. **Consultez les forums** Hackintosh pour vérifier la compatibilité de la mise à jour
3. **Mettez à jour OpenCore et les kexts** vers les dernières versions stables
4. **Préparez votre clé USB de secours** avec l'EFI fonctionnel

### 4.2 – Appliquer la mise à jour

1. Ouvrez **Préférences Système > Mise à jour de logiciels**
2. Téléchargez la mise à jour (ne l'installez pas encore)
3. Vérifiez une dernière fois votre sauvegarde EFI
4. Lancez l'installation

> ⚠️ **Mises à jour mineures** (ex: 15.1 → 15.1.1) : généralement sûres.
> ⚠️ **Mises à jour majeures** (ex: 15.x → 16.x) : attendez les retours de la communauté.

### 4.3 – Après la mise à jour

```bash
# Vérifier la version de macOS
sw_vers

# Vérifier que tout fonctionne
system_profiler SPHardwareDataType
system_profiler SPDisplaysDataType
system_profiler SPAudioDataType
system_profiler SPUSBDataType
```

Si le système ne démarre plus après la mise à jour :
1. Bootez depuis la clé USB de secours
2. Restaurez l'EFI de sauvegarde
3. Consultez les forums pour identifier le problème

---

## Étape 5 – Maintenance régulière

### 5.1 – Calendrier de maintenance recommandé

| Fréquence | Action |
|-----------|--------|
| Mensuelle | Vérifier les mises à jour des kexts |
| Trimestrielle | Mettre à jour OpenCore si une nouvelle version stable est disponible |
| Avant chaque MAJ macOS | Sauvegarder l'EFI + mettre à jour OpenCore/kexts |
| Annuelle | Nettoyer les anciennes sauvegardes EFI |

### 5.2 – Sources d'information

- [Forum InsanelyMac](https://www.insanelymac.com/)
- [Subreddit r/hackintosh](https://www.reddit.com/r/hackintosh/)
- [Dortania Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [OpenCore Changelog](https://github.com/acidanthera/OpenCorePkg/blob/master/Changelog.md)

### 5.3 – Retirer le mode verbose

Une fois que votre système est stable, retirez `-v` des boot-args pour un démarrage silencieux :

1. Ouvrez le config.plist dans ProperTree
2. Allez dans `NVRAM > Add > 7C436110-AB2A-4BBB-A880-FE41995C9F82 > boot-args`
3. Retirez `-v` de la chaîne
4. Vous pouvez aussi retirer `keepsyms=1` et `debug=0x100`
5. Résultat : `alcid=1` (ou votre alcid)
6. Sauvegardez et redémarrez

---

## Récapitulatif de la série

Félicitations ! Vous avez terminé l'installation complète de macOS Sequoia sur votre ASUS Z97-C. Voici un résumé de ce qui a été accompli :

| Guide | Réalisation |
|-------|-------------|
| [Guide 1](Guide-01-Telechargement-macOS.md) | Téléchargement de macOS Sequoia |
| [Guide 2](Guide-02-Cle-USB-Bootable.md) | Création de la clé USB bootable |
| [Guide 3](Guide-03-Preparation-OpenCore.md) | Préparation d'OpenCore |
| [Guide 4](Guide-04-Assemblage-EFI.md) | Assemblage du dossier EFI |
| [Guide 5](Guide-05-Config-Plist.md) | Configuration du Config.plist |
| [Guide 6](Guide-06-Copie-EFI-USB.md) | Copie de l'EFI sur la clé USB |
| [Guide 7](Guide-07-Installation-macOS.md) | Installation de macOS Sequoia |
| [Guide 8](Guide-08-Post-Installation-USB.md) | Post-installation et mappage USB |
| [Guide 9](Guide-09-Maintenance-EFI.md) | Maintenance et mises à jour |

---

## Dépannage

| Problème | Solution |
|----------|----------|
| Boot impossible après MAJ OpenCore | Restaurez l'EFI depuis la sauvegarde via la clé USB |
| Kext incompatible après mise à jour | Revenez à la version précédente du kext |
| macOS ne démarre plus après MAJ | Bootez via clé USB, restaurez l'EFI, attendez un correctif |
| Perte de numéros de série | Gardez vos valeurs SMBIOS dans un fichier texte sécurisé |

---

← [Retour à l'index des guides](README.md)
