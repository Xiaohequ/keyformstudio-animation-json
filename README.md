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
- Livre **un seul exemple**, `references/vasf-example.json`, qui exerce toutes
  les fonctionnalités du format (groupes, couches, palette, defs, cycles,
  pivot, cubic-bezier, morph, couleur animée, miroir, coins, squelette IK).
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
```

Le validateur sort en code 0 si le fichier est importable, 1 s'il contient des
erreurs, et affiche chaque problème en français avec son chemin.

## Structure

```
keyformstudio-animation-json/
├─ SKILL.md              # instructions de l'agent + référence complète des champs
├─ CHANGELOG.md          # historique des versions du skill
├─ references/
│  └─ vasf-example.json  # UN exemple complet couvrant toutes les fonctionnalités
└─ scripts/
   ├─ validate_vasf.py   # validateur (mêmes règles que l'import de l'appli)
   └─ preview_vasf.py    # rendu headless (outil de développement, non publié)
```

## Versions

Le frontmatter de `SKILL.md` porte `version` (le skill), `license` et
`homepage`. L'historique est dans `CHANGELOG.md`.

`SKILL.md` est rédigé en anglais : c'est la langue de travail des agents qui
consomment le skill.

Ce dépôt est la copie **publiée** du skill. Le dépôt de l'application reste la
source de vérité du code qui implémente le format ; `references/` en est le
miroir exact.

## Licence

MIT — voir `LICENSE`.

Note : ClawHub affiche **MIT-0** (MIT sans attribution) sur la fiche du skill.
Ce n'est pas un choix de l'auteur mais la licence unique que la plateforme
applique à tous les skills publiés ; le champ n'accepte que `MIT-0` ou vide
(demande d'ouverture aux autres licences SPDX : openclaw/clawhub#3439). Le
fichier `LICENSE` de ce dépôt reste la référence : MIT, avec attribution.

### État de la publication ClawHub

La version **1.1.0** est la dernière visible sur ClawHub. Les versions 1.1.1,
1.1.2 et 1.1.3 ont été acceptées par le registre puis sont restées bloquées en
`pending.publication` : le scan de sécurité les déclare CLEAN, mais elles
n'apparaissent ni dans l'index ni dans `inspect`, et `clawhub unhide` répond
« Forbidden: hidden by moderation ». C'est un défaut connu du registre
(openclaw/clawhub#3466, #3205, #3937), sans recours côté propriétaire.

Ces trois versions n'apportaient que la note de licence ci-dessus : le contenu
utile du skill (SKILL.md en anglais, validateur, aperçu, exemples) est bien
celui de la 1.1.0 en ligne. Le dépôt GitHub reste la référence à jour.
