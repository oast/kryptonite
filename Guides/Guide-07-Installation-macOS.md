---
title: "Guide 7 – Installation de macOS Sequoia"
author: "Projet Kryptonite"
date: "2026-04-01"
lang: fr
geometry: margin=2.5cm
fontsize: 11pt
toc: true
---

# Guide 7 – Installation de macOS Sequoia

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- Clé USB bootable avec EFI OpenCore (voir [Guide 6](Guide-06-Copie-EFI-USB.md))
- PC éteint avec le matériel cible installé
- Écran connecté à la **RX 580** (pas à la carte mère)
- Clavier et souris connectés en USB

---

## Étape 1 – Configuration du BIOS ASUS Z97-C

Avant de démarrer sur la clé USB, configurez le BIOS de l'ASUS Z97-C.

1. Allumez le PC et appuyez sur **F2** ou **Suppr** pour entrer dans le BIOS

2. Passez en mode **Avancé** (F7)

3. Appliquez les paramètres suivants :

### Paramètres à désactiver

| Section | Paramètre | Valeur |
|---------|-----------|--------|
| Advanced > CPU Configuration | Intel Virtualization Technology (VT-d) | **Disabled** |
| Advanced > System Agent Configuration | VT-d | **Disabled** |
| Security > Secure Boot | Secure Boot | **Disabled** |
| Boot | Fast Boot | **Disabled** |
| Advanced > CPU Configuration | CFG Lock | **Disabled** (si disponible) |

### Paramètres à activer

| Section | Paramètre | Valeur |
|---------|-----------|--------|
| Advanced > CPU Configuration | Hyper-Threading | **Enabled** |
| Advanced > System Agent Configuration > Graphics Configuration | Primary Display | **PEG** (PCIe GPU) |
| Advanced > System Agent Configuration > Graphics Configuration | iGPU Multi-Monitor | **Disabled** |
| Boot | OS Type | **Other OS** |
| Boot > CSM (Compatibility Support Module) | Launch CSM | **Disabled** |
| Advanced > USB Configuration | XHCI Hand-off | **Enabled** |
| Advanced > USB Configuration | EHCI Hand-off | **Enabled** |

> ⚠️ **CFG Lock** : Si vous ne trouvez pas l'option CFG Lock dans le BIOS, laissez les quirks `AppleCpuPmCfgLock` et `AppleXcpmCfgLock` à `true` dans le config.plist (Guide 5).

4. Sauvegardez et quittez (**F10**)

<!-- 📸 Capture d'écran : BIOS ASUS Z97-C avec les paramètres configurés -->

---

## Étape 2 – Démarrer sur la clé USB

1. Branchez la clé USB sur un **port USB 2.0** de préférence (plus fiable pour le boot)

2. Allumez le PC et appuyez sur **F8** pour accéder au menu de boot

3. Sélectionnez votre clé USB dans la liste :
   - Elle apparaît comme `UEFI: [nom de la clé USB]`
   - **Ne sélectionnez pas** l'entrée sans le préfixe `UEFI:`

> ⚠️ **Important** : Si la clé USB n'apparaît pas, vérifiez que CSM est désactivé et que le mode UEFI est actif.

<!-- 📸 Capture d'écran : menu de boot ASUS Z97-C avec la clé USB sélectionnée -->

---

## Étape 3 – Boot OpenCore

1. Le menu OpenCore s'affiche. Vous devriez voir :
   - `Install macOS Sequoia` (c'est l'installateur sur votre clé USB)
   - D'autres entrées éventuelles (disques existants)

2. Sélectionnez **Install macOS Sequoia** et appuyez sur **Entrée**

3. Le démarrage en mode verbose (si `-v` est dans vos boot-args) affiche des lignes de texte défilantes. C'est normal.

4. Attendez que l'écran de bienvenue de l'installateur macOS apparaisse.

> Le premier boot peut prendre **5 à 10 minutes**. Ne paniquez pas si le texte semble s'arrêter sur une ligne pendant un moment.

<!-- 📸 Capture d'écran : menu OpenCore avec Install macOS Sequoia sélectionné -->

---

## Étape 4 – Préparer le disque d'installation

1. Dans l'installateur, sélectionnez **Utilitaire de disque** dans le menu

2. Dans le menu **Présentation**, sélectionnez **Afficher tous les appareils**

