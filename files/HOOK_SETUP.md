# PARA Hook Setup

The PARA hook is a git `post-commit` hook that fires after every commit. It logs changed files and triggers PARA triage when the commit threshold is reached.

## How It Works

1. You make a `git commit` (from any tool — terminal, IDE, Claude Code, etc.)
2. The hook appends changed file paths to `.para/pending_classification.txt`
3. The hook increments `commits_since_review` in `.para/state.json`
4. When `commits_since_review >= review_threshold` (default: 5), the hook spawns a headless Claude session to run triage per `.claude/skills/para-triage/SKILL.md`

## Install

The hook is automatically injected into `.git/hooks/post-commit` by `sym add` / `sym sync`. No manual setup is needed.

To verify the hook is installed:

```sh
grep -q "symposia:sym-para" .git/hooks/post-commit && echo "Installed" || echo "Not installed"
```

If the hook is missing, run:

```sh
sym sync
```

## Coexistence with Other Hooks

The PARA hook content is wrapped in marker comments (`# --- symposia:sym-para ---`). Other hook content in `.git/hooks/post-commit` is preserved. If you use a hook manager (husky, lefthook, etc.), the PARA section coexists alongside it.

## Verify

1. Make a test commit
2. Check `.para/pending_classification.txt` — **MUST** contain the committed file paths
3. Check `.para/state.json` — `commits_since_review` **MUST** be incremented

## Configure

Edit `.para/config.json`:

| Field | Default | Description |
|-------|---------|-------------|
| `review_threshold` | `5` | Commits before auto-triage fires |

## Uninstall

Run `sym remove sym-para` to cleanly remove the hook section from `.git/hooks/post-commit`.

## Prerequisites

| Dependency | Required? | Notes |
|-----------|-----------|-------|
| `git` | **Yes** | Hook fires on git commit |
| `claude` CLI | No | Required only for auto-triage at threshold |
| `jq` | No | Used if available; falls back to `sed`/`grep` |

## Version Control

| File | Recommendation |
|------|---------------|
| `.para/config.json` | Commit (shared team config) |
| `.para/state.json` | Gitignore (ephemeral counter) |
| `.para/pending_classification.txt` | Gitignore (ephemeral queue) |
| `.para/reviews/*.md` | Commit (review history) |
| `.para/archive-index.json` | Commit (archive registry) |
