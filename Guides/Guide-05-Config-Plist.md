# Guide 5 – Création et personnalisation du Config.plist

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- Dossier EFI assemblé (voir [Guide 4](Guide-04-Assemblage-EFI.md))
- [ProperTree](https://github.com/corpnewt/ProperTree) – éditeur de plist
- [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) – générateur de numéros de série

---

## Étape 1 – Installer les outils

### ProperTree (éditeur de plist)

```bash
cd ~/Desktop/Hackintosh-Sequoia
git clone https://github.com/corpnewt/ProperTree.git
```

Pour lancer ProperTree :

```bash
# Sur macOS
python3 ProperTree/ProperTree.command

# Sur Windows
python ProperTree/ProperTree.bat
```

### GenSMBIOS (générateur de numéros de série)

```bash
git clone https://github.com/corpnewt/GenSMBIOS.git
```

<!-- 📸 Capture d'écran : interface ProperTree -->

---

## Étape 2 – Créer le Config.plist depuis le modèle

1. Dans l'archive OpenCore, localisez le fichier `Sample.plist` :

```bash
cp ~/Downloads/OpenCore-RELEASE/Docs/Sample.plist EFI/OC/config.plist
```

2. Ouvrez `config.plist` avec ProperTree :

```bash
python3 ProperTree/ProperTree.command EFI/OC/config.plist
```

3. **Utilisez OC Snapshot** (menu `File > OC Snapshot`) et pointez vers votre dossier `EFI/OC/`. ProperTree va automatiquement détecter vos kexts, drivers et tables ACPI, et les ajouter au config.plist.

> ⚠️ **OC Snapshot est essentiel** : il garantit que tous vos fichiers sont correctement référencés dans le config.plist.

<!-- 📸 Capture d'écran : menu OC Snapshot dans ProperTree -->

---

## Étape 3 – Configurer les sections du Config.plist

### 3.1 – Section ACPI

Les tables SSDT sont automatiquement ajoutées par OC Snapshot. Vérifiez que vous avez :

```xml
<key>ACPI</key>
<dict>
    <key>Add</key>
    <array>
        <dict>
            <key>Enabled</key>
            <true/>
            <key>Path</key>
            <string>SSDT-PLUG.aml</string>
        </dict>
        <dict>
            <key>Enabled</key>
            <true/>
            <key>Path</key>
            <string>SSDT-EC-USBX.aml</string>
        </dict>
    </array>
</dict>
```

### 3.2 – Section Booter

Paramètres importants pour Haswell :

| Clé | Valeur | Explication |
|-----|--------|-------------|
| `AvoidRuntimeDefrag` | `true` | Corrige les services UEFI |
| `EnableSafeModeSlide` | `true` | Permet le mode sans échec |
| `ProvideCustomSlide` | `true` | Assure des valeurs de slide valides |
| `RebuildAppleMemoryMap` | `true` | Compatible avec le firmware ASUS |
| `SetupVirtualMap` | `true` | Requis pour la plupart des firmwares |
| `SyncRuntimePermissions` | `true` | Corrige les permissions MAT |

### 3.3 – Section DeviceProperties

#### GPU AMD RX 580

La RX 580 est nativement supportée, mais ajoutez WhateverGreen pour la stabilité :

```xml
<key>DeviceProperties</key>
<dict>
    <key>Add</key>
    <dict>
        <!-- Pas besoin d'entrée PCI spécifique pour la RX 580 -->
        <!-- WhateverGreen gère automatiquement le framebuffer -->
    </dict>
</dict>
```

> Si vous n'utilisez pas l'iGPU (notre cas), ne configurez **aucune** propriété pour `PciRoot(0x0)/Pci(0x2,0x0)`.

#### Audio Realtek ALC892

```xml
<key>PciRoot(0x0)/Pci(0x1B,0x0)</key>
<dict>
    <key>layout-id</key>
    <data>AQAAAA==</data>
    <!-- layout-id = 1, fonctionne avec la plupart des ALC892 -->
    <!-- Essayez aussi 2, 3, 5, 7, 12, 28 si l'audio ne fonctionne pas -->
</dict>
```

### 3.4 – Section Kernel

Les kexts sont ajoutés automatiquement par OC Snapshot. Vérifiez l'**ordre de chargement** :

1. `Lilu.kext` (toujours en premier)
2. `VirtualSMC.kext`
3. `SMCProcessor.kext`
4. `SMCSuperIO.kext`
5. `WhateverGreen.kext`
6. `AppleALC.kext`
7. `IntelMausi.kext`
8. `AQtion.kext`

Paramètres Kernel importants :

| Clé | Valeur | Explication |
|-----|--------|-------------|
| `Quirks > AppleCpuPmCfgLock` | `true` | Contourne le verrou CFG si non désactivé dans le BIOS |
| `Quirks > AppleXcpmCfgLock` | `true` | Même chose pour XCPM |
| `Quirks > DisableIoMapper` | `true` | Désactive VT-d (si non désactivé dans le BIOS) |
| `Quirks > PanicNoKextDump` | `true` | Facilite le diagnostic en cas de kernel panic |
| `Quirks > PowerTimeoutKernelPanic` | `true` | Corrige les panics liées à l'alimentation |

> ⚠️ **CFG Lock** : Si vous pouvez désactiver le CFG Lock dans le BIOS de l'ASUS Z97-C, mettez `AppleCpuPmCfgLock` et `AppleXcpmCfgLock` à `false`.

### 3.5 – Section Misc

| Clé | Valeur | Explication |
|-----|--------|-------------|
| `Boot > HideAuxiliary` | `true` | Cache les entrées de boot auxiliaires |
| `Debug > AppleDebug` | `false` | Pas de logs Apple en production |
| `Debug > DisableWatchDog` | `true` | Évite les redémarrages pendant le boot |
| `Debug > Target` | `3` | Logs console + fichier (67 pour debug complet) |
| `Security > AllowSetDefault` | `true` | Permet de définir le disque de boot par défaut |
| `Security > ScanPolicy` | `0` | Scanne tous les disques |
| `Security > SecureBootModel` | `Default` | Active le Secure Boot Apple |
| `Security > Vault` | `Optional` | Pas de vault pour commencer |

### 3.6 – Section NVRAM

```xml
<key>NVRAM</key>
<dict>
    <key>Add</key>
    <dict>
        <key>7C436110-AB2A-4BBB-A880-FE41995C9F82</key>
        <dict>
            <key>boot-args</key>
            <string>-v keepsyms=1 debug=0x100 alcid=1</string>
            <!-- -v : mode verbose (affiche les logs au démarrage) -->
            <!-- keepsyms=1 : conserve les symboles en cas de panic -->
            <!-- debug=0x100 : empêche le redémarrage en cas de panic -->
            <!-- alcid=1 : layout-id pour AppleALC -->

            <key>prev-lang:kbd</key>
            <data>ZnItRlI=</data>
            <!-- fr-FR : clavier français -->
        </dict>
    </dict>
</dict>
```

> ⚠️ **Après une installation réussie**, retirez `-v` des boot-args pour un démarrage normal (sans logs).

### 3.7 – Section PlatformInfo

Cette section sera configurée à l'étape suivante avec GenSMBIOS.

---

## Étape 4 – Générer le SMBIOS avec GenSMBIOS

Le SMBIOS définit le profil matériel que macOS voit. Pour notre configuration (Haswell + GPU dédié), le modèle est **iMac15,1**.

1. Lancez GenSMBIOS :

```bash
python3 GenSMBIOS/GenSMBIOS.command
```

2. Sélectionnez l'option **1** pour télécharger MacSerial
3. Sélectionnez l'option **3** pour générer un SMBIOS
4. Tapez `iMac15,1` quand demandé

5. Vous obtiendrez des valeurs comme :

```
  #######################################################
 #              iMac15,1 SMBIOS Info                   #
#######################################################

Type:         iMac15,1
Serial:       C02XXXXXXXXX
Board Serial: C02XXXXXXXXXXXXXXXXX
SmUUID:       XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
Apple ROM:    XXXXXXXXXXXX
```

6. Reportez ces valeurs dans le config.plist :

| Clé config.plist | Valeur GenSMBIOS |
|------------------|------------------|
| `PlatformInfo > Generic > SystemProductName` | `iMac15,1` |
| `PlatformInfo > Generic > SystemSerialNumber` | Serial |
| `PlatformInfo > Generic > MLB` | Board Serial |
| `PlatformInfo > Generic > SystemUUID` | SmUUID |
| `PlatformInfo > Generic > ROM` | Apple ROM (en hexadécimal) |

> ⚠️ **Important** : Vérifiez que le numéro de série généré n'est **pas** valide chez Apple. Allez sur [checkcoverage.apple.com](https://checkcoverage.apple.com) et entrez le Serial. Vous devez obtenir un message d'erreur (numéro invalide). Si le numéro est valide, générez-en un nouveau.

<!-- 📸 Capture d'écran : GenSMBIOS avec les valeurs générées -->

---

## Étape 5 – Sauvegarder et valider

1. Sauvegardez le config.plist dans ProperTree (`Cmd+S`)

2. Vérifiez la structure du fichier :

```bash
# Vérifier que le plist est valide
plutil -lint EFI/OC/config.plist
```

Résultat attendu : `EFI/OC/config.plist: OK`

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] Le config.plist est créé à partir du Sample.plist d'OpenCore
- [ ] OC Snapshot a été exécuté pour référencer tous les fichiers
- [ ] Les sections Booter, Kernel, DeviceProperties sont configurées
- [ ] Le SMBIOS iMac15,1 est généré et les valeurs sont renseignées
- [ ] Le numéro de série n'est PAS valide chez Apple
- [ ] Le fichier plist est syntaxiquement valide (`plutil -lint`)

---

## Dépannage

| Problème | Solution |
|----------|----------|
| ProperTree ne s'ouvre pas | Installez Python 3 : `xcode-select --install` |
| OC Snapshot ne détecte pas les kexts | Vérifiez que les `.kext` sont bien des dossiers complets |
| `plutil -lint` signale une erreur | Ouvrez dans ProperTree et corrigez la syntaxe XML |
| Audio ne fonctionne pas | Essayez d'autres valeurs de `alcid` (2, 3, 5, 7, 12, 28) |
| GenSMBIOS produit une erreur | Mettez à jour avec `git pull` dans le dossier GenSMBIOS |

---

## Étape suivante

→ [Guide 6 – Montage et copie de l'EFI sur la clé USB](Guide-06-Copie-EFI-USB.md)
