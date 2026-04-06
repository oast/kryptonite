---
title: "Guide M4-03 – Optimisation du stockage et configuration avancée"
author: "Projet Kryptonite"
date: "2026-04-06"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide M4-03 – Optimisation du stockage et configuration avancée

> **Configuration cible** : Mac mini M4 | 256 Go SSD interne | SSD externe 2 To via Thunderbolt

---

## Prérequis

- Mac mini M4 configuré (voir [Guide M4-01](Guide-M4-01-Premier-Demarrage.md))
- SSD externe 2 To formaté en APFS (voir [Guide M4-02](Guide-M4-02-Dock-Thunderbolt-SSD.md))
- SSD externe **toujours connecté** pendant la configuration

---

## Stratégie globale

Avec 256 Go en interne et 2 To en externe, voici comment répartir intelligemment :

```
SSD Interne (256 Go)              SSD Externe 2 To (Thunderbolt)
├── macOS (~15 Go)                ├── Documents/
├── Applications (~30-50 Go)     ├── Photos/
├── Fichiers système              ├── Musique/
├── Cache et swap                 ├── Films & Séries/
└── Espace de travail actif       ├── Machines virtuelles/
                                  ├── Projets archivés/
                                  └── Sauvegarde Time Machine/
```

---

## Option A – Déplacer le dossier Utilisateur vers le SSD externe

> **Attention** : Cette méthode avancée déplace tout votre dossier personnel `/Users/votrecompte` vers le SSD externe. Le Mac doit être **toujours connecté** au dock pour fonctionner normalement.

### Quand choisir cette option ?

- Vous avez beaucoup de documents, photos, musique
- Votre SSD interne de 256 Go est rapidement saturé
- Le dock Thunderbolt est **permanent** sur votre bureau (Mac mini = non nomade)

### A.1 – Créer le dossier destination sur le SSD externe

1. Ouvrez le **Finder**
2. Naviguez vers votre SSD externe (`SSD-Externe`)
3. Créez un dossier `Utilisateurs` : **Fichier → Nouveau dossier** (⇧⌘N)

### A.2 – Déplacer le dossier utilisateur

1. Ouvrez **Réglages du système** → **Utilisateurs et groupes**
2. Faites un **clic droit** (ou Ctrl+clic) sur votre compte utilisateur → **Options avancées**
   - Si cette option n'est pas visible, ouvrez le Terminal et tapez :
     ```bash
     sudo dscl . -read /Users/$(whoami) NFSHomeDirectory
     ```
3. Dans **Options avancées**, modifiez le champ **Dossier personnel** :
   - Valeur actuelle : `/Users/votrecompte`
   - Nouvelle valeur : `/Volumes/SSD-Externe/Utilisateurs/votrecompte`
4. Cliquez sur **OK**

5. Copiez manuellement votre dossier personnel dans le Terminal :
   ```bash
   sudo rsync -avH /Users/votrecompte/ /Volumes/SSD-Externe/Utilisateurs/votrecompte/
   ```

6. Vérifiez que la copie est complète, puis redémarrez le Mac

> **Alternative plus simple** : Ne pas déplacer le dossier utilisateur complet, mais seulement certains dossiers (Documents, Photos, etc.) via des liens symboliques (voir Option B).

---

## Option B – Déplacer sélectivement Documents, Photos et Musique

Cette approche est **plus sûre et recommandée** pour la plupart des utilisateurs.

### B.1 – Créer la structure sur le SSD externe

Ouvrez le Terminal (Spotlight : `Terminal`) et exécutez :

```bash
mkdir -p /Volumes/SSD-Externe/Documents
mkdir -p /Volumes/SSD-Externe/Photos
mkdir -p /Volumes/SSD-Externe/Musique
mkdir -p /Volumes/SSD-Externe/Films
```

### B.2 – Déplacer les dossiers et créer des liens symboliques

#### Documents

```bash
# Copier les données existantes
rsync -avH ~/Documents/ /Volumes/SSD-Externe/Documents/

# Vérifier que la copie est correcte, puis :
rm -rf ~/Documents
ln -s /Volumes/SSD-Externe/Documents ~/Documents
```

