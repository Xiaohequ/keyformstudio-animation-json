#!/usr/bin/env bash
# Publie une nouvelle version du skill sur ClawHub.
#
#   scripts/publish.sh 1.0.1 "Corrige le validateur"      publie 1.0.1
#   scripts/publish.sh --bump minor "Nouveau format"      calcule la version
#   scripts/publish.sh 1.0.1 "..." --dry-run              simulation seulement
#
# Étapes : arbre git propre -> version dans SKILL.md -> CHANGELOG -> commit ->
# tag -> push GitHub -> publication ClawHub.
#
# Prérequis : être authentifié (`clawhub login`), et le CLI clawhub accessible
# (variable CLAWHUB_CLI, sinon `clawhub` dans le PATH, sinon le binaire du cache
# npx).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLUG="keyformstudio-animation-json"
NAME="Keyform Studio Animation JSON"
REPO_URL="https://github.com/Xiaohequ/keyformstudio-animation-json"

DRY_RUN=0
BUMP=""
VERSION=""
CHANGELOG=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --bump) BUMP="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)
      if [ -z "$VERSION" ]; then VERSION="$1"
      elif [ -z "$CHANGELOG" ]; then CHANGELOG="$1"
      else printf 'Argument inattendu : %s\n' "$1" >&2; exit 2
      fi
      shift ;;
  esac
done

# --- CLI clawhub -----------------------------------------------------------
CLAWHUB="${CLAWHUB_CLI:-}"
if [ -z "$CLAWHUB" ]; then
  if command -v clawhub >/dev/null 2>&1; then
    CLAWHUB="clawhub"
  else
    CLAWHUB="$(find "$HOME/.npm/_npx" -path '*/clawhub/bin/clawdhub.js' 2>/dev/null | head -1)"
    if [ -z "$CLAWHUB" ]; then
      printf '✘ CLI clawhub introuvable. Installer avec : npx --yes clawhub@latest --version\n' >&2
      exit 2
    fi
    CLAWHUB="node $CLAWHUB"
  fi
fi

# --- Version ---------------------------------------------------------------
current="$(grep '^version:' "$ROOT/SKILL.md" | awk '{print $2}')"
if [ -n "$BUMP" ]; then
  case "$BUMP" in
    major) VERSION="$(echo "$current" | awk -F. '{print $1+1".0.0"}')" ;;
    minor) VERSION="$(echo "$current" | awk -F. '{print $1"."$2+1".0"}')" ;;
    patch) VERSION="$(echo "$current" | awk -F. '{print $1"."$2"."$3+1}')" ;;
    *) printf '✘ --bump attend major, minor ou patch\n' >&2; exit 2 ;;
  esac
fi
if [ -z "$VERSION" ]; then
  printf '✘ version requise (ex. 1.0.1) ou --bump patch|minor|major\n' >&2
  exit 2
fi
if ! echo "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  printf '✘ version invalide : %s (semver attendu)\n' "$VERSION" >&2
  exit 2
fi
if [ "$VERSION" = "$current" ]; then
  printf '✘ la version %s est déjà celle de SKILL.md\n' "$VERSION" >&2
  exit 2
fi
[ -n "$CHANGELOG" ] || CHANGELOG="Version $VERSION"

# --- Garde-fous ------------------------------------------------------------
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  printf '✘ arbre git non propre dans %s : committer ou remettre à zéro avant de publier\n' "$ROOT" >&2
  git -C "$ROOT" status --short >&2
  exit 1
fi

# Le validateur doit accepter l'exemple avant publication.
python3 "$ROOT/scripts/validate_vasf.py" "$ROOT/references/vasf-example.json" \
  >/dev/null \
  || { printf '✘ references/vasf-example.json refusé par le validateur\n' >&2; exit 1; }

printf '→ %s : %s -> %s\n' "$SLUG" "$current" "$VERSION"

# --- Écriture de la version et du changelog --------------------------------
python3 - "$ROOT" "$VERSION" "$CHANGELOG" <<'PY'
import sys, datetime, re
root, version, changelog = sys.argv[1], sys.argv[2], sys.argv[3]

skill = f"{root}/SKILL.md"
s = open(skill, encoding="utf-8").read()
s = re.sub(r"^version: .*$", f"version: {version}", s, count=1, flags=re.M)
open(skill, "w", encoding="utf-8").write(s)

entry = f"## {version} — {datetime.date.today().isoformat()}\n\n- {changelog}\n\n"
ch = f"{root}/CHANGELOG.md"
c = open(ch, encoding="utf-8").read()
marker = "## 1.0.0"
i = c.find(marker)
c = c[:i] + entry + c[i:] if i != -1 else c + "\n" + entry
open(ch, "w", encoding="utf-8").write(c)
PY

# --- Simulation ------------------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  printf '→ simulation : version %s, changelog « %s »\n' "$VERSION" "$CHANGELOG"
  $CLAWHUB publish "$ROOT" \
    --slug "$SLUG" \
    --name "$NAME" \
    --version "$VERSION" \
    --changelog "$CHANGELOG" \
    --tags latest \
    --source-repo "$REPO_URL" \
    --source-commit "$(git -C "$ROOT" rev-parse HEAD)" \
    --source-ref main \
    --source-path . \
    --dry-run
  git -C "$ROOT" checkout -- SKILL.md CHANGELOG.md
  printf '✔ fichiers restaurés (dry-run) : rien committé, rien poussé, rien publié\n'
  exit 0
fi

# --- Commit, tag, push -----------------------------------------------------
git -C "$ROOT" add SKILL.md CHANGELOG.md
git -C "$ROOT" commit -q -m "release: skill $VERSION

$CHANGELOG"
git -C "$ROOT" tag -a "v$VERSION" -m "Skill $VERSION"
printf '✔ commit et tag v%s créés\n' "$VERSION"

# Aucune credential git locale : pousser via l'URL HTTPS avec le token.
if [ -n "${GITHUB_ACCES_TOKEN:-}" ]; then
  PUSH_URL="https://${GITHUB_ACCES_TOKEN}@github.com/Xiaohequ/${SLUG}.git"
else
  PUSH_URL="$(git -C "$ROOT" remote get-url origin)"
fi
git -C "$ROOT" push "$PUSH_URL" main
git -C "$ROOT" push "$PUSH_URL" "v$VERSION"
printf '✔ poussé sur %s\n' "$REPO_URL"

# --- Publication ClawHub ---------------------------------------------------
commit="$(git -C "$ROOT" rev-parse HEAD)"
$CLAWHUB publish "$ROOT" \
  --slug "$SLUG" \
  --name "$NAME" \
  --version "$VERSION" \
  --changelog "$CHANGELOG" \
  --tags latest \
  --source-repo "$REPO_URL" \
  --source-commit "$commit" \
  --source-ref main \
  --source-path .

printf '\n✔ %s@%s publié — https://clawhub.ai/xiaohequ/skills/%s\n' "$SLUG" "$VERSION" "$SLUG"
printf '  La fiche reste « pending » le temps des scans de sécurité (quelques minutes).\n'
