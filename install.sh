#!/usr/bin/env bash
# Install/update MAC_APP_KIT integrations on this machine:
#   agents/app-*.md   -> ~/.claude/agents/
#   skills/*/SKILL.md -> ~/.claude/skills/<name>/SKILL.md   (/app)
# Pulls the kit repo first so installs are always from the latest committed
# state. Idempotent — rerun after editing any master file.
#
# Usage:
#   bash install.sh            install/update from the latest kit state
#   bash install.sh --push     commit any uncommitted kit changes and push
#                              (the one-command backup), then install
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$HOME/.claude/agents"
SKILL_DIR="$HOME/.claude/skills"

PUSH=0
[[ "${1:-}" == "--push" ]] && PUSH=1

# --push: commit whatever is uncommitted in the kit, then push. This is the
# backup path — an unpushed kit change on one machine is a future merge
# conflict on the other.
if [[ $PUSH -eq 1 ]]; then
  if [[ -n "$(git -C "$KIT_DIR" status --porcelain)" ]]; then
    git -C "$KIT_DIR" status --short
    printf 'Commit message: '
    read -r MSG
    [[ -z "$MSG" ]] && { echo "empty message — aborting"; exit 1; }
    git -C "$KIT_DIR" add -A
    git -C "$KIT_DIR" commit -m "$MSG"
  else
    echo "nothing to commit — kit is clean"
  fi
  git -C "$KIT_DIR" push && echo "pushed to $(git -C "$KIT_DIR" remote get-url origin)"
fi

# Always install from the latest committed state.
git -C "$KIT_DIR" pull --ff-only || echo "offline — installing local copy"

mkdir -p "$AGENT_DIR" "$SKILL_DIR"

cp "$KIT_DIR"/agents/app-*.md "$AGENT_DIR/"
echo "agents installed: $(ls "$KIT_DIR"/agents/app-*.md | xargs -n1 basename | tr '\n' ' ')"

for skill_master in "$KIT_DIR"/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$skill_master")")"
  mkdir -p "$SKILL_DIR/$name"
  cp "$skill_master" "$SKILL_DIR/$name/SKILL.md"
  echo "skill installed: /$name"
done

# Report exactly which kit version just landed on this machine.
echo
echo "kit version: $(git -C "$KIT_DIR" rev-parse --short HEAD) on $(git -C "$KIT_DIR" rev-parse --abbrev-ref HEAD)"
if [[ -f "$KIT_DIR/KIT_CHANGELOG.md" ]]; then
  echo "latest KIT_CHANGELOG entry (first 15 lines):"
  awk '/^## /{if (n++) exit} n' "$KIT_DIR/KIT_CHANGELOG.md" | head -15 | sed 's/^/  /'
  echo "  ... (full entry in KIT_CHANGELOG.md)"
fi

echo
echo "done — verify with /agents and by typing /app in any project folder"
