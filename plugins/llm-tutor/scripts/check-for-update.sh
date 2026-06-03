#!/usr/bin/env bash
# check-for-update.sh — compare the installed llm-tutor version against the
# latest GitHub release and print an upgrade recipe when one is available.
#
# llm-tutor is a Claude Code plugin, so its install/update lifecycle is
# managed by `/plugin update llm-tutor@llm-tutor`. We can't invoke that
# slash command from a skill, but we can tell the user exactly what to type
# (and whether typing it is worth their time).
#
# Output shape:
#   Installed: v0.3.0
#   Latest:    v0.3.0
#   You're up to date.
#
#   --- or, when an upgrade is available ---
#
#   Installed: v0.2.0
#   Latest:    v0.3.0
#
#   Update available!
#
#   Latest release notes:
#   <body of the latest GitHub release>
#
#   To update, run these two commands in Claude Code:
#     /plugin update llm-tutor@llm-tutor
#     /reload-plugins
#
# Exits 0 always — the skill consumer wants to display the output regardless
# of whether an update is available.

set -e

REPO="Flagrare/llm-tutor"
CACHE_DIR="$HOME/.claude/plugins/cache/llm-tutor/llm-tutor"

# --- installed version: the newest semver-sorted subdir under the cache ---
if [ ! -d "$CACHE_DIR" ]; then
  echo "llm-tutor is not installed via the plugin marketplace."
  echo "Install with:  /plugin marketplace add $REPO && /plugin install llm-tutor@llm-tutor"
  exit 0
fi

INSTALLED=$(ls -1 "$CACHE_DIR" 2>/dev/null | sort -V | tail -1)
if [ -z "$INSTALLED" ]; then
  echo "No installed version found in $CACHE_DIR."
  exit 0
fi

# --- latest release: prefer gh CLI (authenticated, no rate limit), curl fallback ---
LATEST=""
LATEST_NOTES=""
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  LATEST=$(gh api "repos/$REPO/releases/latest" --jq '.tag_name' 2>/dev/null | sed 's/^v//')
  LATEST_NOTES=$(gh api "repos/$REPO/releases/latest" --jq '.body' 2>/dev/null)
elif command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  RESP=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null)
  LATEST=$(echo "$RESP" | jq -r '.tag_name // empty' | sed 's/^v//')
  LATEST_NOTES=$(echo "$RESP" | jq -r '.body // empty')
fi

if [ -z "$LATEST" ]; then
  echo "Installed: v$INSTALLED"
  echo "Latest:    (couldn't reach GitHub)"
  echo
  echo "Try again later, or manually check https://github.com/$REPO/releases."
  exit 0
fi

echo "Installed: v$INSTALLED"
echo "Latest:    v$LATEST"
echo

if [ "$INSTALLED" = "$LATEST" ]; then
  echo "You're up to date."
  exit 0
fi

# --- behind: show notes + recipe ---
echo "Update available!"
echo
echo "Latest release notes:"
echo "─────────────────────"
printf "%s\n" "$LATEST_NOTES"
echo "─────────────────────"
echo
echo "To update, run these two commands in Claude Code:"
echo "  /plugin update llm-tutor@llm-tutor"
echo "  /reload-plugins"
