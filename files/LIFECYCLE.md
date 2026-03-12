# PARA Lifecycle Transitions

## Six Transition Types

| # | Transition | Trigger Condition | Action | Resulting Category | Codebase Example |
|---|-----------|-------------------|--------|--------------------|-----------------|
| 1 | Project → Area | Goal achieved; ongoing maintenance remains | Move project directory to the corresponding area path; update `.para/state.json` status to `area` | Area | `feature/auth-migration/` ships — move to `src/auth/`; update state entry from `project` to `area` |
| 2 | Project → Archive | Goal achieved; no maintenance needed | Move project directory to archive; add archive entry with date and tags | Archive | `feature/dark-mode/` ships with no follow-on work — move to `archive/feature-dark-mode/`; log entry in `.para/archive-index.json` |
| 3 | Area → Project | Specific goal and deadline emerge for an ongoing responsibility | Create a new project entry in `.para/state.json` with `goal`, `deadline`, `next_action`; link back to the originating area | Project | `ci/` maintenance gets a Q2 deadline — create `project/ci-refactor-q2/` with `deadline: 2026-06-30` and link `area: ci/` |
| 4 | Resource → Project | Active development begins on a reference item | Promote the resource to a project entry; set `goal`, `deadline`, `next_action` | Project | `docs/api-v1.md` is being rewritten — create `project/api-v2-docs/` with `goal: "Publish updated API reference"` and `deadline: 2026-04-15` |
| 5 | Resource → Archive | Reference item is no longer relevant | Move the resource file to archive; add archive entry with `deprecated` tag | Archive | `docs/jquery-patterns.md` has zero references — move to `archive/docs/jquery-patterns.md`; tag `[deprecated, docs]` |
| 6 | Archive → Project | Archived item becomes active again | Copy archive item to a new project directory; set `goal`, `deadline`, `next_action`; retain original archive entry | Project | Shelved `archive/feature-x/` is greenlit — create `project/feature-x-revival/`; keep archive entry intact |

## Transition Rules

**NEVER auto-delete — only archive.**

| Rule | Action |
|------|--------|
| Goal completed, no ongoing work | Archive the project |
| Goal completed, maintenance required | Move to Area |
| Ongoing responsibility gains a deadline | Promote to Project |
| Reference material enters active development | Promote to Project |
| Reference material goes stale | Archive the resource |
| Archived item reactivated | Create new Project; preserve archive entry |

## State Entry Format

Update `.para/state.json` on every transition:

```json
{
  "path": "feature/auth-migration/",
  "category": "area",
  "previous_category": "project",
  "transitioned_date": "2026-01-15"
}
```

## Transition Checklist

Execute these steps in order for every transition:

1. Identify the trigger condition in the table above.
2. Move or copy files to the target path.
3. Update `.para/state.json` with the new category and `transitioned_date`.
4. If archiving, add an entry to `.para/archive-index.json`.
5. If promoting to Project, set `goal`, `deadline`, and `next_action` immediately.
6. Remove stale references from the originating category (never delete — move only).

## Archive Rules

### Archive Entry Format

Every archived item **MUST** have an entry in `.para/archive-index.json` with these four fields:

| Field | Type | Rule | Example |
|-------|------|------|---------|
| `path` | String | Fully-qualified path from repo root | `"src/old-auth/"` |
| `original_category` | Enum | One of: `project`, `area`, `resource` | `"project"` |
| `archive_date` | ISO date | Date the item was archived | `"2026-01-15"` |
| `tags` | Array of strings | Use standard vocabulary; add custom tags only if no standard tag fits | `["auth", "deprecated", "migration"]` |

Example entry:

```json
{
  "path": "src/old-auth/",
  "original_category": "project",
  "archive_date": "2026-01-15",
  "tags": ["auth", "deprecated", "migration"]
}
```

### Standard Tag Vocabulary

Use these tags before creating custom tags:

| Tag | Use When |
|-----|----------|
| `auth` | Item relates to authentication or authorization |
| `api` | Item relates to an API surface or client |
| `deprecated` | Item is superseded and no longer used |
| `reference` | Item is kept for future reference only |
| `spike` | Item was a time-boxed technical investigation |
| `config` | Item relates to build, CI, or environment configuration |
| `migration` | Item relates to a data or schema migration |
| `feature` | Item was a user-facing feature effort |
| `bug` | Item was a bug fix effort |
| `performance` | Item relates to profiling or optimization work |
| `docs` | Item is documentation |

Custom tags: Use `kebab-case` (e.g., `oauth2-pkce`) only when no standard tag fits.

### Archive Enforcement Rules

**NEVER delete archived items without explicit human instruction.**

| Condition | Action |
|-----------|--------|
| Item no longer active | Archive it — move files, add entry to `.para/archive-index.json` |
| Archive entry missing required field | Block the entry — require all four fields |
| Tag not in standard vocabulary | Check standard table first; use custom only if no match |
| Archived item reactivated | Create a new Project; preserve the archive entry intact |
| Disk space concern | Report the concern to a human — do not delete |
| Item appears unused | Archive it — do not delete |