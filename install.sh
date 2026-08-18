#!/usr/bin/env bash
# Installs the whole Skills AI stack on this machine (macOS / Linux / Git Bash).
# Reads manifest.json, registers every marketplace, plugin and MCP server, and
# installs this repository itself as the `skills-ai` plugin.
# Safe to re-run: anything already present is skipped.
#
#   ./install.sh              full install
#   ./install.sh --skip-mcp   plugins only
#   ./install.sh --refresh    re-copy this repo into the plugin cache after
#                             editing BRIEF.md (plugin update is version-gated)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_MCP=0
SKIP_PLUGINS=0
REFRESH=0
for arg in "$@"; do
  case "$arg" in
    --skip-mcp)     SKIP_MCP=1 ;;
    --skip-plugins) SKIP_PLUGINS=1 ;;
    --refresh)      REFRESH=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

step() { printf '\033[36m==> %s\033[0m\n' "$1"; }
ok()   { printf '\033[32m    OK  %s\033[0m\n' "$1"; }
skip() { printf '\033[90m    --  %s\033[0m\n' "$1"; }
warn() { printf '\033[33m    !!  %s\033[0m\n' "$1"; }

find_claude() {
  if command -v claude >/dev/null 2>&1; then command -v claude; return; fi
  # Desktop app ships the CLI outside PATH.
  local candidates=(
    "$HOME/.local/bin/claude"
    "$HOME/Library/Application Support/Claude/claude-code"
    "$APPDATA/Claude/claude-code"
  )
  local c
  for c in "${candidates[@]}"; do
    [ -x "$c" ] && { echo "$c"; return; }
    if [ -d "$c" ]; then
      find "$c" -name 'claude' -o -name 'claude.exe' 2>/dev/null | sort | tail -1
      return
    fi
  done
}

CLAUDE="$(find_claude)"
if [ -z "${CLAUDE:-}" ] || [ ! -x "$CLAUDE" ]; then
  echo "Claude Code CLI not found. Install Claude Code first, then re-run." >&2
  exit 1
fi
step "Claude Code CLI: $CLAUDE"
ok "$("$CLAUDE" --version)"

MANIFEST="$REPO_ROOT/manifest.json"
# Minimal JSON reads via node (Claude Code already requires Node.js).
jq_node() { node -e "
  const m = require('$MANIFEST');
  $1
"; }

# ------------------------------------------------------------- marketplaces
step 'Registering marketplaces'
EXISTING_MARKETS="$("$CLAUDE" plugin marketplace list 2>&1 || true)"
while IFS=$'\t' read -r name repo; do
  [ -z "$name" ] && continue
  if printf '%s' "$EXISTING_MARKETS" | grep -qF "$name"; then
    skip "$name already registered"; continue
  fi
  if "$CLAUDE" plugin marketplace add "$repo" >/dev/null 2>&1; then
    ok "$name  <-  $repo"
  else
    warn "$name could not be added"
  fi
done < <(jq_node "for (const [k,v] of Object.entries(m.marketplaces)) console.log(k+'\t'+v)")

if printf '%s' "$EXISTING_MARKETS" | grep -qF 'skills-ai'; then
  skip 'skills-ai already registered'
elif "$CLAUDE" plugin marketplace add "$REPO_ROOT" >/dev/null 2>&1; then
  ok "skills-ai  <-  $REPO_ROOT"
else
  warn 'skills-ai could not be added'
fi

# ------------------------------------------------------------------ plugins
if [ "$REFRESH" -eq 1 ]; then
  step 'Refreshing the skills-ai plugin from this working copy'
  "$CLAUDE" plugin marketplace update skills-ai >/dev/null 2>&1 || true
  if "$CLAUDE" plugin uninstall skills-ai@skills-ai >/dev/null 2>&1; then
    ok 'cache cleared'
  else
    skip 'nothing cached'
  fi
fi

if [ "$SKIP_PLUGINS" -eq 0 ]; then
  step 'Installing plugins'
  INSTALLED="$("$CLAUDE" plugin list 2>&1 || true)"
  while read -r plugin; do
    [ -z "$plugin" ] && continue
    if printf '%s' "$INSTALLED" | grep -qF "$plugin"; then
      skip "$plugin already installed"; continue
    fi
    if "$CLAUDE" plugin install "$plugin" >/dev/null 2>&1; then
      ok "$plugin"
    else
      warn "$plugin failed"
    fi
  done < <(jq_node "m.plugins.concat(['skills-ai@skills-ai']).forEach(p => console.log(p))")
fi

# -------------------------------------------------------------- mcp servers
if [ "$SKIP_MCP" -eq 0 ]; then
  step 'Registering MCP servers'
  MCP_LIST="$("$CLAUDE" mcp list 2>&1 || true)"
  while IFS=$'\t' read -r name transport rest; do
    [ -z "$name" ] && continue
    if printf '%s' "$MCP_LIST" | grep -qE "^[[:space:]]*${name}:"; then
      skip "$name already configured"; continue
    fi
    if [ "$transport" = 'http' ]; then
      "$CLAUDE" mcp add --transport http --scope user "$name" "$rest" >/dev/null 2>&1 \
        && ok "$name" || warn "$name failed"
    else
      # shellcheck disable=SC2086
      "$CLAUDE" mcp add --scope user "$name" -- $rest >/dev/null 2>&1 \
        && ok "$name" || warn "$name failed"
    fi
  done < <(jq_node "for (const [k,v] of Object.entries(m.mcpServers)) {
      const rest = v.transport === 'http' ? v.url : [v.command].concat(v.args||[]).join(' ');
      console.log([k, v.transport, rest].join('\t'));
    }")
fi

printf '\n\033[32mDone. Restart Claude Code to load the new skills, plugins and hooks.\033[0m\n'
printf '\033[32mThe startup digest appears automatically; /skills-brief shows it again.\033[0m\n'
