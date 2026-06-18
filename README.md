# Site web académique — Mode d'emploi

## Structure des fichiers

```
academic-site/
├── index.html               ← le site complet (une seule page)
├── publications.json        ← généré par R, lu automatiquement par le site
├── generate_publications.R  ← script R à exécuter pour mettre à jour les publications
└── README.md                ← ce fichier
```

## Workflow en 3 étapes

### 1. Modifier vos publications dans R

Ouvrez `generate_publications.R` et choisissez votre source :

| Source | Effort | Pré-requis |
|--------|--------|-----------|
| **A — Liste manuelle** | Modifier le script | `jsonlite`, `dplyr` |
| **B — Fichier .bib** | Pointer vers votre `.bib` | `bib2df` |
| **C — Google Scholar** | Mettre votre Scholar ID | `scholar` |
| **D — ORCID** | Mettre votre ORCID | `rorcid` |

Vous pouvez combiner plusieurs sources : le script déduplique automatiquement par titre.

### 2. Exécuter le script R

```r
source("generate_publications.R")
# ✓ Wrote 5 publications to: publications.json
```

Le fichier `publications.json` est mis à jour automatiquement.

### 3. Déployer

Copiez tous les fichiers sur votre hébergeur :
- GitHub Pages (gratuit) : déposez dans un repo `votrenom.github.io`
- Netlify / Vercel (gratuit) : drag & drop du dossier
- Votre serveur web universitaire

## Format de publications.json

Chaque publication est un objet JSON avec ces champs :

```json
{
  "title":    "Titre de l'article",
  "authors":  "Doe, J., & Martin, A.",
  "year":     2024,
  "venue":    "Nom de la revue ou conférence",
  "type":     "Journal",        // Journal | Conference | Preprint | Book Chapter
  "doi":      "10.xxxx/xxxxx",  // optionnel — génère un lien DOI
  "preprint": "https://arxiv.org/abs/xxxx", // optionnel
  "code":     "https://github.com/...",     // optionnel
  "pdf":      "papers/mypaper.pdf",         // optionnel
  "keywords": ["mot-clé 1", "mot-clé 2"]   // optionnel — tags affichés
}
```

Tous les champs sauf `title` sont optionnels.

## Personnalisation du site

Ouvrez `index.html` et modifiez :

- **Ligne ~115** : votre nom, poste, institution, bio
- **Ligne ~125** : liens vers votre CV, Scholar, GitHub, email
- **Lignes ~195–200** : vos intérêts de recherche
- **Lignes ~205–215** : vos coordonnées
- Les couleurs sont dans les variables CSS `:root` (ligne ~15)

## Automatisation (optionnel)

Pour que les publications se mettent à jour automatiquement, vous pouvez :

**GitHub Actions** — créer `.github/workflows/update-pubs.yml` :

```yaml
on:
  schedule:
    - cron: '0 6 * * 1'   # chaque lundi à 6h
  push:
    branches: [main]

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - run: Rscript generate_publications.R
      - run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add publications.json
          git diff --staged --quiet || git commit -m "Update publications"
          git push
```
