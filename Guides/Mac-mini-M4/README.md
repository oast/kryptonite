---
title: "Guides Mac mini M4 – Installation propre et stockage Thunderbolt"
author: "Projet Kryptonite"
date: "2026-04-06"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guides Mac mini M4 – Installation propre et stockage Thunderbolt

> **Configuration cible** : Mac mini M4 | 16 Go RAM | 256 Go SSD interne | Dock Thunderbolt + SSD M.2 2 To externe

Série de 3 guides pour configurer proprement un Mac mini M4 avec un disque SSD externe de 2 To connecté via Thunderbolt dans un dock M.2.

---

## Configuration matérielle

| Composant | Modèle |
|-----------|--------|
| Machine | Mac mini (M4, 2024) |
| Processeur | Apple M4 (10 cœurs CPU, 10 cœurs GPU) |
| RAM | 16 Go RAM unifiée |
| Stockage interne | 256 Go SSD NVMe (Apple) |
| Stockage externe | SSD M.2 NVMe 2 To dans dock Thunderbolt |
| Connectivité | Thunderbolt 4 / USB4 (jusqu'à 40 Gb/s) |
| Système | macOS Sequoia (ou version fournie avec la machine) |

---

## Stratégie de stockage recommandée

Avec seulement 256 Go en interne et 2 To en externe, voici la répartition conseillée :

| Disque | Usage recommandé |
|--------|-----------------|
| **SSD interne 256 Go** | macOS, applications, données système |
| **SSD externe 2 To** | Documents, photos, vidéos, musique, Time Machine, machines virtuelles |

> **Remarque** : Le Mac mini M4 intègre un SSD Apple soudé, non remplaçable. La gestion intelligente du stockage externe est donc essentielle.

---

## Table des matières

| # | Guide | Description |
|---|-------|-------------|
| 1 | [Premier démarrage et configuration initiale](Guide-M4-01-Premier-Demarrage.md) | Configurer macOS proprement dès le premier allumage |
| 2 | [Connexion et formatage du dock Thunderbolt](Guide-M4-02-Dock-Thunderbolt-SSD.md) | Connecter, formater et monter le SSD M.2 externe |
| 3 | [Optimisation du stockage et configuration avancée](Guide-M4-03-Optimisation-Stockage.md) | Déplacer les données, Time Machine, conseils avancés |

---

## Prérequis globaux

- Mac mini M4 sous tension
- Dock Thunderbolt avec SSD M.2 NVMe 2 To installé
- Câble Thunderbolt 4 (ou USB4) de qualité
- Connexion Internet (Wi-Fi ou Ethernet)
- Identifiant Apple (Apple ID) actif

---

## Ressources utiles

- [Support Apple – Mac mini M4](https://support.apple.com/mac-mini)
- [Guide d'utilisation de Disk Utility (Utilitaire de disque)](https://support.apple.com/guide/disk-utility/)
- [Time Machine – Sauvegarder le Mac](https://support.apple.com/HT201250)
- [Optimiser le stockage sur macOS](https://support.apple.com/HT206996)
