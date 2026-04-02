---
title: "Guide 4 – Création et personnalisation du Config.plist"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 4 – Création et personnalisation du Config.plist

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## 4.1 – Outils nécessaires

Deux outils sont indispensables pour éditer et valider le config.plist.

### ProperTree (éditeur plist)

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/corpnewt/ProperTree.git
   ```
2. Lancer selon votre OS :
   - **macOS** :
     ```bash
     python3 ProperTree/ProperTree.command
     ```
   - **Linux** (Ubuntu/Debian) :
     ```bash
     sudo apt install python3-tk
     python3 ProperTree/ProperTree.py
     ```

### GenSMBIOS (générateur SMBIOS)

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/corpnewt/GenSMBIOS.git
   ```
2. Lancer :
   ```bash
   python3 GenSMBIOS/GenSMBIOS.command
   ```

---

## 4.2 – Méthode automatisée

Le script fourni génère un config.plist complet à partir du Sample.plist officiel.

```bash
./Scripts/generate-config.sh
```

- Le script copie `Sample.plist` → `config.plist`.
- Il applique **toutes** les valeurs documentées dans ce guide.
- Seuls les champs SMBIOS affichent `CHANGEME`.
- Vous devez uniquement remplacer les valeurs `CHANGEME` (voir section 4.4).

> **Recommandé** : utilisez cette méthode. La méthode manuelle (section 4.3) sert de référence.

---

## 4.3 – Méthode manuelle avec ProperTree

Ouvrez `EFI/OC/config.plist` dans ProperTree. Parcourez chaque section ci-dessous.

---

### ACPI > Add

| Fichier SSDT | Enabled | Rôle |
|---|---|---|
| SSDT-PLUG.aml | `true` | Gestion d'énergie CPU (plugin-type) |
| SSDT-EC-USBX.aml | `true` | Faux Embedded Controller + alimentation USB |

- Vérifiez que les deux fichiers sont dans `EFI/OC/ACPI/`.
- L'ordre n'a pas d'importance ici.

---

### Booter > Quirks

| Quirk | Valeur | Explication |
|---|---|---|
| AvoidRuntimeDefrag | `true` | Corrige les services UEFI au runtime |
| EnableSafeModeSlide | `true` | Autorise les valeurs slide en mode sans échec |
| EnableWriteUnprotector | `true` | Retire la protection écriture du registre CR0 |
| ProvideCustomSlide | `true` | Fournit des valeurs slide valides |
| RebuildAppleMemoryMap | `true` | Compatible avec le firmware ASUS |
| SetupVirtualMap | `true` | Requis pour la plupart des firmwares UEFI |
| SyncRuntimePermissions | `true` | Synchronise les permissions MAT (Memory Attribute Table) |

Tous les autres quirks : `false`.

---

### DeviceProperties > Add

#### Audio – ALC892

- **Chemin** : `PciRoot(0x0)/Pci(0x1B,0x0)`
- **Propriété** : `layout-id` = `01000000` (Type : **Data**)
- Ceci active le codec ALC892 intégré à la carte mère.

#### iGPU (Intel HD 4600)

- **Aucune entrée.**
- L'iGPU est désactivé dans le BIOS (nous utilisons la RX 580).

#### GPU (AMD RX 580)

- **Aucune entrée.**
- La RX 580 est un GPU **Polaris**. Elle fonctionne nativement sous macOS.
- **PAS de `agdpmod=pikera`** nécessaire.

---

### Kernel > Add

L'ordre de chargement est **critique**. Respectez cette séquence exacte :

| # | Kext | Rôle | Enabled |
|---|---|---|---|
| 1 | Lilu.kext | Framework de patches (DOIT être premier) | `true` |
| 2 | VirtualSMC.kext | Émulation SMC Apple | `true` |
| 3 | SMCProcessor.kext | Capteurs CPU | `true` |
| 4 | SMCSuperIO.kext | Capteurs ventilateurs | `true` |
| 5 | WhateverGreen.kext | Patches GPU/graphiques | `true` |
| 6 | AppleALC.kext | Audio natif | `true` |
| 7 | IntelMausi.kext | Ethernet Intel I218-V | `true` |
| 8 | AQtion.kext | Ethernet Kalea AQC113 (10 Gbps) | `true` |
| 9 | AMFIPass.kext | Contourne AMFI pour kexts OCLP | `true` |
| 10 | IOSkywalkFamily.kext | Remplace IOSkywalkFamily système | `true` |
| 11 | IO80211FamilyLegacy.kext | Framework Wi-Fi legacy | `true` |
| 12 | AirportBrcmFixup.kext | Patches Wi-Fi Broadcom | `true` |
| 13 | BlueToolFixup.kext | Fix Bluetooth Monterey+ | `true` |
| 14 | BrcmFirmwareData.kext | Firmware Bluetooth Broadcom | `true` |
| 15 | BrcmPatchRAM3.kext | Patching RAM Bluetooth | `true` |

