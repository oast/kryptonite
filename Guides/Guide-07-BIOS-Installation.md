---
title: "Guide 7 – Configuration BIOS et installation de macOS Sequoia"
author: "Projet Kryptonite"
date: "2026-04-02"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 7 – Configuration BIOS et installation de macOS Sequoia

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | Fenvi T919 | Kalea AQC113 | macOS Sequoia
> **SMBIOS** : iMac18,1 | **OpenCore** : dernière version stable

---

## 7.1 Configuration du BIOS ASUS Z97-C

### Prérequis

- Écran connecté à la **RX 580** (PAS à la sortie vidéo de la carte mère)
- Clavier et souris branchés en USB
- Clé USB d'installation prête (Guides 2-6)

### Accéder au BIOS

1. Allumez le PC
2. Appuyez sur **F2** ou **Suppr** dès l'affichage du logo ASUS
3. Passez en **mode Avancé** avec **F7**

### Paramètres à DÉSACTIVER

| Section BIOS | Paramètre | Valeur | Raison |
|--------------|-----------|--------|--------|
| Advanced > CPU Configuration | Intel Virtualization Technology (VT-d) | **Disabled** | Conflit avec macOS I/O mapper |
| Advanced > System Agent Configuration | VT-d | **Disabled** | Même raison (doublon sur certains BIOS) |
| Security > Secure Boot | Secure Boot | **Disabled** | Incompatible OpenCore |
| Boot | Fast Boot | **Disabled** | Empêche la détection USB au boot |
| Boot > CSM | Launch CSM | **Disabled** | macOS nécessite UEFI pur |
| Advanced > CPU Configuration | CFG Lock | **Disabled** | Si visible (voir note ci-dessous) |

### Paramètres à ACTIVER

| Section BIOS | Paramètre | Valeur | Raison |
|--------------|-----------|--------|--------|
| Advanced > CPU Configuration | Hyper-Threading | **Enabled** | Utiliser les 8 threads du i7-4790 |
| Advanced > System Agent > Graphics | Primary Display | **PEG** | Boot sur la RX 580 (slot PCIe) |
| Advanced > System Agent > Graphics | iGPU Multi-Monitor | **Disabled** | Pas besoin de l'iGPU |
| Boot | OS Type | **Other OS** | Évite les restrictions Windows |
| Advanced > USB Configuration | XHCI Hand-off | **Enabled** | Transfert contrôleur USB 3.0 à macOS |
| Advanced > USB Configuration | EHCI Hand-off | **Enabled** | Transfert contrôleur USB 2.0 à macOS |
| **Advanced > SATA Configuration** | **SATA Mode** | **AHCI** | **OBLIGATOIRE** |

> **SATA Mode AHCI** : Si votre BIOS est en mode IDE ou RAID, le SSD ne sera pas détecté par macOS. Le mode **AHCI est obligatoire**. Changer ce paramètre peut rendre un Windows existant non bootable — sauvegardez d'abord.

### Note sur CFG Lock

Le paramètre CFG Lock n'est **pas visible** sur tous les BIOS ASUS Z97-C. Si vous ne le trouvez pas, pas de panique : les quirks `AppleCpuPmCfgLock` et `AppleXcpmCfgLock` sont déjà activés dans le config.plist (Guide 4) pour contourner ce verrouillage.

### Sauvegarder et quitter

Appuyez sur **F10** → **Yes** pour sauvegarder et redémarrer.

<!-- CAPTURE D'ÉCRAN : BIOS ASUS Z97-C en mode Avancé -->

---

## 7.2 Démarrer sur la clé USB

1. Branchez la clé USB dans un **port USB 2.0** (plus fiable pour le boot)
2. Allumez le PC
3. Appuyez sur **F8** pour le menu de boot
4. Sélectionnez **« UEFI: [Nom de votre clé USB] »**

### La clé USB n'apparaît pas ?

| Vérification | Action |
|-------------|--------|
| CSM désactivé ? | BIOS → Boot → CSM → Disabled |
| Mode UEFI ? | La clé doit être formatée en GPT |
| Port USB ? | Essayez un autre port (USB 2.0 de préférence) |
| EFI présent ? | Vérifiez que `EFI/BOOT/BOOTx64.efi` existe sur la clé |

---

## 7.3 OpenCore Boot Picker

L'écran OpenCore apparaît avec plusieurs options :

- **Install macOS Sequoia** → Si vous avez créé la clé depuis macOS (installeur complet)
- **EFI Boot** / **Recovery** → Si vous avez créé la clé depuis Linux (recovery)
- **Reset NVRAM** → Utile en cas de problème de boot précédent

Sélectionnez l'option d'installation et appuyez sur **Entrée**.

### Mode verbose (-v)

Le boot-arg `-v` est activé : vous verrez du texte défiler rapidement. C'est **normal**. Le premier boot prend **5-10 minutes**. Ne paniquez pas tant que le texte continue de défiler.

<!-- CAPTURE D'ÉCRAN : OpenCore Boot Picker -->

---

## 7.4 Préparer le disque d'installation

Une fois l'installeur macOS chargé :

1. Dans la barre de menu : **Utilitaire de disque** (Disk Utility)
2. Menu **Présentation** → **Afficher tous les appareils**
3. Sélectionnez le **disque physique interne** (PAS la clé USB, PAS une partition)
4. Cliquez **Effacer** avec ces paramètres :

| Paramètre | Valeur |
|-----------|--------|
| Nom | `Macintosh HD` |
| Format | **APFS** |
| Schéma | **Table de partition GUID** |

5. Cliquez **Effacer** et attendez la confirmation
6. Fermez l'Utilitaire de disque

