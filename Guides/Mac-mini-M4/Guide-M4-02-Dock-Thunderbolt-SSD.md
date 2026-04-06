---
title: "Guide M4-02 – Connexion et formatage du dock Thunderbolt avec SSD M.2 2 To"
author: "Projet Kryptonite"
date: "2026-04-06"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide M4-02 – Connexion et formatage du dock Thunderbolt avec SSD M.2 2 To

> **Configuration cible** : Mac mini M4 | Dock Thunderbolt | SSD M.2 NVMe 2 To

---

## Prérequis

- Mac mini M4 configuré (voir [Guide M4-01](Guide-M4-01-Premier-Demarrage.md))
- Dock Thunderbolt avec SSD M.2 NVMe 2 To installé à l'intérieur
- Câble Thunderbolt 4 (ou USB4 40 Gb/s) — utilisez **impérativement** le câble fourni avec le dock ou un câble certifié Thunderbolt 4
- Le SSD M.2 doit être de type **NVMe** (PCIe) — les SSD M.2 SATA sont aussi compatibles mais moins performants

> **Compatibilité des docks Thunderbolt** : Les docks Thunderbolt 3/4 sont nativement pris en charge sur macOS sans pilote supplémentaire. Les docks USB4 sont également compatibles.

---

## Étape 1 – Vérification du dock et installation du SSD M.2

### 1.1 Choisir le bon format de SSD M.2

Avant d'installer le SSD dans le dock, vérifiez la compatibilité :

| Type | Interface | Compatible avec la plupart des docks |
|------|-----------|--------------------------------------|
| M.2 NVMe (PCIe 4.0) | PCIe 4.0 x4 | Oui (recommandé) |
| M.2 NVMe (PCIe 3.0) | PCIe 3.0 x4 | Oui |
| M.2 SATA | SATA III | Selon le dock (vérifiez la fiche technique) |

> **Conseil** : Un SSD NVMe PCIe 4.0 exploite au maximum la bande passante Thunderbolt 4 (40 Gb/s). Les débits réels atteignent 2 500–3 000 Mo/s en lecture.

### 1.2 Installer le SSD dans le dock

