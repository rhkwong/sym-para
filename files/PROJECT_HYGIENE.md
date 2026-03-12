# Project Hygiene

## Required Fields

Every project entry in `.para/state.json` **MUST** include these three fields:

| Field | Type | Rule | Example |
|-------|------|------|---------|
| `goal` | String (1 sentence) | State the specific outcome — no vague language | `"Ship JWT auth replacing session cookies by 2026-04-01"` |
| `deadline` | ISO date or `"ongoing"` | Use `"ongoing"` only as a signal to reclassify as Area | `"2026-04-01"` or `"ongoing"` |
| `next_action` | Verb phrase | Describe the immediate next step — no nouns alone | `"Write migration script for users table"` |

**If `deadline` is `"ongoing"`, reclassify the entry as an Area immediately.**

## Wrong vs Right

| Field | Wrong | Right |
|-------|-------|-------|
| `goal` | `"Improve auth"` | `"Replace session cookies with JWT in src/auth/ by 2026-04-01"` |
| `deadline` | `"soon"` or `"TBD"` | `"2026-04-01"` |
| `next_action` | `"Auth work"` | `"Write migration script for users table in db/migrations/"` |
| `goal` | `"Clean up tests"` | `"Delete all skipped tests in src/__tests__/ by 2026-03-15"` |
| `next_action` | `"Research"` | `"Read RFC 7519 and document key claims in docs/jwt-notes.md"` |

## Stale Detection Thresholds

| Project Type | Stale After |
|-------------|-------------|
| `feature` | 14 days no commit |
| `bug` | 7 days no commit |
| `spike` | 5 days no commit |
| `exploration` | 21 days no commit |

**Stale action: flag in triage review. NEVER auto-archive.**

Detect stale projects by checking last commit date per path: `git log --follow -1 --format="%ci" -- <path>`. Flag stale projects in the next triage session — do not modify state automatically.

## Healthy Project Entry Example

```json
{
  "path": "feature/auth-migration/",
  "category": "project",
  "type": "feature",
  "goal": "Replace session cookies with JWT in src/auth/ by 2026-04-01",
  "deadline": "2026-04-01",
  "next_action": "Write migration script for users table in db/migrations/",
  "last_commit": "2026-03-01"
}
```

## Enforcement Rules

| Condition | Action |
|-----------|--------|
| Missing `goal` | Block entry from `.para/state.json` — require field before saving |
| Missing `deadline` | Block entry — require ISO date or `"ongoing"` |
| Missing `next_action` | Block entry — require verb phrase |
| `deadline: "ongoing"` present | Reclassify entry as `area` in `.para/state.json` |
| Entry exceeds stale threshold | Flag in next triage; do not modify state automatically |
| `next_action` is a noun (e.g., `"Auth"`) | Reject — require a verb phrase |