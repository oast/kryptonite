# Kryptonite · Système d'inventaire HDD — Documentation technique

Architecture tripartite : étiquette thermique SUPVAN T50M Pro (203 dpi) · matrice Katasymbol · portail web d'audit.

---

## Étape 1 — Ingénierie visuelle de l'étiquette thermique (50 mm × 50 mm · 203 dpi)

### Principes d'agencement (inspirés des captures Katasymbol)

| Principe | Application |
|---|---|
| Séparateurs pleins `───` | Délimitation des zones sémantiques (ID/Nom, champs, QR) |
| Grille 2 colonnes | Champs duaux alignés (SMART∣TEST, CAP∣DISPO, PART∣ENFTS) |
| Zone de silence (quiet zone) | Marge blanche de 2 mm minimum autour du QR code — critique à 203 dpi |
| Hiérarchie typographique | ID petit monospace · Nom en gras taille +1 · champs en corps courant |
| Abréviations sémantiques | `S:` = S.M.A.R.T · `T:` = Test · `CAP:` = Capacité · `DISPO:` = Disponible · `PART:` = Partition · `ENFTS:` = Enfants |

### Schéma ASCII de l'étiquette (50 mm × 50 mm)

> Largeur utile ≈ 46 mm (marges 2 mm). À 203 dpi : 400 × 400 px.
> Chaque caractère ASCII ≈ 0,9 mm en largeur à 7 pt (police condensée).

```
╔══════════════════════════════════════════════════╗  ← bord supérieur
║ #001                              SSD NVMe       ║  ← [ID]        [TYPE]   2 mm
╠══════════════════════════════════════════════════╣  ← séparateur plein
║  APPLE SSD SM0128G Media                         ║  ← [NOM] gras           3 mm
╠═══════════════════════╦══════════════════════════╣  ← séparateur 2 colonnes
║  S: ● Sain             ║  T: ✓ Passé             ║  ← [SMART] | [TEST]     2.5mm
╠═══════════════════════╬══════════════════════════╣
║  CAP: 121 Go           ║  DISPO: 98 Go           ║  ← [CAPAC] | [DISPO]    2.5mm
╠═══════════════════════╬══════════════════════════╣
║  PART: GUID            ║  ENFTS: 2               ║  ← [PART]  | [ENFTS]    2.5mm
╠═══════════════════════╩══════════════════════════╣  ← séparateur plein
║                                                  ║  ← zone silence 2 mm
║   ┌──────────────────────────┐                   ║
║   │                          │  DSK-26-001       ║
║   │      [ QR CODE ]         │  oast.github.io/  ║  ← QR 22×22 mm | URL
║   │   (URL encodée seule)    │  kryptonite/      ║
║   │                          │  HDD-Inventory/   ║
║   └──────────────────────────┘  ?id=DSK-26-001   ║
║                                                  ║  ← zone silence 2 mm
╚══════════════════════════════════════════════════╝  ← bord inférieur
```

### Contraintes critiques à 203 dpi

- **QR code** : encoder **uniquement** la colonne `URL_QR` (une seule valeur = fiabilité maximale du décodeur).  
- **Zone de silence** : 4 modules QR minimum de chaque côté ≈ 2 mm à cette résolution — ne jamais faire déborder du texte dans cette zone.  
- **Contraste** : papier blanc thermique direct, encre noire uniquement. Éviter les gris < 70 % qui bavent à 203 dpi.  
- **Police** : utiliser une police condensée sans serif (ex. Helvetica Condensed, Liberation Sans Narrow) pour tenir les 10 champs dans la hauteur.

---

## Étape 2 — Matrice Excel / CSV pour importation Katasymbol

### Architecture des colonnes (ligne 1 = en-têtes)

| Colonne | En-tête CSV | Rôle dans Katasymbol | Remarque |
|---|---|---|---|
| A | `ID`         | Variable texte → champ ID de l'étiquette | Clé primaire immuable |
| B | `NOM`        | Variable texte → champ Nom | Nom commercial complet |
| C | `SMART`      | Variable texte → champ S: | Sain · Prudence · Défaillant |
| D | `TEST`       | Variable texte → champ T: | Passé · En cours · Échec · En attente |
| E | `TYPE`       | Variable texte → coin supérieur droit | SSD NVMe · SSD SATA · HDD 7200rpm · HDD 5400rpm |
| F | `CAPACITE`   | Variable texte → champ CAP: | Valeur + unité (ex. `2 To`) |
| G | `DISPONIBLE` | Variable texte → champ DISPO: | Valeur + unité |
| H | `ENFANTS`    | Variable texte → champ ENFTS: | Entier (nombre de volumes APFS/partitions) |
| I | `PARTITION`  | Variable texte → champ PART: | GUID · MBR · APM |
| J | `URL_QR`     | **Source de données QR code** | Ne pas imprimer en texte — lier au générateur QR |

