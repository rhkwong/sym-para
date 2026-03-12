# PARA Framework Quick Reference

## Category Definitions

| Category | One-Line Criteria |
|----------|-------------------|
| **Project** | Time-bounded effort with a specific goal and deadline |
| **Area** | Ongoing responsibility with no end date |
| **Resource** | Reference material or reusable knowledge |
| **Archive** | Inactive item moved from any other category |

## Classify by File Type

| File Type | Classify As | Example Path |
|-----------|-------------|--------------|
| Feature branch work | Project | `feature/auth-migration/design.md` |
| Sprint epic planning | Project | `.para/projects/q1-auth-overhaul/` |
| Core module source | Area | `src/auth/middleware.ts` |
| CI/CD pipeline config | Area | `.github/workflows/deploy.yml` |
| API reference doc | Resource | `docs/api-patterns.md` |
| Architecture decision record | Resource | `docs/adr/0012-use-postgres.md` |
| Unit/integration tests | Area | `src/auth/__tests__/middleware.test.ts` |
| DB migration file | Project | `migrations/2024-01-15-add-users.sql` |
| Exploratory spike | Project (in progress) / Archive (done) | `spikes/graphql-federation/` |
| Completed feature branch | Archive | `.para/archive/feature-auth-migration/` |
| Deprecated module | Archive | `.para/archive/legacy-oauth/` |
| Learning notes | Resource | `docs/learnings/react-query-patterns.md` |

## When to Classify

| Trigger | Action |
|---------|--------|
| New file added to repo | Classify immediately; default to Area if unsure, then review |
| PARA review invoked | Invoke `/para-triage` or read `.claude/skills/para-triage/SKILL.md` |
| Feature branch merged | Move Project items to Archive via `.claude/docs/para/LIFECYCLE.md` |
| Reorganization initiated | Apply `.claude/docs/para/PROJECT_HYGIENE.md` rules |
| Quarterly review | Invoke `/para-review` or read `.claude/skills/para-review/SKILL.md` |

## Critical Rules

- **MUST** assign every file exactly one PARA category
- **MUST** move completed Projects to Archive within 48 hours of completion
- **NEVER** leave files unclassified in `.para/state.json`
- **IMPORTANT**: When a file fits two categories, apply the tiebreaker rule below

## Edge Case Decision Table

| Situation | Tiebreaker Rule | Classify As |
|-----------|-----------------|-------------|
| Feature with ongoing tests | Tests maintain the Area after feature ships | Area (tests), Project (feature work) |
| ADR created during a sprint | Reference value outlasts the sprint | Resource |
| Migration script post-merge | Execution done; script is historical | Archive |
| Spike that became production code | Code now maintains a standard | Area |
| Config shared by multiple teams | No deadline; ongoing responsibility | Area |
| Spike still in progress | Has a bounded evaluation goal | Project |
| Runbook created for a postmortem | Reusable reference, not time-bounded | Resource |

**Tiebreaker Rule**: When an item fits two categories, ask "Does this have an end date?" — Yes → Project; No → ask "Is it reusable reference?" — Yes → Resource; No → Area. Items that are inactive → Archive.

## Wrong/Right Contrast

| Wrong | Right | Reason |
|-------|-------|--------|
| Classify `src/auth/` as Project | Classify `src/auth/` as Area | Source modules have no deadline |
| Classify `docs/api-patterns.md` as Area | Classify `docs/api-patterns.md` as Resource | Reference docs are consulted, not maintained on a schedule |
| Leave a merged feature branch as Project | Move merged feature to Archive | Completed Projects **MUST** be archived |
| Classify test files as Resource | Classify test files as Area | Tests are ongoing responsibilities, not reference material |
| Add new work to an archived item | Create a new Project instead | Archive is read-only |
| Classify a spike as Area | Classify an active spike as Project | Spikes have bounded evaluation goals |

## Cross-References

| Doc | Use When |
|-----|----------|
| `.claude/docs/para/LIFECYCLE.md` | Moving items through Project → Area → Archive stages (includes archive rules) |
| `.claude/skills/para-triage/SKILL.md` | Running the full PARA triage process (or `/para-triage`) |
| `.claude/docs/para/HOOK_SETUP.md` | Installing the Claude Code commit hook |
| `.claude/skills/para-review/SKILL.md` | Conducting periodic PARA reviews (or `/para-review`) |
| `.claude/docs/para/PROJECT_HYGIENE.md` | Keeping Projects clean and deadline-tracked |