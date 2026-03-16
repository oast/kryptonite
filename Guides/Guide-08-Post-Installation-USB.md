# Guide 8 – Post-installation et mappage USB

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- macOS Sequoia installé et fonctionnel (voir [Guide 7](Guide-07-Installation-macOS.md))
- Boot depuis la clé USB via OpenCore
- Connexion Internet (Ethernet)

---

## Étape 1 – Copier l'EFI sur le disque interne

Actuellement, vous bootez depuis la clé USB. Pour rendre le boot autonome, copiez l'EFI sur le disque interne.

### 1.1 – Monter les partitions EFI

```bash
# Identifier les disques
diskutil list

# Monter la partition EFI de la clé USB
sudo diskutil mount disk2s1    # Remplacez par votre identifiant USB

# Monter la partition EFI du disque interne
sudo diskutil mount disk0s1    # Remplacez par votre identifiant interne
```

> ⚠️ Vérifiez bien les identifiants avec `diskutil list`. Le disque interne est généralement `disk0` ou `disk1`.

### 1.2 – Copier l'EFI

```bash
# Supprimer l'EFI existant sur le disque interne (s'il existe)
sudo rm -rf /Volumes/EFI\ 1/EFI    # Ou /Volumes/EFI/EFI si c'est le seul monté

# Copier depuis la clé USB
sudo cp -R /Volumes/EFI/EFI /Volumes/EFI\ 1/
```

> Si les deux partitions EFI sont montées, elles apparaissent comme `/Volumes/EFI` et `/Volumes/EFI 1`. Vérifiez laquelle est laquelle.

### 1.3 – Tester le boot sans clé USB

1. Éjectez la clé USB
2. Redémarrez le PC
3. OpenCore devrait apparaître depuis le disque interne
4. Sélectionnez **Macintosh HD** pour démarrer macOS

<!-- 📸 Capture d'écran : deux partitions EFI montées dans le Finder -->

---

## Étape 2 – Identifier les ports USB avec Hackintool

macOS limite les ports USB à **15 maximum** par contrôleur. L'ASUS Z97-C possède plus de 15 ports physiques (USB 2.0, USB 3.0, internes). Un mappage personnalisé est nécessaire.

### 2.1 – Installer Hackintool