> **Procédure de liaison QR dans Katasymbol** : insérer un objet QR Code sur l'étiquette → taper sur l'objet → *Data Source* → sélectionner la colonne `URL_QR`. Katasymbol itérera automatiquement sur les 30 lignes lors de l'impression groupée (batch print).

### Exemple de tableau (3 lignes réalistes)

| ID | NOM | SMART | TEST | TYPE | CAPACITE | DISPONIBLE | ENFANTS | PARTITION | URL_QR |
|---|---|---|---|---|---|---|---|---|---|
| DSK-26-001 | APPLE SSD SM0128G Media | Sain | Passé | SSD NVMe | 121 Go | 98 Go | 2 | GUID | `https://oast.github.io/kryptonite/HDD-Inventory/?id=DSK-26-001` |
| DSK-26-002 | APPLE HDD ST2000LM007 | Sain | Passé | HDD 5400rpm | 2 To | 1.4 To | 3 | GUID | `https://oast.github.io/kryptonite/HDD-Inventory/?id=DSK-26-002` |
| DSK-26-010 | TOSHIBA MQ04ABF100 1 To | Prudence | Échec | HDD 5400rpm | 1 To | 600 Go | 1 | GUID | `https://oast.github.io/kryptonite/HDD-Inventory/?id=DSK-26-010` |

**Encodage obligatoire** : UTF-8 avec BOM (`﻿`) pour préserver les caractères accentués (É, è, etc.) lors de l'ouverture sur Android. Le fichier `katasymbol.csv` fourni dans ce dépôt est déjà encodé en UTF-8 BOM.

---

## Étape 3 — Architecture web Low-Code : Airtable + Softr + Horodatage immuable

### Vue d'ensemble de l'architecture

```
 Étiquette physique (QR)
        │
        │ scan (URL paramétrée)
        ▼
 ┌─────────────────┐      REST API      ┌────────────────────┐
 │   SOFTR         │ ◄────────────────► │   AIRTABLE         │
 │  (Frontend SPA) │                    │  (Backend BDD)      │
 │                 │                    │                     │
 │ Page "Détail    │                    │ Table : DISQUES     │
 │  disque"        │                    │ Table : AUDIT_LOG   │
 │ filtrée par     │                    │  └ Timestamp auto   │
 │ ?recordId=XYZ   │                    │  └ Linked record    │
 └─────────────────┘                    └────────────────────┘
```

### 3.1 — Structure Airtable (2 tables)

#### Table `DISQUES`

| Champ | Type Airtable | Notes |
|---|---|---|
| `ID` | Single line text | Clé primaire — DSK-26-001 … DSK-26-030. **Ne jamais modifier.** |
| `NOM` | Single line text | Nom commercial du disque |
| `SMART` | Single select | Options : Sain · Prudence · Défaillant |
| `TEST` | Single select | Options : Passé · En cours · Échec · En attente |
| `TYPE` | Single select | Options : SSD NVMe · SSD SATA · HDD 7200rpm · HDD 5400rpm |
| `CAPACITE` | Single line text | Ex. `2 To` |
| `DISPONIBLE` | Single line text | Ex. `1.4 To` |
| `ENFANTS` | Number | Entier ≥ 0 |
| `PARTITION` | Single select | GUID · MBR · APM |
| `URL_QR` | Formula | `"https://votre-app.softr.app/disk?recordId=" & RECORD_ID()` |
| `AUDIT_LOG` | Link to AUDIT_LOG | Relation 1→N |

> Le champ `URL_QR` utilise la formule Airtable `RECORD_ID()` qui retourne l'identifiant interne immuable du record (ex. `recXXXXXXXXX`). C'est cet identifiant qui est encodé dans le QR code et qui permet à Softr de filtrer la page de détail.

#### Table `AUDIT_LOG`

| Champ | Type Airtable | Notes |
|---|---|---|
| `TIMESTAMP` | Created time | **Automatique, immuable** — Airtable inscrit l'heure exacte à la milliseconde lors de la création de la ligne. Impossible à rétromodifier. |
| `DISQUE` | Link to DISQUES | Relation N→1 vers la table DISQUES |
| `TYPE_OPERATION` | Single select | CONNEXION · SMART · TEST · FORMAT · NOTE |
| `ETAT` | Single select | Sain · Prudence · Défaillant · Passé · En cours · Échec · Info |
| `NOTES` | Long text | Métriques, valeurs SMART, débit I/O, observations |
| `OPERATEUR` | Single line text | Nom de l'ingénieur ayant réalisé l'opération |

