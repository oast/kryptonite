---
title: "Guide 5 – Wi-Fi et Bluetooth – Fenvi T919 avec OCLP"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 5 – Wi-Fi et Bluetooth – Fenvi T919 avec OCLP

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## 5.1 Pourquoi OCLP est nécessaire

Apple a supprimé le support natif du Wi-Fi Broadcom à partir de **macOS Sonoma 14.0**.

- Le Fenvi T919 utilise la puce **Broadcom BCM4360CD**
- Sans patches : **aucun Wi-Fi, aucun Bluetooth** sous Sequoia
- **OCLP** (OpenCore Legacy Patcher) réinjecte les frameworks Wi-Fi/BT supprimés
- Les root patches doivent être **réappliquées après chaque mise à jour macOS**

### Ce que fait OCLP concrètement

| Action | Détail |
|--------|--------|
| Bloque IOSkywalkFamily système | Remplacé par la version OCLP compatible BCM4360 |
| Injecte IO80211FamilyLegacy | Framework Wi-Fi legacy nécessaire pour BCM4360 |
| Désactive partiellement SIP | Permet le chargement de kexts non signés |
| Contourne AMFI | Autorise les patches système via AMFIPass |

---

## 5.2 Kexts requis (7 kexts)

| # | Kext | Source | Rôle |
|---|------|--------|------|
| 1 | AMFIPass.kext | dortania/OCLP | Contourne AMFI pour charger les kexts legacy |
| 2 | IOSkywalkFamily.kext | dortania/OCLP | Remplace la version système (bloquée via Kernel > Block) |
| 3 | IO80211FamilyLegacy.kext | dortania/OCLP | Framework Wi-Fi legacy pour Broadcom |
| 4 | AirportBrcmFixup.kext | acidanthera | Patches spécifiques Wi-Fi Broadcom |
| 5 | BlueToolFixup.kext | acidanthera/BrcmPatchRAM | Fix Bluetooth pour Monterey et ultérieur |
| 6 | BrcmFirmwareData.kext | acidanthera/BrcmPatchRAM | Upload du firmware Bluetooth vers la puce |
| 7 | BrcmPatchRAM3.kext | acidanthera/BrcmPatchRAM | Patching de la RAM Bluetooth |

> **Important** : Ces 7 kexts s'ajoutent aux 8 kexts de base (Guide 3). Total : **15 kexts**.

---

## 5.3 Installation des kexts

### Méthode automatisée (recommandée)

```bash
cd Guides
chmod +x Scripts/setup-fenvi.sh
./Scripts/setup-fenvi.sh
```

Le script télécharge les 7 kexts et les copie dans `EFI/OC/Kexts/`.

### Méthode manuelle

**Kexts acidanthera** (télécharger les dernières releases) :

```bash
KEXTS_DIR="Hackintosh-EFI/EFI/OC/Kexts"

# AirportBrcmFixup
curl -qLs https://api.github.com/repos/acidanthera/AirportBrcmFixup/releases/latest \
  | grep browser_download_url | head -1 | sed -E 's/.*"([^"]+)".*/\1/' \
  | xargs curl -qLs -o /tmp/AirportBrcmFixup.zip
unzip -q -o /tmp/AirportBrcmFixup.zip -d /tmp/AirportBrcmFixup
cp -R /tmp/AirportBrcmFixup/AirportBrcmFixup.kext "$KEXTS_DIR/"

# BrcmPatchRAM (contient BlueToolFixup, BrcmFirmwareData, BrcmPatchRAM3)
curl -qLs https://api.github.com/repos/acidanthera/BrcmPatchRAM/releases/latest \
  | grep browser_download_url | head -1 | sed -E 's/.*"([^"]+)".*/\1/' \
  | xargs curl -qLs -o /tmp/BrcmPatchRAM.zip
unzip -q -o /tmp/BrcmPatchRAM.zip -d /tmp/BrcmPatchRAM
cp -R /tmp/BrcmPatchRAM/BlueToolFixup.kext "$KEXTS_DIR/"
cp -R /tmp/BrcmPatchRAM/BrcmFirmwareData.kext "$KEXTS_DIR/"
cp -R /tmp/BrcmPatchRAM/BrcmPatchRAM3.kext "$KEXTS_DIR/"
```

**Kexts OCLP** (AMFIPass, IOSkywalkFamily, IO80211FamilyLegacy) :

Ces kexts sont extraits de la release OCLP. Téléchargez la dernière version depuis :
https://github.com/dortania/OpenCore-Legacy-Patcher/releases

Extrayez les kexts depuis le package OCLP et copiez-les dans `EFI/OC/Kexts/`.

---

## 5.4 Modifications du Config.plist

Ouvrez `EFI/OC/config.plist` dans ProperTree et appliquez ces modifications :

### Kernel > Add (ordre de chargement)

Ajoutez les 7 kexts **après** les 8 kexts de base, dans cet ordre exact :

| # | BundlePath | Enabled |
|---|------------|---------|
| 9 | AMFIPass.kext | true |
| 10 | IOSkywalkFamily.kext | true |
| 11 | IO80211FamilyLegacy.kext | true |
| 12 | AirportBrcmFixup.kext | true |
| 13 | BlueToolFixup.kext | true |
| 14 | BrcmFirmwareData.kext | true |
| 15 | BrcmPatchRAM3.kext | true |

> **Astuce** : Utilisez OC Snapshot dans ProperTree (Cmd+R / Ctrl+R) pour ajouter automatiquement tous les kexts du dossier.

### Kernel > Block

Ajoutez une entrée pour bloquer le IOSkywalkFamily système :

