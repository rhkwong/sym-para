# PARA Hook Setup

The PARA hook is a Claude Code `PostToolUse` hook that fires after every Bash command. It detects `git commit` commands, logs changed files, and triggers PARA triage when the commit threshold is reached.

## How It Works

1. Claude runs a `git commit` via the Bash tool
2. The hook appends changed file paths to `.para/pending_classification.txt`
3. The hook increments `commits_since_review` in `.para/state.json`
4. When `commits_since_review >= review_threshold` (default: 5), the hook sends a system message instructing Claude to run triage per `.claude/skills/para-triage/SKILL.md`

## Install

1. Add the hook to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .para/hooks/para-hook.sh"
          }
        ]
      }
    ]
  }
}
```

2. Make the hook script executable:

```sh
chmod +x .para/hooks/para-hook.sh
```

3. Restart Claude Code to load the hook.

## Merge with Existing Hooks

| Existing `PostToolUse`? | Action |
|------------------------|--------|
| No `hooks` key | Add the full `hooks` block above |
| Has `hooks` but no `PostToolUse` | Add the `PostToolUse` array |
| Has `PostToolUse` array | Append the PARA hook object to the array |

## Verify

1. Make a test commit in a Claude Code session
2. Check `.para/pending_classification.txt` — **MUST** contain the committed file paths
3. Check `.para/state.json` — `commits_since_review` **MUST** be incremented

## Configure

Edit `.para/config.json`:

| Field | Default | Description |
|-------|---------|-------------|
| `review_threshold` | `5` | Commits before auto-triage fires |

## Uninstall

1. Remove the PARA hook entry from `.claude/settings.json`
2. Restart Claude Code

## Prerequisites

| Dependency | Required? | Notes |
|-----------|-----------|-------|
| Claude Code | **Yes** | Hook only fires inside Claude Code sessions |
| `jq` | No | Used if available; falls back to `sed`/`grep` |

## Version Control

| File | Recommendation |
|------|---------------|
| `.para/config.json` | Commit (shared team config) |
| `.para/state.json` | Gitignore (ephemeral counter) |
| `.para/pending_classification.txt` | Gitignore (ephemeral queue) |
| `.para/reviews/*.md` | Commit (review history) |
| `.para/archive-index.json` | Commit (archive registry) |
