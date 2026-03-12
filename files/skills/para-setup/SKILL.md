---
name: para-setup
description: Set up PARA framework infrastructure — verifies the git commit hook, creates required directories and files, configures .gitignore, and explains how to get started.
allowed-tools: Read, Write, Edit, Bash, Glob
user-invocable: true
agent-invocable: false
---

# PARA Setup Wizard

Execute all steps in order.

## Step 1 — Verify hook installation

Check if `.git/hooks/post-commit` exists and contains a `symposia:sym-para` marker section.

- If the marker is found, report: "PARA post-commit hook is installed."
- If the file does not exist or the marker is missing, report: "PARA post-commit hook is not installed. Run `sym sync` to install it." **Continue with remaining steps** — the hook is not required for manual usage.

## Step 2 — Create missing infrastructure

Check for and create any missing files/directories:

| Path | Action if missing |
|------|-------------------|
| `.para/reviews/` | Create directory |
| `.para/pending_classification.txt` | Create empty file |
| `.para/archive-index.json` | Create file containing `[]` |
| `.para/config.json` | Do nothing — this is shipped by the package and should already exist |
| `.para/state.json` | Do nothing — this is shipped by the package and should already exist |

## Step 3 — Configure .gitignore

Read `.gitignore` (create it if it does not exist). Append any of the following lines that are not already present:

```
.para/state.json
.para/pending_classification.txt
```

Do not duplicate lines that already exist in `.gitignore`.

## Step 4 — Explain PARA

Output the following to the user:

> **PARA** organizes codebase knowledge into four categories: **Projects** (time-bounded goals with deadlines), **Areas** (ongoing responsibilities), **Resources** (reference material), and **Archive** (inactive items from any category). The git post-commit hook tracks changed files and triggers automatic triage after each commit. You can also run `/para-triage` manually to classify pending files, or `/para-review` for a full periodic review.

## Step 5 — Suggest first action

Output:

> **Next steps:** Run `/para-review` now to classify your existing codebase, or just start coding and triage will fire automatically after each commit. See `.claude/docs/para/QUICK_REFERENCE.md` for the full classification decision table.
