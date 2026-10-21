# Journal du skill keyformstudio-animation-json

Chaque entrée indique la version du skill, la version VASF couverte et la
version d'appli de référence.

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
