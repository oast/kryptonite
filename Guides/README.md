---
title: "Guides d'installation – macOS Sequoia Tahoe sur ASUS Z97-C"
author: "Projet Kryptonite"
date: "2026-04-01"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guides d'installation – macOS Sequoia Tahoe sur ASUS Z97-C

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 (Haswell) | AMD RX 580 8 Go | macOS Sequoia Tahoe

Série de 9 guides pas-à-pas pour installer macOS Sequoia Tahoe via OpenCore sur un PC de bureau basé sur la plateforme Intel Haswell (Z97). Chaque guide est autonome, illustré et adapté aux débutants.

---

## Configuration matérielle

| Composant | Modèle |
|-----------|--------|
| Carte mère | ASUS Z97-C (chipset Intel Z97) |
| Processeur | Intel Core i7-4790 (Haswell, 4C/8T) |
| GPU | AMD Radeon RX 580 8 Go (pas d'iGPU utilisé) |
| Ethernet | Intel I218-V (intégré) + carte 10G Aquantia AQC107 |
| Audio | Realtek ALC892 (intégré) |
| SMBIOS | iMac15,1 |
| Bootloader | OpenCore (dernière version stable) |

## Prérequis globaux

- Un Mac fonctionnel ou une machine virtuelle macOS (pour préparer l'installation)
- Une clé USB de 16 Go minimum
- Connexion Internet stable
- Patience et rigueur dans le suivi des étapes

## Table des matières

| # | Guide | Description |
|---|-------|-------------|
| 1 | [Téléchargement de macOS Sequoia](Guide-01-Telechargement-macOS.md) | Vérifier la compatibilité et télécharger macOS |
| 2 | [Création de la clé USB bootable](Guide-02-Cle-USB-Bootable.md) | Formater et préparer le support d'installation |
| 3 | [Préparation d'OpenCore](Guide-03-Preparation-OpenCore.md) | Télécharger et comprendre la structure d'OpenCore |
| 4 | [Assemblage du dossier EFI](Guide-04-Assemblage-EFI.md) | Rassembler Kexts, Drivers et tables ACPI |
| 5 | [Création du Config.plist](Guide-05-Config-Plist.md) | Configurer OpenCore pour votre matériel |
| 6 | [Copie de l'EFI sur la clé USB](Guide-06-Copie-EFI-USB.md) | Monter et copier le dossier EFI |
| 7 | [Installation de macOS Sequoia](Guide-07-Installation-macOS.md) | Installer macOS pas à pas |
| 8 | [Post-installation et mappage USB](Guide-08-Post-Installation-USB.md) | Finaliser l'installation et mapper les ports USB |
| 9 | [Maintenance et mise à jour](Guide-09-Maintenance-EFI.md) | Maintenir votre EFI à jour |

## Script d'automatisation

Un script bash est fourni pour créer automatiquement l'arborescence EFI et télécharger les composants nécessaires :

```bash
chmod +x Scripts/setup-efi.sh
./Scripts/setup-efi.sh
```

Voir [Scripts/setup-efi.sh](Scripts/setup-efi.sh) pour plus de détails.

## Ressources utiles

- [Dortania OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)
- [OpenCore Releases](https://github.com/acidanthera/OpenCorePkg/releases)
- [ProperTree](https://github.com/corpnewt/ProperTree)
- [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS)
- [Hackintool](https://github.com/benbaker76/Hackintool)

## Conversion en PDF

Chaque guide inclut un en-tête YAML compatible avec [pandoc](https://pandoc.org/) pour la conversion en PDF :

```bash
# Convertir un guide en PDF
pandoc Guide-01-Telechargement-macOS.md -o Guide-01.pdf --pdf-engine=xelatex

# Convertir tous les guides
for f in Guide-*.md; do pandoc "$f" -o "${f%.md}.pdf" --pdf-engine=xelatex; done
```

## Licence

Ces guides sont fournis à titre éducatif. macOS est une marque déposée d'Apple Inc.
