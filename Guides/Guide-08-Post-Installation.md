---
title: "Guide 8 – Post-installation, OCLP et mappage USB"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 8 – Post-installation, OCLP et mappage USB

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : derniere version stable

---

## Prerequis

- macOS Sequoia installe et fonctionnel (voir [Guide 7](Guide-07-Installation-macOS.md))
- Boot depuis la cle USB via OpenCore
- Connexion Internet via Ethernet (Intel I218-V ou Kalea AQC113)
- Un peripherique USB pour le mappage (cle USB ou souris)

---

## 8.1 Copier l'EFI sur le disque interne

Actuellement, vous bootez depuis la cle USB. On va rendre le boot autonome.

### 8.1.1 Identifier les disques

```bash
diskutil list
```

Reperage rapide :

| Disque | Ce que c'est | Indice |
|--------|-------------|--------|
| `disk0` | Disque interne (SSD) | Contient "Macintosh HD" |
| `disk2` | Cle USB | Contient "Install macOS Sequoia" |
| `disk0s1` | Partition EFI du disque interne | Type : EFI |
| `disk2s1` | Partition EFI de la cle USB | Type : EFI |

> Les numeros de disque peuvent varier. Verifiez toujours avec `diskutil list`.

### 8.1.2 Monter les deux partitions EFI

```bash
# Monter la partition EFI du disque interne
sudo diskutil mount disk0s1

# Monter la partition EFI de la cle USB
sudo diskutil mount disk2s1
```

> Quand les deux EFI sont montees, elles apparaissent comme `/Volumes/EFI` et `/Volumes/EFI 1`. Verifiez laquelle est laquelle avec `ls /Volumes/EFI/EFI/OC/` -- celle qui contient votre config.plist est la cle USB.

### 8.1.3 Copier l'EFI

```bash
# Supprimer l'ancien EFI sur le disque interne (s'il existe)
sudo rm -rf "/Volumes/EFI 1/EFI"

# Copier depuis la cle USB vers le disque interne
sudo cp -R /Volumes/EFI/EFI "/Volumes/EFI 1/"
```

> Si c'est l'inverse (le disque interne est `/Volumes/EFI` et la cle USB `/Volumes/EFI 1`), adaptez les chemins.

### 8.1.4 Tester le boot sans cle USB

1. Ejectez la cle USB
2. Redemarrez le PC
3. OpenCore devrait apparaitre **depuis le disque interne**
4. Selectionnez **Macintosh HD** pour demarrer macOS

> Si ca ne boote pas : rebranchez la cle USB, rebootez, et verifiez que la copie a fonctionne. Verifiez que le dossier `/Volumes/EFI/EFI/OC/config.plist` existe bien sur le disque interne.

<!-- CAPTURE D'ECRAN : deux partitions EFI montees dans le Finder -->

---

## 8.2 Appliquer les root patches OCLP

> **ETAPE CRITIQUE.** Sans les patchs OCLP, le Wi-Fi du Fenvi T919 ne fonctionnera pas et il peut y avoir des problemes de compatibilite Metal sur Haswell.

### 8.2.1 Pourquoi c'est necessaire

Apple a retire les frameworks Wi-Fi legacy (IO80211) et certaines bibliotheques Metal dans les versions recentes de macOS. OCLP (OpenCore Legacy Patcher) reinstalle ces composants.

### 8.2.2 Telecharger OCLP

1. Telechargez la derniere version depuis : https://github.com/dortania/OpenCore-Legacy-Patcher/releases
2. Montez le `.dmg` et copiez l'application dans `/Applications/`

### 8.2.3 Appliquer les patchs

