---
name: para-review
description: Run a manual periodic PARA review to verify classifications, detect stale projects, and generate a review report. Use for quarterly reviews or on-demand organization audits.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
agent-invocable: true
model: sonnet
---

# PARA Periodic Review Checklist

Complete every item in order. Do not skip sections.

---

## Pre-Review Checklist

Verify and fix the following before beginning the review:

- [ ] `.para/config.json` exists and contains valid JSON with `review_threshold` field — **STOP if missing** (run `/para-setup` first)
- [ ] `.para/state.json` exists and contains valid JSON — **STOP if missing** (run `/para-setup` first)
- [ ] `.para/pending_classification.txt` exists (may be empty) — **create empty file if missing**
- [ ] `.para/reviews/` directory exists — **create directory if missing**
- [ ] `.para/archive-index.json` exists — **create file containing `[]` if missing**
- [ ] The repository has at least one commit in `git log` — **STOP if no commits**

Only STOP for truly unrecoverable issues (no git repo, missing `.para/config.json` or `.para/state.json`). Create any missing infrastructure files automatically.

---

## During-Review Checklist

Complete every item for each file/project under review:

- [ ] Every path in `.para/pending_classification.txt` has a category assigned (Project / Area / Resource / Archive)
- [ ] Every `[UNCERTAIN]` classification has an explanatory note
- [ ] All files that no longer exist on disk are classified as Archive candidates
- [ ] Generated files (`dist/`, `*.min.js`, `build/`) are **excluded** from classification
- [ ] Stale projects are identified and flagged (see thresholds below)
- [ ] Lifecycle transitions are documented for every file that changed category
- [ ] Recommended actions are written for every Archive candidate and every `[UNCERTAIN]` item

**Stale project thresholds by project type:**

| Type | Stale after | Action when stale |
|------|-------------|-------------------|
| feature | 14 days no commit | Flag for Project → Archive transition |
| bug | 7 days no commit | Flag for Project → Archive transition |
| spike | 5 days no commit | Flag for Project → Archive transition |
| exploration | 21 days no commit | Flag for Project → Archive transition |

Determine project type from the file path prefix or from `.para/config.json` if `project_types` is configured. Default to `feature` if type is ambiguous.

Check last commit date with: `git log --follow -1 --format="%ci" -- <path>`

---

## Post-Review Checklist

Complete every item after classification is finished:

- [ ] Review report written to `.para/reviews/YYYY-MM-DD.md` using the standard template
- [ ] Review report contains a Classifications table with every reviewed file
- [ ] Review report contains a Lifecycle Transitions section (omit only if zero transitions occurred)
- [ ] Review report contains a Recommended Actions section (omit only if zero actions required)
- [ ] `.para/state.json` `last_review` field updated to current ISO 8601 timestamp
- [ ] `.para/pending_classification.txt` cleared (overwritten with empty string — **NEVER** deleted)
- [ ] Review report committed to version control: `git add .para/reviews/ .para/state.json && git commit -m "chore: PARA review YYYY-MM-DD"`

---

## Quick Reference: Classification Rules

| Category | Classify when |
|----------|---------------|
| **Project** | Time-bounded goal with a deadline — `feature/auth-migration/`, sprint epics |
| **Area** | Ongoing responsibility, no end date — `src/auth/`, `ci.yml` |
| **Resource** | Reference or reusable knowledge — `docs/api-patterns.md`, design tokens |
| **Archive** | Inactive: complete, deprecated, or abandoned — `src/old-checkout/` |