> **Attention** : Cela efface TOUT le contenu du disque sélectionné. Assurez-vous de choisir le bon disque.

<!-- CAPTURE D'ÉCRAN : Utilitaire de disque – Effacer en APFS -->

---

## 7.5 Installer macOS Sequoia

1. Sélectionnez **« Installer macOS Sequoia »**
2. Acceptez la licence
3. Sélectionnez **Macintosh HD** comme destination
4. L'installation commence

### Phases d'installation

L'installation se déroule en **plusieurs phases avec des redémarrages** :

| Phase | Durée estimée | Action au redémarrage |
|-------|--------------|----------------------|
| Phase 1 – Copie des fichiers | 15-30 min | Redémarrage automatique |
| Phase 2 – Préparation | 5-10 min | Dans le picker OC : sélectionnez **« macOS Installer »** |
| Phase 3 – Installation | 10-20 min | Dans le picker OC : sélectionnez **« macOS Installer »** |
| Phase finale | 5 min | Dans le picker OC : sélectionnez **« Macintosh HD »** |

> **À CHAQUE redémarrage** : le PC revient au picker OpenCore. Sélectionnez **« macOS Installer »** (PAS « Install macOS Sequoia ») jusqu'à ce que cette option disparaisse. Ensuite, sélectionnez **« Macintosh HD »**.

### Installation depuis Linux (recovery)

Si vous avez créé la clé USB depuis Linux avec macrecovery :

- L'installation **télécharge ~12 Go** depuis Internet
- Une **connexion Ethernet filaire est OBLIGATOIRE** (le Wi-Fi Fenvi ne fonctionne pas encore)
- Utilisez le port Ethernet Intel I218-V intégré (IntelMausi.kext)
- Durée totale plus longue : **1-2 heures** selon la connexion

---

## 7.6 Configuration initiale de macOS

Après le dernier redémarrage, macOS Sequoia démarre pour la première fois :

1. **Pays** : France
2. **Langue** : Français
3. **Réseau** : L'Ethernet Intel devrait être détecté automatiquement
   - Ne vous connectez PAS en Wi-Fi (pas encore configuré)
4. **Migration** : « Ne pas transférer maintenant »
5. **Compte Apple** : **Ignorez cette étape** (configurez plus tard, voir Guide 8 section 8.7)
6. **Créez un compte utilisateur local**
7. Terminez la configuration

> **Ne connectez PAS votre Apple ID maintenant.** Attendez d'avoir vérifié que le SMBIOS est correctement configuré (Guide 8, section 8.7) pour éviter un blocage de compte.

---

## 7.7 Vérifier le boot OpenCore

### À propos de ce Mac

Menu Apple → **À propos de ce Mac** :

- Modèle : **iMac (Retina 5K, 27 pouces, 2017)** — c'est l'identité iMac18,1, normal
- Processeur : Intel Core i7 (affiché comme tel malgré le spoof)
- Mémoire : 24 Go
- Graphique : AMD Radeon RX 580 8192 Mo

### Vérifications Terminal

```bash
# Version macOS
sw_vers

# Informations matérielles
system_profiler SPHardwareDataType

# GPU
system_profiler SPDisplaysDataType

# Ethernet
ifconfig en0
ping -c 3 apple.com
```

Le GPU doit afficher **« AMD Radeon RX 580 »** avec **Metal supporté**.

---

## 7.8 Dépannage

| Problème | Cause probable | Solution |
|----------|---------------|----------|
| Écran noir au boot | GPU non détecté | Vérifiez câble sur RX 580, pas sur carte mère |
| Kernel panic `IOPCIFamily` | VT-d activé dans le BIOS | Désactivez VT-d |
| Kernel panic au boot | Config.plist incorrect | Vérifiez avec ocvalidate, comparez au Guide 4 |
| Disque non visible dans Disk Utility | SATA pas en AHCI | BIOS → SATA Mode → AHCI |
| Boot loop (redémarre en boucle) | Kext manquant ou incompatible | Vérifiez les 15 kexts et leur ordre |
| Pas de réseau pendant l'installation | IntelMausi.kext manquant | Vérifiez la présence du kext dans EFI |
| Installer « macOS Installer » absent | Phase terminée | Sélectionnez « Macintosh HD » |
| Erreur « This copy of macOS is damaged » | Date système incorrecte | Terminal (recovery) : `date 040212002026` |
| Freeze au logo Apple | RAM incompatible | Testez avec un seul module RAM |

### En cas de kernel panic

1. Notez les dernières lignes affichées (mode verbose actif)
2. Cherchez le nom du kext responsable dans le panic log
3. Vérifiez que ce kext est à jour et compatible Sequoia
4. Consultez les forums : r/hackintosh, InsanelyMac

---

## Checklist de validation

- [ ] BIOS configuré (VT-d off, CSM off, AHCI, XHCI Hand-off on)
- [ ] Boot depuis la clé USB via F8
- [ ] OpenCore picker visible
- [ ] Disque interne effacé en APFS + GUID
- [ ] Installation terminée (toutes les phases)
- [ ] macOS Sequoia démarre depuis « Macintosh HD »
- [ ] GPU RX 580 reconnu avec Metal
- [ ] Ethernet Intel fonctionne
- [ ] Compte utilisateur créé
- [ ] Apple ID NON connecté (pour l'instant)

---

→ Guide suivant : [Guide 8 – Post-installation et OCLP](Guide-08-Post-Installation.md)

← Guide précédent : [Guide 6 – Copie de l'EFI sur la clé USB](Guide-06-Copie-EFI-USB.md)