**Principe d'immuabilité** : le champ `TIMESTAMP` de type *Created time* est géré par les serveurs Airtable et **ne peut pas être édité** via l'interface ni l'API. Toute tentative de modification est rejetée. Cela garantit l'intégrité du journal d'audit.

### 3.2 — Configuration Softr (Frontend No-Code)

1. **Créer une application Softr** connectée à la base Airtable.
2. **Page "Tableau de bord"** : ajouter un bloc *List* ou *Cards* lié à la table `DISQUES`. Configurer les filtres SMART/TEST comme dropdown.
3. **Page "Détail disque"** (`/disk`) :
   - Activer le mode **Dynamic page** (URL paramétrée).
   - Dans les paramètres de la page : *Filter by URL parameter* → paramètre `recordId` → champ `Record ID` de la table DISQUES.
   - La page se charge automatiquement avec les données du disque dont le `RECORD_ID()` correspond au paramètre reçu via le scan QR.
4. **Bloc "Journal d'audit"** : ajouter un bloc *Table* ou *List* lié à la table `AUDIT_LOG`, filtré par `DISQUE = current record`. Trier par `TIMESTAMP` décroissant.
5. **Bloc "Nouveau rapport"** : ajouter un bloc *Form* lié à `AUDIT_LOG`. Pré-remplir le champ `DISQUE` avec le `recordId` courant (Softr le gère nativement via *prefill from URL*). Le champ `TIMESTAMP` n'apparaît pas dans le formulaire — il est généré automatiquement.

### 3.3 — Génération de l'URL paramétrée dans le fichier Excel

Une fois l'application Softr déployée, la formule Airtable suivante génère automatiquement la colonne `URL_QR` :

```
"https://votre-app.softr.app/disk?recordId=" & RECORD_ID()
```

Pour l'export vers Katasymbol, utiliser l'API Airtable ou le bouton *Export CSV* de la vue Airtable pour récupérer la matrice complète avec les 30 URLs générées. Le fichier résultant est directement importable dans Katasymbol.

### 3.4 — Alternative : Google Sheets + Apps Script

Si Airtable n'est pas disponible, Google Sheets offre une architecture équivalente :

- **Feuille `DISQUES`** : colonnes identiques. L'ID est une constante alphanumérique manuelle (DSK-26-001, etc.).
- **Feuille `AUDIT_LOG`** : Apps Script ajoute automatiquement un timestamp via `new Date()` à chaque soumission de formulaire Google Forms lié.
- **URL** : construite manuellement sous la forme `https://script.google.com/macros/s/[ID]/exec?id=DSK-26-001` via une webapp Apps Script servant les données JSON.
- **Softr** supporte Google Sheets nativement comme source de données via son connecteur officiel.

### 3.5 — Solution autonome fournie dans ce dépôt

Le portail `index.html` / `app.js` / `styles.css` inclus dans ce dossier est une implémentation **100 % offline** utilisant `localStorage` comme backend. Il offre :

- Tableau de bord filtrable par type / SMART / test
- Vue détail par disque (accessible via `?id=DSK-26-XXX`)
- Journal d'audit horodaté (timestamp `new Date().toISOString()` côté client)
- Export CSV au format Katasymbol (bouton "Exporter CSV")

Pour le déployer en accès public via QR code : activer **GitHub Pages** sur ce dépôt (`Settings → Pages → Source: main branch → /HDD-Inventory`). L'URL de base sera `https://oast.github.io/kryptonite/HDD-Inventory/`.

---

## Flux opérationnel complet

```
1. EXTRACTION  diskutil info diskN  →  30 fiches disques
       │
       ▼
2. SAISIE     Airtable / Google Sheets  →  base de données backend
       │
       ▼
3. EXPORT     CSV UTF-8 BOM  →  30 lignes + colonne URL_QR
       │
       ▼
4. IMPRESSION  Katasymbol (iOS/Android)  →  import CSV  →  batch print
       │                                    liaison QR → colonne URL_QR
       ▼
5. AUDIT      Scan QR  →  portail Softr / index.html  →  fiche disque
              Formulaire d'audit  →  AUDIT_LOG  →  timestamp immuable
```
