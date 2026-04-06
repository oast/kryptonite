---
title: "Guide M4-01 – Premier démarrage et configuration initiale du Mac mini M4"
author: "Projet Kryptonite"
date: "2026-04-06"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide M4-01 – Premier démarrage et configuration initiale du Mac mini M4

> **Configuration cible** : Mac mini M4 | 16 Go RAM | 256 Go SSD interne | macOS Sequoia

---

## Prérequis

- Mac mini M4 déballé et connecté à un écran (HDMI ou USB-C)
- Clavier et souris (USB ou Bluetooth)
- Connexion Internet disponible (Wi-Fi ou câble Ethernet)
- Un identifiant Apple (Apple ID) — créez-en un à l'avance si nécessaire

---

## Étape 1 – Branchements physiques

Avant d'allumer le Mac mini, effectuez tous les branchements :

1. **Alimentation** : branchez le câble d'alimentation (prise secteur IEC C7 à l'arrière)
2. **Écran** :
   - Port HDMI (à l'arrière) → câble HDMI vers votre moniteur
   - **ou** port Thunderbolt 4 → adaptateur USB-C/Thunderbolt vers votre écran
3. **Clavier et souris** :
   - USB : branchez directement sur les ports USB-A ou USB-C du Mac mini
   - Bluetooth : ils s'associeront pendant la configuration initiale
4. **Ethernet** (recommandé) : branchez un câble RJ45 sur le port Ethernet 10 Gb/s

> **Conseil** : Utiliser Ethernet pour le premier démarrage est fortement recommandé. La connexion est plus stable que le Wi-Fi pour les mises à jour initiales.

---

## Étape 2 – Premier allumage

1. Appuyez sur le bouton d'alimentation situé **à l'arrière du Mac mini** (coin inférieur gauche vu de face)
2. Le Mac mini émet un son de démarrage et le logo Apple apparaît
3. L'assistant de configuration macOS se lance automatiquement

---

## Étape 3 – Assistant de configuration macOS

Suivez les étapes de l'assistant dans l'ordre :

### 3.1 Langue et région

- Sélectionnez **Français** comme langue
- Sélectionnez votre pays/région (France, Belgique, Suisse, etc.)
- Cliquez sur **Continuer**

### 3.2 Accessibilité

- Passez cette étape pour l'instant (cliquez sur **Plus tard**)
- Vous pourrez configurer l'accessibilité dans les Préférences Système

### 3.3 Connexion Internet

- **Wi-Fi** : sélectionnez votre réseau et saisissez le mot de passe
- **Ethernet** : la connexion est détectée automatiquement, aucune action requise
- Cliquez sur **Continuer**

### 3.4 Données et confidentialité

- Lisez les informations affichées
- Cliquez sur **Continuer**

### 3.5 Migration (IMPORTANT)

> **Pour une installation propre, choisissez "Ne pas transférer mes informations".**

- Si c'est votre premier Mac ou si vous voulez repartir de zéro : sélectionnez **Ne pas transférer mes informations maintenant**
- Si vous souhaitez migrer depuis un ancien Mac : sélectionnez **Depuis un Mac** et suivez les instructions de Migration Assistant

Cliquez sur **Continuer**.

### 3.6 Connexion avec l'identifiant Apple

- Saisissez votre **adresse e-mail** et votre **mot de passe Apple ID**
- Validez le code de vérification à deux facteurs (envoyé sur votre iPhone ou iPad)
- Acceptez les conditions d'utilisation

> **Note** : Votre Apple ID est lié à vos achats, iCloud, et FaceTime. Utilisez le même que sur vos autres appareils Apple.

### 3.7 Création du compte utilisateur

Remplissez les champs suivants :

| Champ | Recommandation |
|-------|----------------|
| **Nom complet** | Votre prénom et nom |
| **Nom du compte** | Court, sans espaces ni accents (ex. : `jdupont`) |
| **Mot de passe** | Fort, mémorisable — ne le perdez pas ! |
| **Indice** | Optionnel, discret |

> **Important** : Le nom du compte (identifiant court) définit le nom de votre dossier personnel `/Users/jdupont`. Il ne peut pas être changé facilement par la suite.

### 3.8 FileVault (chiffrement du disque)

**Recommandation : activez FileVault.**

- FileVault chiffre intégralement le SSD interne avec AES-XTS 128 bits
- Sur Mac Apple Silicon (M4), le chiffrement est accéléré par le Secure Enclave
- L'impact sur les performances est **nul** sur M4
- Conservez précieusement la **clé de récupération** affichée

Sélectionnez **Activer FileVault** et cliquez sur **Continuer**.

### 3.9 iCloud Keychain (Trousseau iCloud)

- Activez le Trousseau iCloud pour synchroniser vos mots de passe entre appareils Apple
- Cliquez sur **Continuer**

### 3.10 Siri

- Activez ou désactivez Siri selon vos préférences
- Cliquez sur **Continuer**

### 3.11 Screen Time (Temps d'écran)

- Ignorez pour l'instant, sauf si vous configurez le Mac pour un enfant
- Cliquez sur **Ignorer**

### 3.12 Apparence et couleurs

- Choisissez **Clair**, **Sombre** ou **Automatique**
- Cliquez sur **Continuer**

---

## Étape 4 – Bureau macOS : premières actions

Une fois sur le bureau, effectuez ces actions dans l'ordre.

### 4.1 Vérifier et installer les mises à jour système

1. Cliquez sur le menu  → **Réglages du système**
2. Dans la barre latérale, cliquez sur **Général** → **Mise à jour de logiciels**
3. Installez toutes les mises à jour disponibles
4. Redémarrez si demandé

> **Ne sautez pas cette étape.** Les premières mises à jour peuvent inclure des correctifs de sécurité et des pilotes essentiels.

### 4.2 Vérifier les informations système

1. Menu  → **À propos de ce Mac**
2. Vérifiez :
   - **Puce** : Apple M4
   - **Mémoire** : 16 Go
   - **Stockage** : 256 Go (environ 245 Go réels disponibles)

### 4.3 Configurer les préférences essentielles

**Trackpad / Souris**
- Réglages du système → Souris (ou Trackpad)
- Ajustez la vitesse du pointeur et activez le défilement naturel selon vos préférences

**Dock**
- Faites un clic droit sur le Dock → **Préférences du Dock**
- Recommandé : activez **Masquer et afficher automatiquement le Dock** pour gagner de l'espace écran

**Nom de la machine**
- Réglages du système → Général → Partage
- Changez le **Nom de l'ordinateur** pour quelque chose de mémorisable (ex. : `Mac-mini-M4`)

---

## Étape 5 – Vérification du stockage interne

1. Menu  → **À propos de ce Mac** → **Plus d'infos** → **Stockage**
2. Vérifiez que le disque interne de 256 Go est correctement reconnu
3. Notez l'espace disponible (environ 220-230 Go après macOS)

---

## Résumé

À la fin de ce guide, votre Mac mini M4 est :

- [x] Allumé et configuré avec un compte utilisateur
- [x] Connecté à Internet
- [x] Chiffré avec FileVault
- [x] À jour avec les dernières mises à jour macOS
- [x] Prêt pour la connexion du disque externe Thunderbolt

---

## Étape suivante

Passez au [Guide M4-02 – Connexion et formatage du dock Thunderbolt + SSD M.2 2 To](Guide-M4-02-Dock-Thunderbolt-SSD.md).
