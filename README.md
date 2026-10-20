# keyformstudio-animation-json

Agent skill (ClawHub / nanobot) qui apprend à un agent IA à **générer et valider
un fichier d'animation JSON VASF** importable dans **Keyform Studio**, le studio
d'animation vectorielle Flutter (Android / iOS).

VASF (*Vector Anim Studio Format*) est un format JSON compact et lisible par un
LLM : formes, keyframes, squelette optionnel, en secondes et en degrés.

## Ce que fait le skill

- Décrit le format complet : VASF-1 (base), VASF-2 (couches, palette, cycles,
  defs, pivot, cubic-bezier), VASF-3 (couleur animée, morph de points,
  translation d'os, IK), VASF-4 (miroir), VASF-5 (coins de rectangles),
  VASF-6 (groupes d'éléments).
- Fournit un **validateur** qui reproduit les règles d'import strictes de
  l'application et rapporte les erreurs en français avec leur chemin.
- Fournit un **aperçu headless** qui rend les frames hors application, avec les
  mêmes formules que le moteur Flutter (vérifié au pixel, écart < 1/255), pour
  contrôler une composition avant de livrer le fichier.

## Installation

Depuis ClawHub :

```bash
npx --yes clawhub@latest install keyformstudio-animation-json --workdir ~/.nanobot/workspace
```

Ou manuellement : copier ce dossier dans `~/.nanobot/workspace/skills/`.

## Utilisation

```bash
# Valider un fichier avant import
python3 scripts/validate_vasf.py mon_animation.json

# Rendre une planche de contrôle (5 instants répartis sur la durée)
python3 scripts/preview_vasf.py mon_animation.json

# Instants précis, avec le squelette superposé
python3 scripts/preview_vasf.py mon_animation.json 0 0.5 1.2 --bones
```

Le validateur sort en code 0 si le fichier est importable, 1 s'il contient des
erreurs. L'aperçu écrit `tmp/vasf_preview/<nom>/planche.png` et les frames
pleine résolution.

## Structure

```
keyformstudio-animation-json/
├─ SKILL.md              # instructions de l'agent (frontmatter version/vasf/app)
├─ CHANGELOG.md          # historique des versions du skill
├─ references/
│  ├─ vasf-1-format.md   # spec complète du format
│  └─ vasf-*.json        # exemples importables (v1, v2, v2-G2, v3, v5, v6)
└─ scripts/
   ├─ validate_vasf.py   # validateur (mêmes règles que l'import de l'appli)
   └─ preview_vasf.py    # rendu headless fidèle au moteur Flutter
```

## Versions

Le frontmatter de `SKILL.md` porte trois versions : `version` (le skill),
`vasf` (la version de format couverte) et `app` (la version d'appli de
référence). L'historique est dans `CHANGELOG.md`.

Ce dépôt est la copie **publiée** du skill. Le dépôt de l'application reste la
source de vérité du code qui implémente le format ; `references/` en est le
miroir exact.

## Licence

MIT — voir `LICENSE`.
