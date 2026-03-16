# Guide 2 – Création de la clé USB bootable

> **Configuration cible** : ASUS Z97-C | Intel i7-4790 | AMD RX 580 | macOS Sequoia

---

## Prérequis

- L'installateur `Install macOS Sequoia.app` dans `/Applications/` (voir [Guide 1](Guide-01-Telechargement-macOS.md))
- Une clé USB de **16 Go minimum** (32 Go recommandé)
- Un Mac fonctionnel (ou une VM macOS)

> ⚠️ **Attention** : toutes les données de la clé USB seront effacées. Sauvegardez vos fichiers avant de continuer.

---

## Étape 1 – Identifier votre clé USB

1. Branchez la clé USB sur votre Mac

2. Ouvrez le **Terminal** (`Applications > Utilitaires > Terminal`)

3. Listez les disques connectés :

```bash
diskutil list
```

4. Repérez votre clé USB dans la liste. Elle apparaît généralement comme `/dev/diskN` (N étant un chiffre). Identifiez-la par sa taille (16 Go ou 32 Go).

```
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *16.0 GB    disk2
   1:                 DOS_FAT_32 USB_DRIVE               16.0 GB    disk2s1
```

> ⚠️ **Notez bien le numéro du disque** (ex: `disk2`). Une erreur de numéro pourrait effacer le mauvais disque !

<!-- 📸 Capture d'écran : sortie de diskutil list avec la clé USB identifiée -->

---

## Étape 2 – Formater la clé USB

### Option A – Via l'Utilitaire de disque (interface graphique)

1. Ouvrez **Utilitaire de disque** (`Applications > Utilitaires > Utilitaire de disque`)
2. Dans le menu **Présentation**, sélectionnez **Afficher tous les appareils**
3. Sélectionnez votre clé USB (le disque entier, pas la partition)
4. Cliquez sur **Effacer**
5. Configurez :
   - **Nom** : `MyVolume`
   - **Format** : `Mac OS étendu (journalisé)` (HFS+)
   - **Schéma** : `Table de partition GUID`
6. Cliquez sur **Effacer**

<!-- 📸 Capture d'écran : Utilitaire de disque avec les paramètres de formatage -->

### Option B – Via le Terminal

```bash
# Remplacez disk2 par le numéro de votre clé USB
diskutil partitionDisk /dev/disk2 GPT JHFS+ "MyVolume" 100%
```

Cette commande :
- Crée une table de partition GUID (GPT)
- Formate en HFS+ journalisé
- Nomme le volume `MyVolume`
- Utilise 100% de l'espace disponible

---

## Étape 3 – Créer le support d'installation avec createinstallmedia

1. Ouvrez le Terminal et exécutez la commande suivante :

```bash
sudo "/Applications/Install macOS Sequoia.app/Contents/Resources/createinstallmedia" \
    --volume /Volumes/MyVolume \
    --nointeraction
```

2. Entrez votre mot de passe administrateur quand demandé

3. Le processus va :
   - Effacer le volume `MyVolume`
   - Copier les fichiers d'installation
   - Rendre la clé bootable

> Le processus prend **15 à 30 minutes** selon la vitesse de votre clé USB. Ne débranchez pas la clé pendant l'opération.

<!-- 📸 Capture d'écran : Terminal montrant la progression de createinstallmedia -->

4. Une fois terminé, vous verrez le message :

```
Install media now available at "/Volumes/Install macOS Sequoia"
```

---

## Étape 4 – Vérification

Vérifiez que la clé USB a été correctement préparée :

```bash
# Vérifiez que le volume d'installation existe
ls /Volumes/
```

Vous devriez voir `Install macOS Sequoia` dans la liste.

```bash
# Vérifiez le contenu du volume
ls "/Volumes/Install macOS Sequoia/"
```

Vous devriez voir des fichiers comme `BaseSystem.dmg` ou le dossier `.IAPhysicalMedia`.

---

## Vérification

Avant de passer au guide suivant, assurez-vous que :

- [ ] La clé USB est formatée en GPT + HFS+
- [ ] Le volume `Install macOS Sequoia` apparaît dans `/Volumes/`
- [ ] Les fichiers d'installation sont présents sur la clé

---

## Dépannage

| Problème | Solution |
|----------|----------|
| `createinstallmedia: command not found` | Vérifiez le chemin vers l'installateur dans `/Applications/` |
| `Volume could not be unmounted` | Fermez toutes les applications qui accèdent à la clé USB |
| Le processus est très lent | Utilisez un port USB 3.0 et une clé USB 3.0 |
| Erreur de permission | Assurez-vous d'utiliser `sudo` |
| La clé n'apparaît pas dans diskutil | Essayez un autre port USB ou une autre clé |

---

## Étape suivante

→ [Guide 3 – Téléchargement et préparation d'OpenCore](Guide-03-Preparation-OpenCore.md)
