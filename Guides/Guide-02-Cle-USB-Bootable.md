---
title: "Guide 2 – Création de la clé USB bootable"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 2 – Création de la clé USB bootable

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## 2.1 Préparer la clé USB

### Exigences

| Critère | Minimum | Recommandé |
|---------|---------|------------|
| **Capacité** | 16 Go | 32 Go |
| **Interface** | USB 2.0 | USB 3.0 |
| **Contenu** | Vide ou sauvegardé | Vide |

> **Attention** : tout le contenu de la clé sera **effacé**. Sauvegarder vos données avant de continuer.

### Identifier la clé USB

**Depuis macOS :**

```bash
diskutil list
```

- Repérer la clé USB (ex. `/dev/disk2`).
- Vérifier la taille pour ne pas confondre avec un autre disque.

<!-- CAPTURE D'ÉCRAN : sortie de diskutil list avec la clé USB identifiée -->

**Depuis Linux :**

```bash
lsblk
```

- Repérer la clé USB (ex. `/dev/sdb`).
- Vérifier la taille et le modèle.

<!-- CAPTURE D'ÉCRAN : sortie de lsblk avec la clé USB identifiée -->

> **DANGER** : bien identifier le bon disque. Formater le mauvais disque = perte de données irréversible.

---

## 2.2 Formater la clé USB

### Méthode A – Depuis macOS

1. Identifier le disque (ex. `/dev/disk2`) :
   ```bash
   diskutil list
   ```

2. Formater en GPT + JHFS+ :
   ```bash
   diskutil partitionDisk /dev/diskN GPT JHFS+ "MyVolume" 100%
   ```
   - Remplacer `/dev/diskN` par votre disque (ex. `/dev/disk2`).
   - `MyVolume` = nom temporaire du volume.

3. Vérifier le résultat :
   ```bash
   diskutil list /dev/diskN
   ```
   - Vous devez voir une table de partition **GPT**.
   - Un volume **MyVolume** en JHFS+.

<!-- CAPTURE D'ÉCRAN : résultat du formatage macOS -->

### Méthode B – Depuis Linux Ubuntu 25.10

1. Identifier le disque (ex. `/dev/sdb`) :
   ```bash
   lsblk
   ```

2. Démonter toutes les partitions de la clé :
   ```bash
   sudo umount /dev/sdX*
   ```

