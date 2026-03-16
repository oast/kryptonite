# Guide 3 – Téléchargement et préparation d'OpenCore

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- Un navigateur web ou un accès au Terminal
- Clé USB d'installation prête (voir [Guide 2](Guide-02-Cle-USB-Bootable.md))

---

## Étape 1 – Télécharger OpenCore

1. Rendez-vous sur la page des releases officielles d'OpenCore :
   **https://github.com/acidanthera/OpenCorePkg/releases**

2. Téléchargez la **dernière version stable** (RELEASE, pas DEBUG) :
   - Fichier : `OpenCore-X.Y.Z-RELEASE.zip`
   - Choisissez la version RELEASE pour une utilisation quotidienne

> ⚠️ **Ne téléchargez OpenCore que depuis le dépôt officiel acidanthera.** Évitez les sources tierces qui peuvent contenir des fichiers modifiés.

3. Décompressez l'archive :

```bash
# Exemple avec la version téléchargée
cd ~/Downloads
unzip OpenCore-*-RELEASE.zip -d OpenCore-RELEASE
```

<!-- 📸 Capture d'écran : page GitHub des releases OpenCore -->

---

## Étape 2 – Explorer la structure d'OpenCore

L'archive contient une structure précise. Voici les dossiers importants :

```
OpenCore-RELEASE/
├── Docs/
│   ├── Configuration.pdf        # Documentation complète
│   ├── Differences.pdf          # Changements entre versions
│   └── Sample.plist             # Modèle de configuration
├── EFI/
│   ├── BOOT/
│   │   └── BOOTx64.efi          # Chargeur de démarrage UEFI
│   └── OC/
│       ├── ACPI/                 # Tables ACPI personnalisées (vide)
│       ├── Drivers/              # Pilotes UEFI (vide)
│       │   └── (fichiers .efi disponibles dans le dossier Drivers/)
│       ├── Kexts/                # Extensions noyau (vide)
│       ├── Resources/            # Ressources (thèmes, audio)
│       ├── Tools/                # Outils UEFI
│       ├── OpenCore.efi          # Le bootloader OpenCore
│       └── config.plist          # Fichier de configuration (à créer)
└── Utilities/                    # Outils divers
```

### Dossiers clés pour notre configuration :

| Dossier | Contenu à ajouter |
|---------|-------------------|
| `EFI/OC/ACPI/` | Tables SSDT compilées (.aml) |
| `EFI/OC/Drivers/` | Pilotes UEFI (.efi) |
| `EFI/OC/Kexts/` | Extensions noyau (.kext) |
| `EFI/OC/` | Fichier `config.plist` |

---

## Étape 3 – Identifier les fichiers nécessaires

Pour la configuration ASUS Z97-C + i7-4790 + RX 580, voici ce qu'il faudra ajouter :

### Drivers UEFI (dossier `Drivers/`)

| Driver | Rôle |
|--------|------|
| **OpenRuntime.efi** | Requis – gestion mémoire et sécurité |
| **HfsPlus.efi** | Requis – lecture des volumes HFS+ |

> `OpenRuntime.efi` est inclus dans l'archive OpenCore. `HfsPlus.efi` doit être téléchargé séparément depuis le [dépôt OcBinaryData](https://github.com/acidanthera/OcBinaryData/blob/master/Drivers/HfsPlus.efi).

### Kexts (dossier `Kexts/`)

| Kext | Rôle | Source |
|------|------|--------|
| **Lilu.kext** | Framework de patches noyau (requis par tous les autres) | [acidanthera/Lilu](https://github.com/acidanthera/Lilu/releases) |
| **VirtualSMC.kext** | Émulation du SMC Apple | [acidanthera/VirtualSMC](https://github.com/acidanthera/VirtualSMC/releases) |
| **SMCProcessor.kext** | Monitoring CPU | Inclus avec VirtualSMC |
| **SMCSuperIO.kext** | Monitoring ventilateurs | Inclus avec VirtualSMC |
| **WhateverGreen.kext** | Patches GPU et gestion framebuffer | [acidanthera/WhateverGreen](https://github.com/acidanthera/WhateverGreen/releases) |
| **AppleALC.kext** | Audio Realtek ALC892 | [acidanthera/AppleALC](https://github.com/acidanthera/AppleALC/releases) |
| **IntelMausi.kext** | Ethernet Intel I218-V | [acidanthera/IntelMausi](https://github.com/acidanthera/IntelMausi/releases) |
| **AQC10G.kext** | Réseau 10G Aquantia | [Mieze/AQtion](https://github.com/Mieze/AQtion/releases) |

### Tables ACPI (dossier `ACPI/`)

| SSDT | Rôle |
|------|------|
| **SSDT-PLUG.aml** | Gestion d'alimentation CPU (XCPM) |
| **SSDT-EC.aml** | Contrôleur embarqué factice (requis depuis Catalina) |
| **SSDT-USBX.aml** | Propriétés d'alimentation USB |

> Les fichiers SSDT pré-compilés sont disponibles sur le [guide Dortania](https://dortania.github.io/Getting-Started-With-ACPI/ssdt-methods/ssdt-prebuilt.html).

---

## Étape 4 – Préparer le dossier de travail

Créez un dossier de travail pour organiser les téléchargements :

```bash
# Créer un dossier de travail
mkdir -p ~/Desktop/Hackintosh-Sequoia
cd ~/Desktop/Hackintosh-Sequoia

# Copier le dossier EFI depuis l'archive OpenCore
cp -R ~/Downloads/OpenCore-RELEASE/X64/EFI .

# Vérifier la structure
find EFI -type d
```

Résultat attendu :

```
EFI
EFI/BOOT
EFI/OC
EFI/OC/ACPI
EFI/OC/Drivers
EFI/OC/Kexts
EFI/OC/Resources
EFI/OC/Tools
```

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] OpenCore est téléchargé depuis la source officielle (acidanthera)
- [ ] L'archive est décompressée et la structure EFI est comprise
- [ ] Vous avez identifié tous les fichiers nécessaires (Drivers, Kexts, ACPI)
- [ ] Un dossier de travail est prêt sur votre bureau

---

## Dépannage

| Problème | Solution |
|----------|----------|
| Le lien GitHub ne fonctionne pas | Vérifiez votre connexion ; le dépôt est `acidanthera/OpenCorePkg` |
| L'archive ne contient pas `OpenRuntime.efi` | Cherchez dans le sous-dossier `X64/EFI/OC/Drivers/` |
| Confusion entre DEBUG et RELEASE | DEBUG = logs détaillés pour le diagnostic ; RELEASE = production |

---

## Étape suivante

→ [Guide 4 – Assemblage du dossier EFI](Guide-04-Assemblage-EFI.md)