> **Important** : Lilu.kext DOIT être en position 1. VirtualSMC.kext en position 2. Les kexts Wi-Fi/BT (9–15) doivent être après les kexts de base.

---

### Kernel > Block

| Clé | Valeur |
|---|---|
| Identifier | `com.apple.iokit.IOSkywalkFamily` |
| Comment | Block IOSkywalkFamily pour OCLP Wi-Fi |
| MinKernel | `23.0.0` |
| Strategy | `Exclude` |
| Enabled | `true` |

> **Pourquoi ?** macOS Sonoma+ utilise un nouveau framework IOSkywalkFamily incompatible avec la Fenvi T919. On bloque la version système et on charge la version OCLP (kext #10).

---

### Kernel > Quirks

| Quirk | Valeur | Explication |
|---|---|---|
| AppleCpuPmCfgLock | `true` | Contourne le CFG Lock pour la gestion d'énergie legacy |
| AppleXcpmCfgLock | `true` | Contourne le CFG Lock pour XCPM |
| DisableIoMapper | `true` | Désactive le mapping VT-d (équivalent de `dart=0`) |
| DisableLinkeditJettison | `true` | Améliore la stabilité avec Lilu et autres kexts |
| ForceAquantiaEthernet | `true` | **CRITIQUE** – Active le driver natif pour la Kalea AQC113 |
| IgnoreInvalidFlexRatio | `true` | **CRITIQUE pour Haswell** – Ignore le FlexRatio invalide au boot |
| PanicNoKextDump | `true` | Empêche le dump de kexts lors d'un kernel panic (lisibilité) |
| PowerTimeoutKernelPanic | `true` | Résout les panics liés aux timeouts d'alimentation |
| XhciPortLimit | `false` | Pas nécessaire — les ports USB sont mappés correctement |

Tous les autres quirks : `false`.

---

### Misc > Boot

| Clé | Valeur | Explication |
|---|---|---|
| ShowPicker | `true` | Affiche le menu de sélection OpenCore |
| Timeout | `5` | 5 secondes avant démarrage automatique |

---

### Misc > Debug

| Clé | Valeur | Explication |
|---|---|---|
| AppleDebug | `true` | Active les logs de démarrage Apple |
| DisableWatchDog | `true` | Désactive le watchdog timer (évite les redémarrages forcés) |
| Target | `67` | Logs écran + fichier (valeur recommandée pour le debug) |

---

### Misc > Security

| Clé | Valeur | Explication |
|---|---|---|
| SecureBootModel | `Disabled` | Désactivé — requis pour les kexts OCLP non signés |
| ScanPolicy | `0` | Affiche tous les volumes de démarrage |
| Vault | `Optional` | Pas de vérification de vault |
| AllowSetDefault | `true` | Permet de choisir le disque par défaut (Ctrl+Entrée) |

---

### NVRAM > Add > 7C436110-AB2A-4BBB-A880-FE41995C9F82

#### boot-args

```
-v keepsyms=1 debug=0x100 alcid=1 -amfipassbeta
```

Détail de chaque argument :

| Argument | Explication |
|---|---|
| `-v` | Mode verbose — affiche les logs au démarrage (utile pour le debug) |
| `keepsyms=1` | Conserve les symboles du kernel dans les logs de panic |
| `debug=0x100` | Empêche le redémarrage automatique en cas de kernel panic |
| `alcid=1` | Layout audio pour AppleALC (ALC892, layout 1) |
| `-amfipassbeta` | Active AMFIPass sur les versions beta de macOS |

> **PAS de `agdpmod=pikera`** – Ce paramètre est **uniquement** pour les GPU Navi (RX 5xxx/6xxx/7xxx). La RX 580 est un GPU **Polaris** qui fonctionne **nativement**. Ajouter ce paramètre sur un Polaris peut provoquer des problèmes graphiques.

#### csr-active-config

- **Valeur** : `03080000` (Type : **Data**)
- Désactivation **partielle** du SIP (System Integrity Protection).
- Nécessaire pour que les kexts OCLP non signés puissent se charger.

#### prev-lang:kbd

- **Valeur** : `fr-FR:252` (Type : **String**)
- Clavier français par défaut dans le picker OpenCore.

---

### PlatformInfo > Generic

Voir la section 4.4 pour générer ces valeurs.

| Clé | Valeur |
|---|---|
| SystemProductName | `iMac18,1` |
| MLB | `CHANGEME` |
| SystemSerialNumber | `CHANGEME` |
| SystemUUID | `CHANGEME` |
| ROM | `CHANGEME` |

---

### UEFI > Drivers

| # | Driver | Rôle |
|---|---|---|
| 1 | HfsPlus.efi | Support du système de fichiers HFS+ |
| 2 | OpenRuntime.efi | Runtime requis par OpenCore |
| 3 | ResetNvramEntry.efi | Option « Reset NVRAM » dans le picker |

Vérifiez que ces fichiers sont dans `EFI/OC/Drivers/`.

---

### UEFI > Quirks

| Quirk | Valeur | Explication |
|---|---|---|
| RequestBootVarRouting | `true` | Route les variables de boot vers OC au lieu du firmware |

Tous les autres quirks : `false`.

---

## 4.4 – Générer le SMBIOS

### Pourquoi iMac18,1 ?

- `iMac15,1` est le SMBIOS Haswell natif.
- Apple l'a **supprimé** à partir de macOS Ventura.
- Pour macOS Sequoia, nous utilisons `iMac18,1` (Coffee Lake).
- OpenCore fait croire à macOS que notre Haswell est un Coffee Lake.
- Ce SMBIOS est toujours **supporté** dans Sequoia.

### Étapes GenSMBIOS

1. Lancer GenSMBIOS :
   ```bash
   python3 GenSMBIOS/GenSMBIOS.command
   ```
2. Choisir l'option **1** — Télécharger MacSerial.
3. Choisir l'option **3** — Générer SMBIOS.
4. Taper : `iMac18,1`
5. GenSMBIOS affiche :

   ```
   Type:         iMac18,1
   Serial:       C02XXXXXXX
   Board Serial: C02XXXXXXXXXXXXXXX
   SmUUID:       XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   Apple ROM:    XXXXXXXXXXXX
   ```

### Correspondance avec le config.plist

| Sortie GenSMBIOS | Clé config.plist (PlatformInfo > Generic) |
|---|---|
| Type | SystemProductName → `iMac18,1` |
| Serial | SystemSerialNumber |
| Board Serial | MLB |
| SmUUID | SystemUUID |
| Apple ROM | ROM (Type : **Data**) |

### Vérification du numéro de série

1. Ouvrir : [https://checkcoverage.apple.com](https://checkcoverage.apple.com)
2. Entrer le **Serial** généré.
3. Le résultat **doit** être : **« Numéro de série non valide »** ou **« Unable to check coverage »**.
4. Si le résultat indique un vrai Mac → **regénérer un nouveau SMBIOS**.

> **Important** : ne partagez jamais vos valeurs SMBIOS. Elles sont uniques à votre machine.

---

## 4.5 – Validation

### Vérification syntaxique

```bash
plutil -lint EFI/OC/config.plist
```

- Résultat attendu : `EFI/OC/config.plist: OK`
- Si erreur : vérifiez les balises XML mal fermées dans ProperTree.

### Vérification OpenCore

```bash
./Utilities/ocvalidate EFI/OC/config.plist
```

- `ocvalidate` se trouve dans le dossier OpenCore téléchargé.
- Résultat attendu : aucune erreur.
- Les **warnings** sont acceptables. Les **errors** doivent être corrigées.

---

## Checklist de vérification

Avant de passer au Guide 5, vérifiez :

- [ ] `config.plist` est dans `EFI/OC/`
- [ ] **ACPI** : 2 SSDTs listés et activés
- [ ] **Booter** : 7 quirks activés
- [ ] **DeviceProperties** : layout-id configuré pour l'audio
- [ ] **Kernel > Add** : 15 kexts dans le bon ordre
- [ ] **Kernel > Block** : IOSkywalkFamily bloqué
- [ ] **Kernel > Quirks** : ForceAquantiaEthernet et IgnoreInvalidFlexRatio activés
- [ ] **NVRAM** : boot-args complets, csr-active-config = 03080000
- [ ] **PlatformInfo** : SMBIOS iMac18,1, valeurs uniques générées
- [ ] **UEFI** : 3 drivers listés
- [ ] `plutil -lint` retourne OK
- [ ] `ocvalidate` ne retourne aucune erreur

---

## Dépannage

| Problème | Solution |
|---|---|
| `plutil` signale une erreur de syntaxe | Ouvrir dans ProperTree, chercher les balises mal fermées |
| `ocvalidate` erreur sur un kext | Vérifier que le BundlePath correspond au nom exact du dossier .kext |
| `ocvalidate` erreur SMBIOS | Remplacer les `CHANGEME` par des valeurs GenSMBIOS |
| Le fichier est trop gros / corrompu | Repartir du Sample.plist et recommencer |
| ProperTree ne s'ouvre pas sous Linux | Installer `python3-tk` : `sudo apt install python3-tk` |

---

> **Suite** : [Guide 5 – Wi-Fi et Bluetooth – Fenvi T919 avec OCLP](Guide-05-Fenvi-WiFi-Bluetooth.md)