#### Musique (bibliothèque Apple Music)

```bash
rsync -avH ~/Music/ /Volumes/SSD-Externe/Musique/
rm -rf ~/Music
ln -s /Volumes/SSD-Externe/Musique ~/Music
```

> **Après avoir déplacé la bibliothèque Music** : Ouvrez Apple Music → Préférences → Fichiers → Emplacement de la bibliothèque multimédia → vérifiez qu'il pointe vers `/Volumes/SSD-Externe/Musique`.

#### Photos (bibliothèque Photos)

La bibliothèque Photos doit être déplacée différemment :

1. Fermez complètement l'application Photos
2. Dans le Finder, allez dans `~/Pictures/`
3. Glissez le fichier `Photothèque.photoslibrary` vers `/Volumes/SSD-Externe/Photos/`
4. Ouvrez Photos en maintenant **Option (⌥)** enfoncé
5. Dans la fenêtre qui s'ouvre, cliquez sur **Autre bibliothèque** et sélectionnez la bibliothèque sur le SSD externe
6. Dans Photos → Réglages → Général, cliquez sur **Utiliser comme bibliothèque du système**

---

## Option C – Utiliser iCloud Drive pour les Documents

Si vous avez un abonnement iCloud+, cette option est la plus transparente :

1. Réglages du système → **[Votre nom]** → **iCloud**
2. Activez **iCloud Drive**
3. Activez **Synchroniser ce Mac** pour les dossiers Bureau et Documents
4. Vos documents sont synchronisés dans le cloud et optimisés localement

> Avec cette option, macOS stocke uniquement les fichiers récents/actifs sur le SSD interne et garde le reste dans iCloud.

---

## Étape 2 – Configurer Time Machine sur le SSD externe

Time Machine est la solution de sauvegarde intégrée de macOS. Configurez-la sur le SSD externe.

### 2.1 Créer un volume APFS dédié à Time Machine