1. Ouvrez l'application **OpenCore Patcher**
2. Cliquez sur **"Post-Install Root Patch"**
3. OCLP detecte automatiquement les patchs necessaires
4. Cliquez sur **"Start Root Patching"**
5. Attendez 2 a 5 minutes (ne fermez pas l'application)
6. **Redemarrez** quand OCLP le demande

### 8.2.4 Ce que les patchs OCLP installent

| Patch | Pourquoi | Composant concerne |
|-------|----------|--------------------|
| IO80211 / IOSkywalk | Frameworks Wi-Fi legacy retires par Apple | Fenvi T919 (BCM94360CD) |
| MetallibSupportPkg | Bibliotheques Metal V27 pour GPU/iGPU Haswell | i7-4790 (Haswell) |
| Bluetooth framework patches | Support BT legacy | Fenvi T919 (BCM20702) |

### 8.2.5 Avertissement important

> **Les root patches OCLP DOIVENT etre reappliquees apres CHAQUE mise a jour de macOS.**
>
> Le Wi-Fi cessera de fonctionner apres une MAJ jusqu'a ce que les patches soient reappliquees. C'est normal. Ouvrez simplement OCLP et refaites "Post-Install Root Patch" apres chaque MAJ.

---

## 8.3 Verifications post-OCLP

Apres le redemarrage, verifiez **chaque composant** un par un. Ouvrez le Terminal.

### Audio (Realtek ALC892)

```bash
system_profiler SPAudioDataType
```

Vous devriez voir votre peripherique audio liste.

> **Si pas d'audio** : le `alcid=1` dans les boot-args ne convient peut-etre pas. Essayez d'autres valeurs dans cet ordre : `alcid=2`, `alcid=3`, `alcid=5`, `alcid=7`, `alcid=12`, `alcid=28`. Modifiez dans le config.plist, sauvegardez, redemarrez.

### Reseau Ethernet Intel I218-V

```bash
# Verifier l'interface
ifconfig en0

# Tester la connectivite
ping -c 3 apple.com
```

Vous devriez voir une adresse IP et des reponses au ping.

### Reseau 10G Kalea AQC113

```bash
# Lister toutes les interfaces reseau
ifconfig

# Chercher l'interface AQC113 (sera un autre enX)
system_profiler SPEthernetDataType
```

L'AQC113 apparait comme une interface `en` supplementaire avec "Aquantia" ou "AQtion" dans la description.

### Wi-Fi Fenvi T919 (apres patchs OCLP)

```bash
system_profiler SPAirPortDataType
```

Verifiez aussi :
- L'icone Wi-Fi apparait dans la barre de menus
- Des reseaux Wi-Fi sont visibles dans la liste
- Vous pouvez vous connecter a votre reseau

> **Si le Wi-Fi ne marche pas** : les patchs OCLP n'ont pas ete appliques correctement. Relancez OCLP > Post-Install Root Patch.

### Bluetooth Fenvi T919

```bash
system_profiler SPBluetoothDataType
```

Vous devriez voir le module Bluetooth avec "Broadcom" dans les details. Testez l'appairage avec un peripherique BT.

### GPU AMD RX 580

```bash
system_profiler SPDisplaysDataType | grep -A5 "Chipset Model"
```

Resultat attendu :
- **Chipset Model** : AMD Radeon RX 580
- **VRAM** : 8192 MB
- **Metal** : Supported

> La RX 580 (Polaris) est supportee nativement. Pas besoin de `agdpmod=pikera` (c'est pour Navi, pas Polaris).

---

## 8.4 Activer TRIM pour le SSD

TRIM ameliore les performances et la duree de vie de votre SSD.

```bash
sudo trimforce enable
```

- Tapez **y** puis Entree (premiere confirmation)
- Tapez **y** puis Entree (deuxieme confirmation)
- Le systeme redemarrera automatiquement

> Apres le redemarrage, TRIM est actif. Pas besoin de reverifier.

---

## 8.5 Mappage USB avec USBToolBox

### Pourquoi c'est necessaire

macOS limite les ports USB a **15 maximum** par controleur. L'ASUS Z97-C a plus de 15 ports logiques (USB 2.0, USB 3.0, ports internes). Sans mappage, certains ports ne fonctionneront pas ou le systeme sera instable.

### Methode A -- USBToolBox (recommandee)

```bash
cd ~/Desktop
git clone https://github.com/USBToolBox/tool.git
cd tool
python3 USBToolBox.command
```

Etapes dans l'outil :

1. **D** = Discover ports (decouvrir les ports)
2. Branchez et debranchez un peripherique USB dans **chaque port physique** du boitier (attendez 3 secondes entre chaque)
3. **S** = Show detected ports (afficher les ports detectes)
4. **C** = Create kext (creer le kext)
5. Choisissez les **15 ports les plus importants** :

| Priorite | Ports a garder |
|----------|---------------|
| Haute | Tous les ports USB 3.0 arriere (HS + SS) |
| Haute | Port interne Bluetooth (pour Fenvi T919) |
| Moyenne | 2 a 3 ports USB 2.0 arriere |
| Basse | Ports USB facade (si vous les utilisez) |

6. L'outil genere **USBMap.kext**

### Methode B -- Hackintool (alternative)

1. Telechargez [Hackintool](https://github.com/benbaker76/Hackintool/releases)
2. Ouvrez Hackintool, allez dans l'onglet **USB**
3. Identifiez les ports en branchant/debranchant des peripheriques
4. Decochez les ports inutilises (gardez **15 maximum**)
5. Exportez : cela genere **USBPorts.kext**

### Ajouter le kext a l'EFI

```bash
# Monter la partition EFI
sudo diskutil mount disk0s1

# Copier le kext genere
cp -R ~/Desktop/USBMap.kext /Volumes/EFI/EFI/OC/Kexts/
```

> **N'oubliez pas** : lancez un **OC Snapshot** dans ProperTree pour mettre a jour le config.plist apres l'ajout du kext.

```bash
python3 ~/Desktop/ProperTree/ProperTree.command /Volumes/EFI/EFI/OC/config.plist
# File > OC Snapshot > Selectionnez /Volumes/EFI/EFI/OC/
```

Sauvegardez et redemarrez.

<!-- CAPTURE D'ECRAN : USBToolBox montrant les ports detectes -->

---

## 8.6 Optimiser veille et hibernation

L'hibernation pose probleme sur les Hackintosh. Desactivez-la :

```bash
# Desactiver hibernation et fonctions de veille problematiques
sudo pmset -a hibernatemode 0
sudo pmset -a proximitywake 0
sudo pmset -a standby 0
sudo pmset -a autopoweroff 0

# Supprimer le fichier d'hibernation existant
sudo rm -f /var/vm/sleepimage

# Creer un fichier vide verrouille pour empecher la recreation
sudo mkdir -p /var/vm
sudo touch /var/vm/sleepimage
sudo chflags uchg /var/vm/sleepimage
```

### Tester la veille

1. Menu Apple > **Suspendre l'activite**
2. Attendez 10 secondes
3. Reveillez avec le clavier
4. Verifiez : ecran, USB, reseau, audio

> Si la veille ne fonctionne pas : ajoutez `darkwake=0` aux boot-args dans le config.plist.

---

## 8.7 iServices (iMessage, FaceTime)

### Verifier le numero de serie

1. Allez sur https://checkcoverage.apple.com
2. Entrez le numero de serie de votre config SMBIOS (GenSMBIOS, voir Guide 5)
3. Le resultat **doit etre invalide** ("Nous ne pouvons verifier la couverture...")
   - Si le numero est valide = il appartient a un vrai Mac. Generez-en un autre !

### Activer iMessage et FaceTime

1. Ouvrez **Reglages Systeme > Identifiant Apple**
2. Connectez-vous avec votre Apple ID
3. Ouvrez **Messages** et tentez d'activer iMessage
4. Ouvrez **FaceTime** et tentez de l'activer

> **Si iMessage ne s'active pas** : c'est frequent pour les premiers Hackintosh sur un Apple ID. Appelez le support Apple (ils peuvent debloquer l'activation). Ne mentionnez pas que c'est un Hackintosh.

---

## Verification finale

Avant de passer au guide suivant, cochez chaque element :

- [ ] L'EFI est copie sur le disque interne
- [ ] Le boot fonctionne **sans cle USB**
- [ ] Les root patches OCLP sont appliquees
- [ ] Le Wi-Fi Fenvi T919 fonctionne
- [ ] Le Bluetooth Fenvi T919 fonctionne
- [ ] L'audio fonctionne
- [ ] L'Ethernet Intel I218-V fonctionne
- [ ] L'Ethernet 10G Kalea AQC113 fonctionne
- [ ] Le GPU RX 580 est accelere (Metal supporte)
- [ ] TRIM est active sur le SSD
- [ ] Les ports USB sont mappes (15 max)
- [ ] La veille et le reveil fonctionnent

---

## Depannage

| Probleme | Solution |
|----------|----------|
| Boot impossible sans cle USB | Verifiez que l'EFI est copie sur la bonne partition (disque interne, pas un autre volume) |
| Wi-Fi ne fonctionne pas | Reappliquez les root patches OCLP. Verifiez que le Fenvi T919 est bien branche en PCIe |
| Bluetooth absent | Verifiez que le cable USB interne du Fenvi T919 est branche sur la carte mere |
| Pas d'audio | Essayez `alcid=2`, `alcid=3`, `alcid=5`, `alcid=7`, `alcid=12`, `alcid=28` dans les boot-args |
| AQC113 non detecte | Verifiez que `AQtion.kext` est present dans EFI/OC/Kexts/ et que `ForceAquantiaEthernet` est active |
| Plus de 15 ports USB | Desactivez les ports inutilises dans le mappage |
| Veille ne fonctionne pas | Verifiez les parametres `pmset` ; ajoutez `darkwake=0` aux boot-args |
| GPU non accelere | Verifiez que WhateverGreen.kext est charge. Ne pas ajouter `agdpmod=pikera` (Polaris n'en a pas besoin) |
| Kernel panic au reveil | Desactivez l'hibernation ; verifiez le mappage USB |
| iMessage ne s'active pas | Verifiez le numero de serie (doit etre invalide). Appelez le support Apple si necessaire |

---

## Etape suivante

-> [Guide 9 -- Maintenance, mises a jour et sauvegarde de l'EFI](Guide-09-Maintenance-EFI.md)