3. Sélectionnez votre **disque interne** (le SSD/HDD où vous voulez installer macOS)

> ⚠️ **Attention** : ne sélectionnez pas la clé USB ni une partition, mais bien le disque physique entier.

4. Cliquez sur **Effacer** :
   - **Nom** : `Macintosh HD` (ou le nom de votre choix)
   - **Format** : `APFS`
   - **Schéma** : `Table de partition GUID`

5. Cliquez sur **Effacer**, puis fermez l'Utilitaire de disque

<!-- 📸 Capture d'écran : Utilitaire de disque formatant le disque interne en APFS -->

---

## Étape 5 – Installer macOS Sequoia

1. De retour dans l'installateur, sélectionnez **Installer macOS Sequoia**

2. Acceptez les termes du contrat de licence

3. Sélectionnez le disque que vous venez de formater (`Macintosh HD`)

4. L'installation commence :
   - **Phase 1** : copie des fichiers (15-30 minutes)
   - Le PC va **redémarrer automatiquement** plusieurs fois

> ⚠️ **À chaque redémarrage**, vous devez sélectionner la bonne entrée dans le menu OpenCore. Après le premier redémarrage, sélectionnez **macOS Installer** (pas « Install macOS Sequoia »).

5. Après 2-3 redémarrages, sélectionnez **Macintosh HD** dans le menu OpenCore

6. L'assistant de configuration macOS s'affiche : macOS Sequoia est installé !

<!-- 📸 Capture d'écran : sélection du disque d'installation -->

---

## Étape 6 – Configuration initiale de macOS

1. Sélectionnez votre **pays** et **langue**
2. Configurez le **réseau** (Ethernet devrait fonctionner automatiquement avec IntelMausi)
3. Créez votre **compte utilisateur**
4. Ignorez ou configurez les autres options selon vos préférences :
   - Apple ID : vous pouvez le configurer plus tard
   - Localisation : selon vos préférences
   - Siri : selon vos préférences

> ⚠️ **Ne connectez pas votre Apple ID** pour le moment. Attendez d'avoir vérifié que le SMBIOS fonctionne correctement (numéro de série non valide chez Apple).

---

## Étape 7 – Vérifier le boot via OpenCore

À ce stade, vous bootez toujours depuis la **clé USB**. Il faut vérifier que tout fonctionne :

1. Ouvrez **À propos de ce Mac** (menu Apple > À propos de ce Mac) :
   - Vérifiez : `iMac (Retina 5K, 27-inch, Late 2014)` (iMac15,1)
   - Processeur : Intel Core i7
   - Mémoire : votre RAM installée
   - Graphiques : AMD Radeon RX 580 8 Go

2. Ouvrez le **Terminal** et vérifiez quelques points :

```bash
# Version de macOS
sw_vers

# Informations système
system_profiler SPHardwareDataType

# État du GPU
system_profiler SPDisplaysDataType
```

<!-- 📸 Capture d'écran : À propos de ce Mac montrant les informations système -->

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] macOS Sequoia est installé et démarre correctement
- [ ] Le boot se fait via OpenCore depuis la clé USB
- [ ] Le GPU RX 580 est reconnu avec accélération graphique
- [ ] L'Ethernet fonctionne (IntelMausi)
- [ ] Le système est stable (pas de kernel panic)

---

## Dépannage

| Problème | Solution |
|----------|----------|
| Écran noir après le menu OpenCore | Vérifiez que l'écran est branché sur la RX 580 ; ajoutez `agdpmod=pikera` aux boot-args |
| Kernel panic au démarrage | Photographiez l'écran de panic ; vérifiez l'ordre des kexts dans le config.plist |
| L'installateur ne voit pas le disque | Reformatez le disque en APFS dans l'Utilitaire de disque |
| Redémarrage en boucle | Ajoutez `debug=0x100` aux boot-args pour empêcher le reboot automatique |
| Pas de réseau | Vérifiez que IntelMausi.kext est bien chargé |
| Clé USB non détectée au boot | Essayez un autre port USB ; vérifiez CSM désactivé |
| Installation très lente | C'est normal pour une clé USB 2.0 ; utilisez USB 3.0 si possible |

---

## Étape suivante

→ [Guide 8 – Post-installation et mappage USB](Guide-08-Post-Installation-USB.md)
