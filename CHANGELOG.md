# Journal du skill keyformstudio-animation-json

Chaque entrée indique la version du skill, la version VASF couverte et la
version d'appli de référence.

## 1.2.1 — 2026-10-21

- `.clawhubignore` : README.md, CHANGELOG.md, scripts/publish.sh et
  scripts/preview_vasf.py restent dans le dépôt GitHub mais ne sont plus
  publiés sur ClawHub (bundle réduit à 5 fichiers : SKILL.md, LICENSE, la spec,
  l'exemple et le validateur).

## 1.2.0 — 2026-10-21

- Exemples fusionnés en un seul fichier `references/vasf-example.json` : un
  objet importable unique qui exerce TOUTES les fonctionnalités du format
  (groupes v6, theme, defs+ref, layers[], cycle, scaleX/scaleY animés, pivot,
  cubic-bezier, easing step, fenêtres start/end, couleur animée, morph de
  points, flipH/flipV, coins de rectangles, squelette IK + bend, move d'os,
  liaisons de forme et de couche).
- Suppression des six fichiers d'exemples séparés.
- `validate_vasf.py` : accepte un recueil (`--pick CLE`) en plus d'un objet seul.
- CI et `publish.sh` alignés sur le fichier unique.

## 1.1.4 — 2026-10-21

- README : documenter l'état réel de la publication ClawHub (1.1.0 visible,
  1.1.1 à 1.1.3 bloquées en `pending.publication` par un défaut du registre).
- Décision : conserver la situation telle quelle — le dépôt GitHub porte MIT,
  la fiche ClawHub affiche MIT-0 (licence imposée par la plateforme).

## 1.1.3 — 2026-10-21

- Test de publication sans métadonnées de catalogue (les 1.1.1 et 1.1.2 sont
  restées bloquées en attente côté ClawHub).

## 1.1.2 — 2026-10-21

- Republication de la précision de licence (la 1.1.1 est restée bloquée en
  attente de publication côté ClawHub).

## 1.1.1 — 2026-10-21

- README : précision sur la licence affichée par ClawHub (MIT-0 imposé par la
  plateforme) et sur le fichier `LICENSE` du dépôt (MIT avec attribution).

## 1.1.0 — 2026-10-21

- SKILL.md réécrit en anglais pour un usage par un agent tiers.
- Contenu resserré : suppression des notes d'historique de développement
  (versions d'appli, éditeur in-app, détails d'implémentation), des chemins
  propres au dépôt de l'appli et de la section de synchronisation.
- Règles regroupées par thème (core rules, versions, gotchas, workflow) au lieu
  d'un empilement chronologique.

## 1.0.1 — 2026-10-20

- Inclut le README et le script de publication

## 1.0.0 — 2026-10-21

- Première version hébergée DANS le dépôt `vector-anim-studio` (auparavant
  uniquement dans le workspace de l'agent, sous
  `skills/keyformstudio-animation-json/`).
- Frontmatter enrichi : `version` (skill), `vasf` (version de format couverte),
  `app` (version d'appli de référence).
- Chemins réécrits pour le dépôt : la spec et les exemples cités sont ceux de
  `docs/` (source de vérité versionnée avec le code) ; `references/` devient un
  miroir de contrôle.
- Ajout de `scripts/sync_skill.sh` (copie vers le workspace de l'agent +
  vérification de dérive `references/` ↔ `docs/`).
- Alignement VASF-6 / app 0.39.0 : groupes d'éléments (`groups` + `groupId` par
  nom), transformation de groupe rendue autour du centre visuel, import strict
  des versions 1 à 6.
