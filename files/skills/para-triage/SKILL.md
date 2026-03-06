---
name: para-triage
description: Classify changed files using PARA (Projects, Areas, Resources, Archive). Fires automatically when the git commit review threshold is reached, or invoke manually with /para-triage.
allowed-tools: Read, Glob, Grep, Write, Edit
user-invocable: true
agent-invocable: true
model: sonnet
---

# PARA Triage Workflow

Execute the following 7 steps in order. Use only the tools: Read, Glob, Grep, Write, Edit.

## Step 1 — Read configuration

Read `.para/config.json`. Extract `review_threshold` (default: 5).

## Step 2 — Read pending list

Read `.para/pending_classification.txt`. If the file is missing or its content is empty (zero bytes or only whitespace):

1. Output to the user: "No files pending PARA classification. Files are added to the pending list automatically on git commit (if the hook is installed), or you can run `/para-review` for a full repository review."
2. Check if the PARA hook is installed: read `.claude/settings.json` and look for an entry containing `para-hook.sh` in the `PostToolUse` hooks. If not found, also output: "The PARA commit hook is not installed yet. Run `/para-setup` to install it."
3. **STOP** — write nothing else, exit with no changes.

If the file has content, collect each non-blank line as a file path to classify.

## Step 3 — Classify each file

For each path in the pending list, apply the rules below in order. The **first matching rule wins**.

**File existence decision table:**

| Condition | Action |
|-----------|--------|
| File does not exist on disk | Classify as **Archive** candidate; Confidence = High; Note "file not found" |
| File exists | Continue to classification rules |

**Edge cases decision table (check before P/A/R/A rules):**

| File pattern | Classification | Notes |
|--------------|----------------|-------|
| `dist/`, `build/`, `out/` (directory prefix) | Skip | Generated output — do not classify |
| `*.min.js`, `*.min.css` | Skip | Minified artifact — do not classify |
| Binary file (non-UTF-8 content detected) | Skip | Binary — do not classify |
| `fixtures/`, `testdata/`, `__fixtures__/` | Resource | Test fixture reference material |
| `*.test.ts`, `*.spec.ts`, `*.test.js` | Project or Area | Classify by owning feature/module |

**PARA classification rules:**

| Category | Classify when | Examples |
|----------|---------------|---------|
| **Project** | File belongs to a time-bounded, goal-directed effort | `feature/auth-migration/login.ts`, sprint epic files, `src/checkout-v2/` |
| **Area** | File belongs to ongoing responsibility with no end date | `src/auth/`, `.github/workflows/ci.yml`, `src/api/middleware/` |
| **Resource** | File is reference material or reusable knowledge; consulted but rarely modified | `docs/api-patterns.md`, `notes/architecture.md`, design system tokens |
| **Archive** | File is inactive: effort complete, deprecated, or abandoned | `src/old-checkout/`, completed sprint branches, deprecated modules |

**Classification confidence decision table:**

| Condition | Confidence | Action |
|-----------|------------|--------|
| Path contains `feature/`, `sprint/`, `epic/`, version suffix (`-v2`, `-migration`) | High | Assign Project |
| Path is under `src/` with stable module name, no version suffix | High | Assign Area |
| Path is under `docs/`, `notes/`, `references/` | High | Assign Resource |
| Path contains `old-`, `deprecated-`, `archive/`, `legacy/` | High | Assign Archive |
| Path matches multiple rules or has ambiguous structure | Low | Assign best-guess category; mark `[UNCERTAIN]` in Notes |
| File exists but content reveals different purpose than path implies | Medium | Assign by content; explain in Notes |

## Step 4 — Detect lifecycle transitions

For each classified file, compare the new classification against any prior classification found in existing review files under `.para/reviews/`. Use Glob to list prior reviews, then Grep for the file path.

Apply this transition logic:

| Prior → Current | Transition label |
|-----------------|-----------------|
| Project → Area | Goal achieved; ongoing maintenance remains |
| Area → Archive | Responsibility ended or handed off |
| Project → Archive | Effort complete or abandoned |
| Resource → Archive | Reference material outdated |
| Any → same category | No transition |
| No prior record | New classification |

## Step 5 — Write review report

Determine today's date in `YYYY-MM-DD` format. The review file path is `.para/reviews/YYYY-MM-DD.md`.

If the file already exists today, append the new content (add a blank line before the new section). If it does not exist, create it. Use this exact template:

```
# PARA Triage Review — YYYY-MM-DD

## Classifications

| File | Category | Confidence | Notes |
|------|----------|------------|-------|
| path/to/file.ts | Project | High | auth-migration feature |

## Lifecycle Transitions

- [path/to/file.ts] Project → Area: goal achieved, ongoing maintenance remains

## Recommended Actions

- [ ] Move src/old-feature/ to Archive (completed sprint)
```

**MUST** include every classified file in the Classifications table. Omit "Lifecycle Transitions" section if no transitions detected. Omit "Recommended Actions" if no actions warranted. Write at least one recommended action for every Archive candidate or [UNCERTAIN] file.

## Step 6 — Update state

Read `.para/state.json`. Set `last_review` to the current ISO 8601 timestamp (e.g., `2026-03-05T14:32:00Z`). Write the updated JSON back to `.para/state.json`.

## Step 7 — Clear pending list

Write an empty string to `.para/pending_classification.txt`. **NEVER** delete the file — overwrite it with empty content.