3. Créer la table de partition GPT avec `gdisk` :
   ```bash
   sudo gdisk /dev/sdX
   ```

   Séquence de commandes dans gdisk :

   | Commande | Action | Détails |
   |----------|--------|---------|
   | `o` | Nouvelle table GPT | Confirmer avec `Y` |
   | `n` | Partition 1 (EFI) | First sector : défaut, Last sector : `+200M`, Type : `EF00` |
   | `n` | Partition 2 (données) | First sector : défaut, Last sector : défaut (tout l'espace), Type : `AF00` |
   | `w` | Écrire les changements | Confirmer avec `Y` |

4. Formater la partition EFI en FAT32 :
   ```bash
   sudo mkfs.vfat -F 32 -n "EFI" /dev/sdX1
   ```

5. Vérifier le résultat :
   ```bash
   lsblk -f /dev/sdX
   ```
   - Partition 1 : FAT32, label "EFI", ~200 Mo.
   - Partition 2 : Apple HFS (non formatée pour l'instant, c'est normal).

<!-- CAPTURE D'ÉCRAN : résultat de lsblk -f après formatage -->

---

## 2.3 Créer le support bootable

### Méthode A – Depuis macOS (installeur complet)

> **Prérequis** : avoir téléchargé l'installeur complet (voir Guide 1, Méthode A).

1. Lancer la commande `createinstallmedia` :
   ```bash
   sudo "/Applications/Install macOS Sequoia.app/Contents/Resources/createinstallmedia" \
     --volume /Volumes/MyVolume \
     --nointeraction
   ```

2. Entrer votre mot de passe administrateur.

3. Attendre la fin du processus :
   - **Erasing disk** : formatage de la clé.
   - **Copying to disk** : copie des fichiers (~15–30 min).
   - **Making disk bootable** : finalisation.
   - **Copy complete** : terminé.

<!-- CAPTURE D'ÉCRAN : sortie de createinstallmedia en cours -->

4. Vérifier :
   ```bash
   ls -la "/Volumes/Install macOS Sequoia/"
   ```
   - Vous devez voir les fichiers de l'installeur macOS.

### Méthode B – Depuis Linux (Recovery)

> **Prérequis** : avoir téléchargé les fichiers Recovery (voir Guide 1, Méthode B).
> **Rappel** : cette méthode nécessite une **connexion Ethernet active** pendant l'installation.

1. Créer le point de montage :
   ```bash
   sudo mkdir -p /mnt/usb
   ```

2. Monter la partition EFI :
   ```bash
   sudo mount /dev/sdX1 /mnt/usb
   ```

3. Créer le dossier Recovery et copier les fichiers :
   ```bash
   sudo mkdir -p /mnt/usb/com.apple.recovery.boot
   sudo cp com.apple.recovery.boot/BaseSystem.dmg /mnt/usb/com.apple.recovery.boot/
   sudo cp com.apple.recovery.boot/BaseSystem.chunklist /mnt/usb/com.apple.recovery.boot/
   ```

4. Vérifier la copie :
   ```bash
   ls -lh /mnt/usb/com.apple.recovery.boot/
   ```
   - `BaseSystem.dmg` : ~600–700 Mo.
   - `BaseSystem.chunklist` : quelques Ko.

5. Démonter la clé :
   ```bash
   sudo umount /mnt/usb
   ```

<!-- CAPTURE D'ÉCRAN : contenu de la partition EFI après copie des fichiers Recovery -->

> **Note** : le dossier EFI (OpenCore) sera ajouté dans le **Guide 6**. La clé n'est pas encore bootable.

---

## 2.4 Résumé des structures

### Méthode A (macOS complet)

```
/Volumes/Install macOS Sequoia/
├── .IABootFiles/
├── Install macOS Sequoia.app/
├── .disk_label
└── ...
```

### Méthode B (Linux Recovery)

```
/dev/sdX1 (EFI, FAT32, 200 Mo)
└── com.apple.recovery.boot/
    ├── BaseSystem.dmg
    └── BaseSystem.chunklist

/dev/sdX2 (Apple HFS, reste de l'espace)
└── (vide pour l'instant)
```

---

## Checklist de vérification

Avant de passer au Guide 3, vérifiez chaque point :

- [ ] Clé USB de **16 Go minimum** (32 Go recommandé)
- [ ] Clé formatée en **GPT**
- [ ] **Méthode A** : `createinstallmedia` terminé sans erreur
- [ ] **Méthode A** : volume "Install macOS Sequoia" visible dans le Finder
- [ ] **Méthode B** : partition EFI formatée en FAT32
- [ ] **Méthode B** : `BaseSystem.dmg` et `BaseSystem.chunklist` copiés dans `com.apple.recovery.boot/`
- [ ] Aucune erreur de copie ou de montage

---

## Dépannage

| Problème | Cause probable | Solution |
|----------|---------------|----------|
| `diskutil partitionDisk` erreur "Resource busy" | Clé en cours d'utilisation | Fermer toutes les fenêtres Finder, `diskutil unmountDisk /dev/diskN` |
| `createinstallmedia` erreur "not a valid volume" | Mauvais format de partition | Reformater en JHFS+ avec `diskutil partitionDisk` |
| `gdisk` non trouvé sous Linux | Package manquant | `sudo apt install gdisk` |
| `mkfs.vfat` non trouvé sous Linux | Package manquant | `sudo apt install dosfstools` |
| Permission denied sous Linux | Droits insuffisants | Utiliser `sudo` pour chaque commande |
| `createinstallmedia` bloqué à 0% | Clé USB lente ou défectueuse | Essayer un autre port USB ou une autre clé |
| Erreur "No space left on device" | Clé trop petite | Utiliser une clé de 32 Go |

---

## Étape suivante

La clé USB est prête. Direction le **[Guide 3 – Préparation et assemblage du dossier EFI](Guide-03-Preparation-EFI.md)**.
