#!/bin/sh
# Claude Code PostToolUse hook — PARA framework file tracker
# Fires on Bash tool use. Checks if command was a git commit.
# If so, accumulates changed files and triggers triage at threshold.

set -eu

# ── 1. Read hook input from stdin ────────────────────────────────────────────
INPUT=$(cat)

# ── 2. Check if this was a git commit ────────────────────────────────────────
TOOL_INPUT=$(printf '%s' "$INPUT" | grep -o '"tool_input"[[:space:]]*:[[:space:]]*{[^}]*}' 2>/dev/null || true)
if [ -z "$TOOL_INPUT" ]; then
  exit 0
fi

# Extract the command string from tool_input
COMMAND=$(printf '%s' "$TOOL_INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | sed 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/' || true)
if [ -z "$COMMAND" ]; then
  exit 0
fi

# Only proceed if this was a git commit
case "$COMMAND" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# ── 3. Ensure .para directory structure exists ───────────────────────────────
mkdir -p .para/reviews .para/hooks

if [ ! -f .para/config.json ]; then
  printf '{\n  "review_threshold": 5\n}\n' > .para/config.json
fi

if [ ! -f .para/state.json ]; then
  printf '{\n  "last_commit": null,\n  "commits_since_review": 0,\n  "last_review": null,\n  "hook_version": "1.0.0"\n}\n' > .para/state.json
fi

if [ ! -f .para/pending_classification.txt ]; then
  : > .para/pending_classification.txt
fi

# ── 4. Append changed files to pending list ──────────────────────────────────
git diff-tree --no-commit-id -r --name-only HEAD >> .para/pending_classification.txt 2>/dev/null || true

# ── 5. Increment commits_since_review ────────────────────────────────────────
if command -v jq > /dev/null 2>&1; then
  current=$(jq -r '.commits_since_review // 0' .para/state.json 2>/dev/null)
  current=${current:-0}
  new_count=$((current + 1))
  tmp=$(mktemp)
  jq --argjson n "$new_count" '.commits_since_review = $n' .para/state.json > "$tmp" 2>/dev/null && mv "$tmp" .para/state.json
else
  current=$(grep -o '"commits_since_review"[[:space:]]*:[[:space:]]*[0-9]*' .para/state.json 2>/dev/null | grep -o '[0-9]*$')
  current=${current:-0}
  new_count=$((current + 1))
  sed "s/\"commits_since_review\"[[:space:]]*:[[:space:]]*[0-9]*/\"commits_since_review\": $new_count/" .para/state.json > .para/state.json.tmp 2>/dev/null && mv .para/state.json.tmp .para/state.json
fi

# ── 6. Check threshold ──────────────────────────────────────────────────────
if command -v jq > /dev/null 2>&1; then
  review_threshold=$(jq -r '.review_threshold // 5' .para/config.json 2>/dev/null)
else
  review_threshold=$(grep -o '"review_threshold"[[:space:]]*:[[:space:]]*[0-9]*' .para/config.json 2>/dev/null | grep -o '[0-9]*$')
fi
review_threshold=${review_threshold:-5}

# ── 7. If threshold reached, send system message to trigger triage ───────────
if [ "$new_count" -ge "$review_threshold" ] 2>/dev/null; then
  # Reset counter
  if command -v jq > /dev/null 2>&1; then
    tmp=$(mktemp)
    jq '.commits_since_review = 0' .para/state.json > "$tmp" 2>/dev/null && mv "$tmp" .para/state.json
  else
    sed "s/\"commits_since_review\"[[:space:]]*:[[:space:]]*[0-9]*/\"commits_since_review\": 0/" .para/state.json > .para/state.json.tmp 2>/dev/null && mv .para/state.json.tmp .para/state.json
  fi

  # Output system message — Claude will receive this as context
  printf '{"systemMessage": "PARA review threshold reached (%s commits since last review). Run PARA triage now: read and follow .claude/skills/para-triage/SKILL.md."}\n' "$review_threshold"
fi

exit 0