| Clé | Valeur |
|-----|--------|
| Identifier | `com.apple.iokit.IOSkywalkFamily` |
| Comment | Block IOSkywalkFamily pour OCLP Wi-Fi |
| MinKernel | `23.0.0` |
| Strategy | `Exclude` |
| Enabled | `true` |

**Pourquoi ?** Le IOSkywalkFamily système est incompatible avec BCM4360. On le bloque pour utiliser la version OCLP qui supporte notre puce.

### NVRAM > boot-args

Ajoutez `-amfipassbeta` aux boot-args :

```
-v keepsyms=1 debug=0x100 alcid=1 -amfipassbeta
```

| Flag | Rôle |
|------|------|
| `-amfipassbeta` | Active AMFIPass pour permettre le chargement des kexts OCLP non signés |

### NVRAM > csr-active-config

Valeur : `03080000` (type Data)

Cela désactive partiellement SIP :
- Autorise les kexts non signés (bit 0)
- Autorise les modifications du système de fichiers (bit 1)
- Autorise le chargement d'extensions tierces (bit 11)

> **Note** : Un SIP complètement désactivé (`FF0F0000`) n'est PAS nécessaire. `03080000` suffit.

### Misc > Security > SecureBootModel

Valeur : `Disabled`

Nécessaire car les kexts OCLP ne sont pas signés par Apple.

---

## 5.5 Root Patches OCLP (post-installation)

> **Cette étape se fait APRÈS l'installation de macOS** (Guide 8).

1. Téléchargez OCLP depuis https://github.com/dortania/OpenCore-Legacy-Patcher/releases
2. Ouvrez l'application OCLP
3. Cliquez sur **« Post-Install Root Patch »**
4. Acceptez les modifications (mot de passe administrateur requis)
5. Attendez la fin de l'installation (2-5 minutes)
6. **Redémarrez** quand demandé

### Ce que les root patches installent

- Remplacement du framework Wi-Fi système par la version legacy
- Patches du framework Bluetooth
- MetallibSupportPkg pour la compatibilité Metal V27 (Haswell)

### Après chaque mise à jour macOS

Les root patches sont **effacées** par les mises à jour macOS. Procédure obligatoire :

1. Installer la mise à jour macOS normalement
2. Redémarrer
3. Ouvrir OCLP → **Post-Install Root Patch**
4. Redémarrer

> **Le Wi-Fi cessera de fonctionner après chaque MAJ jusqu'à ce que les patches soient réappliquées.**

---

## 5.6 Vérification

### Wi-Fi

```bash
# Vérifier le module Wi-Fi
system_profiler SPAirPortDataType
```

- Le menu Wi-Fi doit afficher les réseaux disponibles
- Carte : `Broadcom BCM43xx`
- Protocoles supportés : 802.11a/b/g/n/ac

### Bluetooth

```bash
# Vérifier le module Bluetooth
system_profiler SPBluetoothDataType
```

- Bluetooth doit être activé dans Réglages Système
- Appareil : `Broadcom`
- Version LMP attendue : `0x6` ou supérieur

### AirDrop et Handoff

- **AirDrop** : Ouvrir le Finder → AirDrop. D'autres appareils Apple doivent être visibles.
- **Handoff** : Réglages Système → Général → AirDrop et Handoff → Activer

> AirDrop nécessite que Wi-Fi ET Bluetooth fonctionnent simultanément.

### Kexts chargés

```bash
kextstat | grep -i -E "brcm|airport|bluetooth|amfi|skywalk|80211"
```

Vous devez voir les 7 kexts listés comme chargés.

---

## 5.7 Dépannage

| Problème | Cause probable | Solution |
|----------|---------------|----------|
| Wi-Fi absent du menu | Root patches non appliquées | Ouvrir OCLP → Post-Install Root Patch → Redémarrer |
| Wi-Fi disparu après MAJ macOS | Root patches effacées | Réappliquer les root patches OCLP |
| Bluetooth ne s'active pas | BrcmPatchRAM3 non chargé | Vérifier : `kextstat \| grep -i brcm` |
| Bluetooth appairage échoue | Firmware non uploadé | Vérifier BrcmFirmwareData.kext dans Kernel > Add |
| AirDrop ne fonctionne pas | Wi-Fi ou BT manquant | Vérifier que les deux fonctionnent, même Apple ID |
| « Périphérique Wi-Fi non installé » | IOSkywalkFamily non bloqué | Vérifier Kernel > Block dans config.plist |
| Kernel panic au boot | Ordre des kexts incorrect | Vérifier l'ordre (AMFIPass avant IOSkywalk avant IO80211) |
| AMFI violation au boot | -amfipassbeta manquant | Ajouter `-amfipassbeta` aux boot-args |

---

## Checklist de validation

- [ ] 7 kexts Fenvi copiés dans `EFI/OC/Kexts/`
- [ ] Kernel > Add : 7 kexts ajoutés dans le bon ordre
- [ ] Kernel > Block : IOSkywalkFamily bloqué
- [ ] boot-args contient `-amfipassbeta`
- [ ] csr-active-config = `03080000`
- [ ] SecureBootModel = `Disabled`
- [ ] Root patches OCLP appliquées (après installation)
- [ ] Wi-Fi fonctionne et affiche les réseaux
- [ ] Bluetooth fonctionne et peut appairer des périphériques
- [ ] AirDrop visible

---

→ Guide suivant : [Guide 6 – Copie de l'EFI sur la clé USB](Guide-06-Copie-EFI-USB.md)

← Guide précédent : [Guide 4 – Config.plist](Guide-04-Config-Plist.md)