1. Éteignez le dock (s'il est alimenté séparément)
2. Ouvrez le compartiment M.2 du dock (souvent une vis ou un loquet)
3. Insérez le SSD M.2 en biais (environ 30°) dans le slot M.2
4. Abaissez le SSD et fixez-le avec la vis de retenue
5. Refermez le compartiment

---

## Étape 2 – Connexion du dock au Mac mini M4

### 2.1 Identifier les ports Thunderbolt du Mac mini M4

Le Mac mini M4 dispose de :
- **3 ports Thunderbolt 4** (USB-C, à l'arrière)
- **2 ports USB-A** (USB 3.2 Gen 2, à l'arrière)
- **1 port HDMI 2.1** (à l'arrière)
- **1 port Ethernet 10 Gb/s** (à l'arrière)
- **1 port USB-C** (USB 3.2 Gen 2, à l'avant)
- **1 port audio jack 3,5 mm** (à l'avant)

> **Important** : Branchez le dock **uniquement sur un port Thunderbolt 4** (ports arrière, marqués du symbole éclair ⚡). Ne branchez pas sur le port USB-C frontal qui est USB 3.2 (moins performant).

### 2.2 Connecter le câble

1. Branchez le câble Thunderbolt 4 sur l'un des ports Thunderbolt 4 arrière du Mac mini
2. Branchez l'autre extrémité sur le port Thunderbolt du dock
3. Si le dock a une alimentation externe, branchez-la aussi

### 2.3 Vérifier la détection

Quelques secondes après la connexion, le SSD doit apparaître sur le bureau ou dans le Finder.

Si c'est un **SSD neuf non formaté** :
- Une fenêtre s'ouvre : **"Ce disque n'est pas lisible par cet ordinateur"**
- Cliquez sur **Initialiser** pour lancer l'Utilitaire de disque — ou ignorez et passez à l'étape 3

---

## Étape 3 – Formatage du SSD avec l'Utilitaire de disque

### 3.1 Ouvrir l'Utilitaire de disque

- **Méthode 1** : Spotlight (⌘ + Espace) → tapez "Utilitaire de disque" → Entrée
- **Méthode 2** : Finder → Applications → Utilitaires → Utilitaire de disque

### 3.2 Afficher tous les disques

Dans l'Utilitaire de disque :
1. Cliquez sur le menu **Présentation** (barre de menus) → **Afficher tous les appareils**
2. Dans la colonne de gauche, vous verrez maintenant l'arborescence complète des disques

### 3.3 Identifier le SSD externe

Dans la colonne de gauche, repérez votre SSD externe. Il apparaît sous la forme :
```
[Nom du fabricant du dock] Media
  └── (sans nom) / disk2
```

> **Attention** : Assurez-vous de bien sélectionner le disque externe et non le disque interne du Mac. Le disque interne s'appelle généralement **"APPLE SSD"**.

### 3.4 Effacer et formater le SSD

1. Sélectionnez le **disque racine** du SSD externe (pas une partition, mais le disque lui-même)
2. Cliquez sur le bouton **Effacer** dans la barre d'outils

Remplissez les options :

| Option | Valeur recommandée |
|--------|--------------------|
| **Nom** | `SSD-Externe` (ou votre choix) |
| **Format** | **APFS** |
| **Schéma** | **Table de partition GUID (GPT)** |

> **Pourquoi APFS ?**
> - Format natif macOS depuis High Sierra
> - Copie-on-write, snapshots instantanés
> - Allocation d'espace dynamique entre volumes
> - Chiffrement natif (FileVault)
> - Performances optimales sur SSD NVMe

3. Cliquez sur **Effacer**
4. Attendez la fin du processus (quelques secondes pour un SSD neuf)
5. Cliquez sur **OK**

### 3.5 Vérifier le résultat

Après le formatage :
- Le SSD apparaît sur le Bureau macOS sous le nom choisi
- Dans l'Utilitaire de disque : le format indique **APFS** et le schéma **GUID Partition Map**

---

## Étape 4 – Vérifier les performances Thunderbolt

### 4.1 Vérifier la connexion Thunderbolt

1. Menu  → **À propos de ce Mac** → **Plus d'infos**
2. Cliquez sur **Rapport système** (ou menu Pomme → À propos de ce Mac → Rapport système)
3. Dans la barre latérale : **Matériel** → **Thunderbolt/USB4**
4. Vérifiez que le dock apparaît avec une vitesse de **40 Gb/s**

### 4.2 Test de débit avec l'outil Blackmagic Disk Speed Test

Téléchargez **Blackmagic Disk Speed Test** (gratuit sur le Mac App Store) :

1. Ouvrez l'application
2. Cliquez sur le sélecteur de disque → choisissez votre SSD externe
3. Cliquez sur **Start** pour lancer le test

Résultats attendus avec un SSD NVMe PCIe 4.0 via Thunderbolt 4 :

| Opération | Débit attendu |
|-----------|---------------|
| Écriture | ~1 500 – 2 500 Mo/s |
| Lecture | ~2 000 – 3 000 Mo/s |

> Si les débits sont inférieurs à 500 Mo/s, vérifiez que vous utilisez bien un câble Thunderbolt 4 certifié et que le dock est branché sur un port Thunderbolt 4 (pas USB-C/USB 3.2).

---

## Étape 5 – Chiffrement du SSD externe (optionnel mais recommandé)

Chiffrer le SSD externe protège vos données en cas de vol du dock ou du disque.

### 5.1 Activer FileVault sur le SSD externe

**Méthode rapide (Finder)** :
1. Clic droit sur l'icône du SSD externe sur le Bureau
2. Sélectionnez **Chiffrer "SSD-Externe"...**
3. Définissez un mot de passe solide
4. Notez le mot de passe dans votre gestionnaire de mots de passe
5. Cliquez sur **Chiffrer le disque**

> Le chiffrement initial peut prendre plusieurs heures pour 2 To. Le disque reste utilisable pendant l'opération.

---

## Étape 6 – Éjection correcte du disque

> **Toujours éjecter correctement le SSD avant de débrancher le câble.**

Pour éjecter :
- **Méthode 1** : Clic droit sur l'icône du SSD → **Éjecter**
- **Méthode 2** : Glissez l'icône du SSD vers la Corbeille (l'icône devient une flèche d'éjection)
- **Méthode 3** : Dans le Finder, cliquez sur le bouton ⏏ à côté du nom du disque

---

## Résumé

À la fin de ce guide, votre SSD externe est :

- [x] Correctement installé dans le dock Thunderbolt
- [x] Connecté au Mac mini M4 via Thunderbolt 4
- [x] Formaté en APFS avec une table GPT
- [x] Vérifié en termes de performances
- [x] Optionnellement chiffré avec FileVault

---

## Étape suivante

Passez au [Guide M4-03 – Optimisation du stockage et configuration avancée](Guide-M4-03-Optimisation-Stockage.md).
