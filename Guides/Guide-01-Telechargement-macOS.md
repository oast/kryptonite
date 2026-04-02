---
title: "Guide 1 – Téléchargement de macOS Sequoia Tahoe"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 1 – Téléchargement de macOS Sequoia Tahoe

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## 1.1 Vérifier la compatibilité matérielle

Avant de télécharger quoi que ce soit, on vérifie que **chaque composant** est compatible.

| Composant | Modèle | Statut | Notes |
|-----------|--------|--------|-------|
| **CPU** | Intel i7-4790 (Haswell) | Supporté via OpenCore | Plus supporté nativement depuis Ventura. Nécessite le spoof **iMac18,1**. |
| **GPU** | AMD RX 580 (Polaris) | Supporté nativement | Aucun patch nécessaire. WhateverGreen pour la stabilité. **Pas** de `agdpmod=pikera` (c'est pour Navi, pas Polaris). |
| **Wi-Fi / BT** | Fenvi T919 (BCM94360CD) | Nécessite OCLP | Patchs OCLP requis (voir **Guide 5**). |
| **Ethernet 10G** | Kalea AQC113 | Supporté | Via `AQtion.kext` + quirk `ForceAquantiaEthernet`. |
| **RAM** | 2x8 Go + 2x4 Go DDR3 (24 Go) | OK | Mixte = pas de souci. Placer les paires identiques dans le même canal. |
| **Stockage** | SSD SATA AHCI | Supporté nativement | TRIM activé en post-installation. |
| **Carte mère** | ASUS Z97-C | Supportée | Chipset Z97, compatible OpenCore. |

<!-- CAPTURE D'ÉCRAN : tableau récapitulatif de compatibilité matérielle -->

### Points importants

- Le **SMBIOS iMac18,1** est obligatoire.
  - iMac15,1 (ancien SMBIOS Haswell) est abandonné depuis Ventura.
  - iMac18,1 permet de contourner cette limitation.
- La **RX 580** fonctionne **sans patch** sous Sequoia.
  - Ne **jamais** ajouter `agdpmod=pikera` (réservé aux GPU Navi uniquement).
- Le **Fenvi T919** nécessite des patchs OCLP pour le Wi-Fi et le Bluetooth.
  - Détails complets dans le **Guide 5**.

---

## 1.2 Télécharger macOS Sequoia

Deux méthodes selon votre système actuel.

### Méthode A – Depuis macOS (recommandée)

C'est la méthode la plus simple. Elle télécharge l'installeur **complet** (~13 Go).

**Option 1 : App Store**

1. Ouvrir l'**App Store**.
2. Rechercher **macOS Sequoia**.
3. Cliquer sur **Télécharger**.
4. Attendre la fin du téléchargement.
5. L'installeur apparaît dans `/Applications/Install macOS Sequoia.app`.

**Option 2 : Terminal (softwareupdate)**

```bash
softwareupdate --fetch-full-installer --full-installer-version 15.x
```

- Remplacer `15.x` par la version exacte souhaitée (ex. `15.3`).
- L'installeur se place automatiquement dans `/Applications/`.

<!-- CAPTURE D'ÉCRAN : commande softwareupdate dans Terminal -->

**Option 3 : gibMacOS**

```bash
git clone https://github.com/corpnewt/gibMacOS.git
cd gibMacOS
python3 gibMacOS.command
```

- Sélectionner **macOS Sequoia** dans la liste.
- Suivre les instructions à l'écran.
- L'installeur final sera dans `/Applications/Install macOS Sequoia.app`.

---

### Méthode B – Depuis Linux Ubuntu 25.10

> **Attention** : c'est une installation **Recovery**.
> - Téléchargement initial : **~600 Mo** seulement.
> - Les **~12 Go restants** se téléchargent **pendant** l'installation.
> - **Connexion Ethernet obligatoire** pendant toute l'installation.

**Option 1 : Script automatisé (recommandée)**

```bash
./Scripts/macrecovery-download.sh
```

- Le script télécharge automatiquement les fichiers Recovery.
- Les fichiers se placent dans `com.apple.recovery.boot/`.

<!-- CAPTURE D'ÉCRAN : exécution du script macrecovery-download.sh -->

**Option 2 : Méthode manuelle**

1. Récupérer `macrecovery.py` depuis le dépôt OpenCorePkg :
   ```bash
   # Télécharger OpenCorePkg ou extraire macrecovery.py depuis Utilities/macrecovery/
   ```

2. Lancer le téléchargement :
   ```bash
   python3 macrecovery.py \
     -b Mac-4B682C642B45593E \
     -m 00000000000000000 \
     download
   ```

3. Vérifier les fichiers téléchargés :
   ```bash
   ls -lh com.apple.recovery.boot/
   ```

   Vous devez obtenir :
   - `BaseSystem.dmg` (~600 Mo)
   - `BaseSystem.chunklist` (~quelques Ko)

---

## 1.3 Vérifier l'intégrité des fichiers

**Ne sautez pas cette étape.** Un fichier corrompu = une installation qui plante.

### Depuis macOS

```bash
shasum -a 256 "/Applications/Install macOS Sequoia.app/Contents/SharedSupport/SharedSupport.dmg"
```

### Depuis Linux

```bash
sha256sum com.apple.recovery.boot/BaseSystem.dmg
```

### Tailles attendues (approximatives)

| Fichier | Taille attendue |
|---------|-----------------|
| Install macOS Sequoia.app (complet) | ~13–14 Go |
| BaseSystem.dmg (Recovery) | ~600–700 Mo |
| BaseSystem.chunklist | ~quelques Ko |

- Comparer le hash SHA-256 avec les valeurs officielles Apple (si disponibles).
- Si la taille est anormalement petite : **retélécharger**.

---

## Checklist de vérification

Avant de passer au Guide 2, vérifiez chaque point :

- [ ] Compatibilité matérielle vérifiée pour **tous** les composants
- [ ] SMBIOS confirmé : **iMac18,1** (pas iMac15,1)
- [ ] Installeur macOS Sequoia téléchargé avec succès
- [ ] **Méthode A** : `/Applications/Install macOS Sequoia.app` existe et pèse ~13 Go
- [ ] **Méthode B** : `BaseSystem.dmg` + `BaseSystem.chunklist` présents dans `com.apple.recovery.boot/`
- [ ] Intégrité vérifiée (SHA-256 ou taille de fichier)

---

## Dépannage

| Problème | Cause probable | Solution |
|----------|---------------|----------|
| `softwareupdate` ne trouve pas Sequoia | Version macOS trop ancienne | Utiliser gibMacOS ou l'App Store |
| Téléchargement qui s'arrête | Connexion instable | Relancer la commande, elle reprend |
| `macrecovery.py` erreur Python | Python 3 manquant | `sudo apt install python3` sous Linux |
| BaseSystem.dmg trop petit (<100 Mo) | Téléchargement incomplet | Supprimer et relancer `macrecovery.py` |
| Hash SHA-256 différent | Fichier corrompu | Retélécharger depuis le début |

---

## Étape suivante

Le téléchargement est terminé. Direction le **[Guide 2 – Création de la clé USB bootable](Guide-02-Cle-USB-Bootable.md)**.