Il est recommandé de créer un **volume APFS séparé** pour Time Machine sur le SSD externe (APFS partage l'espace dynamiquement).

1. Ouvrez l'**Utilitaire de disque**
2. Sélectionnez votre SSD externe dans la colonne gauche
3. Cliquez sur **+** (Ajouter un volume) dans la barre d'outils
4. Configurez le nouveau volume :
   - **Nom** : `Time Machine`
   - **Format** : APFS
   - **Quota** : Définissez une taille réservée (ex. : 500 Go) si vous voulez limiter l'espace utilisé
5. Cliquez sur **Ajouter**

### 2.2 Activer Time Machine

1. Réglages du système → **Général** → **Time Machine**
2. Cliquez sur **Ajouter un disque de sauvegarde...**
3. Sélectionnez le volume **Time Machine** sur votre SSD externe
4. Cliquez sur **Utiliser le disque**
5. Optionnel : activez **Chiffrer les sauvegardes** et définissez un mot de passe

### 2.3 Lancer la première sauvegarde

- Time Machine lancera automatiquement la première sauvegarde dans l'heure
- Pour la forcer immédiatement : icône Time Machine dans la barre de menus → **Sauvegarder maintenant**

> La première sauvegarde complète peut prendre 1 à 3 heures selon la quantité de données.

---

## Étape 3 – Optimisation macOS pour le stockage interne

### 3.1 Activer l'optimisation du stockage macOS

1. Menu  → **À propos de ce Mac** → **Plus d'infos** → **Stockage**
2. Cliquez sur **Gérer...**
3. Activez les options suivantes :

| Option | Description | Recommandé |
|--------|-------------|-----------|
| **Stocker dans iCloud** | Déplace Bureau/Documents dans iCloud | Si abonnement iCloud+ |
| **Optimiser le stockage** | Supprime les films/séries regardés | Oui |
| **Vider la corbeille automatiquement** | Supprime après 30 jours | Oui |
| **Réduire l'encombrement** | Identifie les gros fichiers | Oui (revue manuelle) |

### 3.2 Nettoyer les caches et fichiers temporaires

```bash
# Vider le cache de l'utilisateur
rm -rf ~/Library/Caches/*

# Vider les logs utilisateur
rm -rf ~/Library/Logs/*
```

> Redémarrez le Mac après le nettoyage.

### 3.3 Désactiver le mode veille prolongée (optionnel)

Le Mac mini n'est pas portable, le sleepimage (image de RAM pour la veille prolongée) consomme de l'espace disque (équivalent à la RAM = 16 Go) :

```bash
# Vérifier la configuration actuelle
pmset -g | grep hibernatemode

# Désactiver la veille prolongée (0 = veille normale sans fichier hibernation)
sudo pmset -a hibernatemode 0

# Supprimer le fichier sleepimage existant
sudo rm -f /private/var/vm/sleepimage
```

> **Note** : Cela libère ~16 Go sur le SSD interne. Sur Mac mini (non portable), la perte de données en cas de coupure de courant pendant la veille est le seul risque.

---

## Étape 4 – Automatiser le montage du SSD externe

Le SSD externe doit être monté au démarrage pour que les liens symboliques et Time Machine fonctionnent.

### 4.1 Vérifier le montage automatique

Le dock Thunderbolt doit être **branché avant le démarrage** du Mac pour un montage automatique. Si le Mac démarre sans le dock :
- Les liens symboliques vers le SSD externe seront cassés
- Time Machine ignorera cette sauvegarde

### 4.2 Configurer une alerte si le disque est absent (optionnel)

Créez un script de vérification avec un LaunchAgent :

```bash
# Créer le script de vérification
cat > ~/Library/Scripts/check-external-ssd.sh << 'EOF'
#!/bin/bash
if [ ! -d "/Volumes/SSD-Externe" ]; then
    osascript -e 'display notification "Le SSD externe n'\''est pas connecté !" with title "Stockage" sound name "Basso"'
fi
EOF
chmod +x ~/Library/Scripts/check-external-ssd.sh
```

---

## Étape 5 – Tableau de bord du stockage

Après configuration, voici l'état cible de votre stockage :

### SSD Interne (256 Go)
```
Utilisé :  ~80-120 Go
  ├── macOS + système : ~15 Go
  ├── Applications    : ~30-50 Go
  ├── Cache/Temp      : ~5-10 Go
  └── Espace de travail actif

Libre : ~130-170 Go (tampon confortable)
```

### SSD Externe 2 To (Thunderbolt)
```
Utilisé : variable
  ├── Documents       : selon votre usage
  ├── Photos          : selon votre médiathèque
  ├── Musique         : selon votre bibliothèque
  ├── Films/Vidéos    : selon votre usage
  └── Time Machine    : ~500 Go réservés

Libre : largement suffisant pour des années d'usage
```

---

## Résumé final

À la fin de ces 3 guides, votre Mac mini M4 est parfaitement configuré :

- [x] macOS installé proprement avec FileVault activé
- [x] SSD externe 2 To connecté via Thunderbolt 4, formaté en APFS
- [x] Données personnelles (Documents, Photos, Musique) sur le SSD externe
- [x] Time Machine configurée sur le SSD externe
- [x] Stockage interne optimisé avec ~130-170 Go libres
- [x] Mac mini prêt pour une utilisation quotidienne fiable

---

## Conseils supplémentaires

### Sécurité du dock Thunderbolt

- Ne branchez jamais un dock ou accessoire Thunderbolt/USB-C d'origine inconnue : Thunderbolt permet un accès DMA direct à la RAM (attaque "Thunderspy")
- Activez la protection Thunderbolt : Réglages du système → Confidentialité et sécurité → Sécurité → cochez **Exiger l'approbation de l'utilisateur pour les nouveaux accessoires Thunderbolt**

### Durée de vie du SSD externe

- Évitez de débrancher le câble sans éjecter le disque
- Évitez les variations thermiques extrêmes sur le dock
- Vérifiez périodiquement la santé du SSD avec **DriveDx** (payant) ou **smartmontools** (gratuit via Homebrew) :
  ```bash
  brew install smartmontools
  smartctl -a /dev/disk2  # remplacez disk2 par votre disque
  ```

### Homebrew (gestionnaire de paquets)

Pour installer des outils en ligne de commande sur macOS :
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
