---
name: para-setup
description: Set up PARA framework infrastructure — installs the git commit hook, creates required directories and files, configures .gitignore, and explains how to get started.
allowed-tools: Read, Write, Edit, Bash, Glob
user-invocable: true
agent-invocable: false
---

# PARA Setup Wizard

Execute all steps in order.

## Step 1 — Check hook status

Read `.claude/settings.json`. Check if a `PostToolUse` hook entry containing `para-hook.sh` already exists.

- If the hook is already configured, report: "PARA hook is already installed."
- If `.claude/settings.json` does not exist or has no hooks, proceed to Step 2.

## Step 2 — Install hook

Based on the current state of `.claude/settings.json`, apply the correct action:

| Existing state | Action |
|----------------|--------|
| File does not exist | Create `.claude/settings.json` with the full hooks block below |
| File exists, no `hooks` key | Add the `hooks` key with the block below |
| File has `hooks` but no `PostToolUse` | Add the `PostToolUse` array to `hooks` |
| File has `PostToolUse` array | Append the PARA hook object to the existing array |

Hook block to add:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "type": "command",
        "command": "bash .para/hooks/para-hook.sh"
      }
    ]
  }
}
```

Then make the hook script executable:

```bash
chmod +x .para/hooks/para-hook.sh
```

## Step 3 — Create missing infrastructure

Check for and create any missing files/directories:

| Path | Action if missing |
|------|-------------------|
| `.para/reviews/` | Create directory |
| `.para/pending_classification.txt` | Create empty file |
| `.para/archive-index.json` | Create file containing `[]` |
| `.para/config.json` | Do nothing — this is shipped by the package and should already exist |
| `.para/state.json` | Do nothing — this is shipped by the package and should already exist |

## Step 4 — Configure .gitignore

Read `.gitignore` (create it if it does not exist). Append any of the following lines that are not already present:

```
.para/state.json
.para/pending_classification.txt
```

Do not duplicate lines that already exist in `.gitignore`.

## Step 5 — Explain PARA

Output the following to the user:

> **PARA** organizes codebase knowledge into four categories: **Projects** (time-bounded goals with deadlines), **Areas** (ongoing responsibilities), **Resources** (reference material), and **Archive** (inactive items from any category). The git commit hook you just installed tracks changed files and triggers automatic triage after each commit. You can also run `/para-triage` manually to classify pending files, or `/para-review` for a full periodic review.

## Step 6 — Suggest first action

Output:

> **Next steps:** Run `/para-review` now to classify your existing codebase, or just start coding and triage will fire automatically after each commit. See `.claude/docs/para/QUICK_REFERENCE.md` for the full classification decision table.
