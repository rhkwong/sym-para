#!/bin/sh
# Git post-commit hook — PARA framework file tracker
# Fires on every git commit. Accumulates changed files and spawns
# headless Claude to triage when the review threshold is reached.

set -eu

# ── 1. Ensure .para directory structure exists ───────────────────────────────
mkdir -p .para/reviews

if [ ! -f .para/config.json ]; then
  printf '{\n  "review_threshold": 1\n}\n' > .para/config.json
fi

if [ ! -f .para/state.json ]; then
  printf '{\n  "last_commit": null,\n  "commits_since_review": 0,\n  "last_review": null,\n  "hook_version": "2.0.0"\n}\n' > .para/state.json
fi

if [ ! -f .para/pending_classification.txt ]; then
  : > .para/pending_classification.txt
fi

# ── 2. Append changed files to pending list ──────────────────────────────────
git diff-tree --no-commit-id -r --name-only HEAD >> .para/pending_classification.txt 2>/dev/null || true

# ── 3. Increment commits_since_review ────────────────────────────────────────
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

# ── 4. Check threshold ──────────────────────────────────────────────────────
if command -v jq > /dev/null 2>&1; then
  review_threshold=$(jq -r '.review_threshold // 1' .para/config.json 2>/dev/null)
else
  review_threshold=$(grep -o '"review_threshold"[[:space:]]*:[[:space:]]*[0-9]*' .para/config.json 2>/dev/null | grep -o '[0-9]*$')
fi
review_threshold=${review_threshold:-1}

# ── 5. If threshold reached, spawn headless Claude to run triage ─────────────
if [ "$new_count" -ge "$review_threshold" ] 2>/dev/null; then
  # Reset counter
  if command -v jq > /dev/null 2>&1; then
    tmp=$(mktemp)
    jq '.commits_since_review = 0' .para/state.json > "$tmp" 2>/dev/null && mv "$tmp" .para/state.json
  else
    sed "s/\"commits_since_review\"[[:space:]]*:[[:space:]]*[0-9]*/\"commits_since_review\": 0/" .para/state.json > .para/state.json.tmp 2>/dev/null && mv .para/state.json.tmp .para/state.json
  fi

  # Guard: only run if claude is available and no triage is already in progress
  LOCK=".para/triage.lock"
  if command -v claude > /dev/null 2>&1 && [ ! -f "$LOCK" ]; then
    touch "$LOCK"
    (
      claude -p "$(cat <<'PROMPT'
Read and execute the PARA triage workflow defined in .claude/skills/para-triage/SKILL.md.
Follow every step exactly. The pending files are in .para/pending_classification.txt.
PROMPT
      )" --dangerously-skip-permissions \
         > .para/triage.log 2>&1
      rm -f "$LOCK"
    ) &
  fi
fi

exit 0