1. Téléchargez [Hackintool](https://github.com/benbaker76/Hackintool/releases)

2. Déplacez l'application dans `/Applications/`

3. Lancez Hackintool et allez dans l'onglet **USB**

<!-- 📸 Capture d'écran : onglet USB de Hackintool -->

### 2.2 – Identifier les ports actifs

1. Dans l'onglet USB, vous voyez tous les ports détectés

2. Pour identifier chaque port physique :
   - Branchez un périphérique USB **2.0** (clé USB, souris) dans chaque port un par un
   - Branchez ensuite un périphérique USB **3.0** dans les mêmes ports
   - Notez quel port logique correspond à quel port physique

3. Hackintool affiche :
   - **HS01-HS14** : ports USB 2.0 (High Speed)
   - **SS01-SS10** : ports USB 3.0 (Super Speed)
   - **USR1-USR2** : ports internes

> Un port USB 3.0 physique utilise **2 ports logiques** : un HS (compatibilité 2.0) + un SS (3.0).

---

## Étape 3 – Créer le mappage USB

### Méthode A – Avec USBToolBox (recommandée)

[USBToolBox](https://github.com/USBToolBox/tool) est plus simple et peut être utilisé depuis Windows ou macOS.

1. Téléchargez l'outil :

```bash
cd ~/Desktop
git clone https://github.com/USBToolBox/tool.git
cd tool
python3 USBToolBox.command
```

2. Sélectionnez **D** pour découvrir les ports

3. Branchez et débranchez un périphérique USB dans chaque port (attendez quelques secondes entre chaque)

4. Sélectionnez **S** pour voir les ports détectés

5. Sélectionnez **C** pour créer le kext de mappage

6. Choisissez les **15 ports maximum** les plus importants :
   - Gardez les ports USB 3.0 arrière (HS + SS)
   - Gardez au moins 2 ports USB 2.0
   - Gardez les ports internes (pour Bluetooth si utilisé)
   - Supprimez les ports que vous n'utilisez jamais

7. L'outil génère `USBMap.kext`

### Méthode B – Avec Hackintool

1. Dans l'onglet USB de Hackintool, décochez les ports que vous n'utilisez pas

2. Assurez-vous de n'avoir que **15 ports cochés** maximum

3. Cliquez sur l'icône d'export (flèche) pour générer :
   - `USBPorts.kext` – kext de mappage
   - `SSDT-UIAC.aml` – table ACPI alternative

### Ajouter le kext de mappage à l'EFI

```bash
# Monter la partition EFI du disque interne
sudo diskutil mount disk0s1

# Copier le kext généré
cp -R ~/Desktop/USBMap.kext /Volumes/EFI/EFI/OC/Kexts/

# OU si vous avez utilisé Hackintool :
cp -R ~/Desktop/USBPorts.kext /Volumes/EFI/EFI/OC/Kexts/
```

> ⚠️ **N'oubliez pas** de lancer un **OC Snapshot** dans ProperTree après avoir ajouté le kext, pour mettre à jour le config.plist.

```bash
python3 ~/Desktop/Hackintosh-Sequoia/ProperTree/ProperTree.command /Volumes/EFI/EFI/OC/config.plist
# File > OC Snapshot > Sélectionnez /Volumes/EFI/EFI/OC/
```

<!-- 📸 Capture d'écran : USBToolBox montrant les ports détectés -->

---

## Étape 4 – Optimiser la stabilité et la veille

### 4.1 – Désactiver la mise en veille hybride

La mise en veille peut être problématique sur un Hackintosh. Commencez par ces réglages :

```bash
# Désactiver hibernation (recommandé pour les Hackintosh)
sudo pmset -a hibernatemode 0
sudo pmset -a proximitywake 0
sudo pmset -a standby 0
sudo pmset -a autopoweroff 0

# Supprimer le fichier d'hibernation existant
sudo rm -f /var/vm/sleepimage

# Créer un fichier vide pour empêcher la recréation
sudo mkdir -p /var/vm
sudo touch /var/vm/sleepimage
sudo chflags uchg /var/vm/sleepimage
```

### 4.2 – Vérifier les paramètres de veille

```bash
# Afficher les paramètres actuels
pmset -g
```

Valeurs recommandées :

| Paramètre | Valeur |
|-----------|--------|
| `hibernatemode` | `0` |
| `standby` | `0` |
| `autopoweroff` | `0` |
| `proximitywake` | `0` |

### 4.3 – Tester la veille

1. Mettez le Mac en veille (menu Apple > Suspendre l'activité)
2. Attendez 10 secondes
3. Réveillez avec le clavier ou la souris
4. Vérifiez que tout fonctionne : écran, USB, réseau, audio

---

## Étape 5 – Vérifications post-installation

Ouvrez le Terminal et vérifiez chaque composant :

### Audio

```bash
# Vérifier que le codec audio est reconnu
system_profiler SPAudioDataType
```

Si l'audio ne fonctionne pas, essayez un autre `alcid` dans les boot-args (voir Guide 5).

### Réseau

```bash
# Vérifier l'interface Ethernet
ifconfig en0

# Tester la connectivité
ping -c 3 apple.com
```

### GPU

```bash
# Vérifier l'accélération graphique
system_profiler SPDisplaysDataType | grep -A5 "Chipset Model"
```

Vous devriez voir `AMD Radeon RX 580` avec la VRAM correcte (8192 Mo).

### USB

```bash
# Lister les contrôleurs USB
system_profiler SPUSBDataType
```

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] L'EFI est copié sur le disque interne et le boot fonctionne sans clé USB
- [ ] Le mappage USB est créé (15 ports maximum)
- [ ] Le kext USB est ajouté à l'EFI et référencé dans config.plist
- [ ] L'audio fonctionne (haut-parleurs et/ou casque)
- [ ] Le réseau Ethernet fonctionne
- [ ] La veille et le réveil fonctionnent
- [ ] L'accélération GPU est active

---

## Dépannage

| Problème | Solution |
|----------|----------|
| Boot impossible sans clé USB | Vérifiez que l'EFI est copié sur la bonne partition (disque interne) |
| Plus de 15 ports USB | Désactivez les ports inutilisés dans le mappage |
| Pas d'audio | Essayez `alcid=2`, `alcid=3`, `alcid=5`, `alcid=7` dans les boot-args |
| Veille ne fonctionne pas | Vérifiez les paramètres `pmset` ; ajoutez `darkwake=0` aux boot-args |
| USB 3.0 lent | Vérifiez que les ports SS sont bien mappés ; vérifiez XHCI Hand-off dans le BIOS |
| Kernel panic au réveil | Désactivez l'hibernation ; vérifiez le mappage USB |

---

## Étape suivante

→ [Guide 9 – Maintenance et mise à jour de l'EFI](Guide-09-Maintenance-EFI.md)
