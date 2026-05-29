#!/usr/bin/env bash
set -euo pipefail
DRY_RUN=false; FORCE=false
for arg in "$@"; do case "$arg" in --dry-run) DRY_RUN=true;; --force) FORCE=true;; esac; done
DIR="$(cd "$(dirname "$0")" && pwd)"
install_one() {
  local t="$1" l="$2"
  [ -d "$(dirname "$t")" ] || { echo "  skip $l: parent not found"; return; }
  [ -d "$t" ] && ! $FORCE && { echo "  warn $l: exists (--force to overwrite)"; return; }
  $DRY_RUN && { echo "  [dry-run] $l -> $t"; return; }
  local src="$DIR/skills/core-coordination"
  [ ! -f "$src/SKILL.md" ] && src="$DIR/plugin/vibe-agent/skills/core-coordination"
  mkdir -p "$t" && cp "$src/SKILL.md" "$t/"
  local pres="$DIR/plugin/vibe-agent/presets"
  if [ -d "$pres" ]; then rm -rf "$t/presets"; cp -r "$pres" "$t/presets"; fi
  echo "  ok $l -> $t"
}
echo "vibe-agent installer v0.1"; $DRY_RUN && echo "(dry-run: no files changed)"
for cli in claude codex gemini; do [ -d "$HOME/.$cli" ] && echo "  $cli: detected" || echo "  $cli: not found"; done
[ -d "$HOME/.claude" ] && install_one "$HOME/.claude/skills/core-coordination" "Claude Code"
[ -d "$HOME/.codex" ]  && install_one "$HOME/.codex/skills/core-coordination" "Codex"
if [ -d "$HOME/.gemini" ]; then
  if command -v gemini &>/dev/null; then
    $DRY_RUN && echo "  [dry-run] gemini skills install $DIR/skills/core-coordination" \
              || gemini skills install "$DIR/skills/core-coordination" --scope user
  else
    install_one "$HOME/.gemini/skills/core-coordination" "Gemini CLI"
  fi
fi
echo; echo "Done. Restart your agent(s) to pick up the skill."
