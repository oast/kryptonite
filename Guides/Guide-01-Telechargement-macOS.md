# Guide 1 – Téléchargement de macOS Sequoia Tahoe

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- Un Mac fonctionnel (ou une machine virtuelle macOS)
- Connexion Internet stable (le fichier pèse environ 13 Go)
- Au moins 20 Go d'espace libre sur le disque

---

## Étape 1 – Vérification de la compatibilité matérielle

Avant de télécharger macOS, vérifiez que votre matériel est compatible avec OpenCore et macOS Sequoia.

### Processeur : Intel i7-4790 (Haswell)

Les processeurs Haswell (4e génération Intel) sont pris en charge par macOS via OpenCore. Points importants :

- **Architecture** : Haswell est supporté par macOS depuis Mavericks (10.9) jusqu'à Sequoia
- **iGPU** : L'Intel HD 4600 intégré n'est **pas utilisé** dans notre configuration (GPU dédié RX 580)
- **Instructions SSE4.2 et AVX2** : présentes sur le i7-4790, requises par macOS Sequoia

### GPU : AMD Radeon RX 580

- La RX 580 est nativement supportée par macOS depuis High Sierra (10.13)
- Aucun patch GPU supplémentaire n'est nécessaire
- Le kext **WhateverGreen** est tout de même requis pour la gestion correcte du framebuffer

### Carte mère : ASUS Z97-C

- Chipset Intel Z97, compatible avec OpenCore
- Audio Realtek ALC892 : supporté via **AppleALC** (layout-id à déterminer)
- Ethernet Intel I218-V : supporté via **IntelMausi**
- USB : nécessitera un mappage personnalisé (Guide 8)

> ⚠️ **Important** : Vérifiez que votre BIOS est à jour. La dernière version disponible pour l'ASUS Z97-C est recommandée.

<!-- 📸 Capture d'écran : page de spécifications ASUS Z97-C -->

---

## Étape 2 – Téléchargement de macOS Sequoia

Deux méthodes sont disponibles :

### Méthode A – Via l'App Store (recommandée si vous avez un Mac)

1. Ouvrez l'**App Store** sur votre Mac
2. Recherchez **macOS Sequoia**
3. Cliquez sur **Obtenir** puis **Télécharger**
4. L'installateur se télécharge dans `/Applications/Install macOS Sequoia.app`

> ⚠️ **Ne lancez pas l'installation !** Fermez l'installateur s'il s'ouvre automatiquement.

<!-- 📸 Capture d'écran : macOS Sequoia dans l'App Store -->

### Méthode B – Via gibMacOS (si vous n'avez pas de Mac)

[gibMacOS](https://github.com/corpnewt/gibMacOS) est un script Python qui permet de télécharger macOS directement depuis les serveurs Apple.

1. Téléchargez gibMacOS :

```bash
git clone https://github.com/corpnewt/gibMacOS.git
cd gibMacOS
```

2. Lancez le script :

```bash
# Sur macOS
python3 gibMacOS.command

# Sur Windows
python gibMacOS.bat

# Sur Linux
python3 gibMacOS.py
```

3. Dans le menu, sélectionnez **macOS Sequoia** dans la liste
4. Le téléchargement commence automatiquement dans le dossier `macOS Downloads/`

5. Une fois le téléchargement terminé, utilisez le script `BuildmacOSInstallApp.command` pour reconstruire l'installateur :

```bash
# Sur macOS uniquement
python3 BuildmacOSInstallApp.command
```

Sélectionnez le dossier contenant les fichiers téléchargés. L'installateur sera créé dans `/Applications/`.

<!-- 📸 Capture d'écran : interface gibMacOS avec la liste des versions macOS -->

---

## Étape 3 – Vérification de l'intégrité du fichier

Il est essentiel de vérifier que le téléchargement n'est pas corrompu.

### Vérifier la taille de l'installateur

```bash
# Vérifiez que l'installateur existe et a une taille raisonnable (~13 Go)
ls -lh "/Applications/Install macOS Sequoia.app"
```

### Vérifier le hash SHA-256

```bash
# Calculer le hash SHA-256 de l'installateur
shasum -a 256 "/Applications/Install macOS Sequoia.app/Contents/SharedSupport/SharedSupport.dmg"
```

Comparez le hash obtenu avec celui publié sur les forums de la communauté Hackintosh ou sur le site officiel Apple.

> ⚠️ **Si le hash ne correspond pas**, supprimez le fichier et recommencez le téléchargement. Un fichier corrompu peut provoquer des erreurs d'installation impossibles à diagnostiquer.

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] L'installateur `Install macOS Sequoia.app` est présent dans `/Applications/`
- [ ] La taille du fichier est d'environ 13 Go
- [ ] Le hash SHA-256 a été vérifié (ou le téléchargement provient directement de l'App Store)

---

## Dépannage

| Problème | Solution |
|----------|----------|
| L'App Store indique que macOS Sequoia n'est pas disponible | Vérifiez que votre Mac exécute au moins macOS 10.15 Catalina |
| gibMacOS ne trouve pas Sequoia | Mettez à jour gibMacOS avec `git pull` |
| Téléchargement interrompu | Relancez la commande, gibMacOS reprend là où il s'est arrêté |
| Hash SHA-256 différent | Supprimez et retéléchargez le fichier complet |

---

## Étape suivante

→ [Guide 2 – Création de la clé USB bootable](Guide-02-Cle-USB-Bootable.md)
