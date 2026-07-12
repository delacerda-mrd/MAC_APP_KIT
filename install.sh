#!/usr/bin/env bash
# Install/update MAC_APP_KIT integrations on this machine:
#   agents/app-*.md   -> ~/.claude/agents/
#   skills/*/SKILL.md -> ~/.claude/skills/<name>/SKILL.md   (/app)
# Idempotent — rerun after editing any master file.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$HOME/.claude/agents"
SKILL_DIR="$HOME/.claude/skills"

mkdir -p "$AGENT_DIR" "$SKILL_DIR"

cp "$KIT_DIR"/agents/app-*.md "$AGENT_DIR/"
echo "agents installed: $(ls "$KIT_DIR"/agents/app-*.md | xargs -n1 basename | tr '\n' ' ')"

for skill_master in "$KIT_DIR"/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$skill_master")")"
  mkdir -p "$SKILL_DIR/$name"
  cp "$skill_master" "$SKILL_DIR/$name/SKILL.md"
  echo "skill installed: /$name"
done

echo "done — verify with /agents and by typing /app in any project folder"
