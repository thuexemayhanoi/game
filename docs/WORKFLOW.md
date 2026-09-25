# WORKFLOW — HANOI RIDER

## Golden rule

> RESUME → FIX → VERIFY → NEW FEATURE

## Feature lifecycle

1. **SELECT** — pick the highest-priority READY feature whose dependencies are DONE/VERIFIED.
2. **LOCK** — write `docs/state/active-work.json` (feature_id, run_id, started_at, start_commit).
3. **IMPLEMENT** — small, separable, data-driven changes following ARCHITECTURE.md.
4. **TEST** — write/run focused GUT tests. No fake passing tests.
5. **QA** — run full validation: `python3 scripts/validate_project.py` + headless boot + GUT.
6. **REPAIR** — fix failures. Max 3 attempts for the same root failure, then QA_FAILED/BLOCKED
   with recorded evidence.
7. **FULL VALIDATION** — all validators pass, project imports, game boots.
8. **UPDATE MATRIX** — set the real status and evidence URL/commit in the Matrix row.
9. **COMMIT** — clear conventional message (`feat(vehicle): ...`, `fix:`, `docs:`, `test:`, `ci:`, `deploy:`).
   Inspect the diff first. Never commit secrets, keys, caches, or huge binaries.
10. **CHECKPOINT** — update active-work.json (checkpoint_commit, last_checkpoint).
11. **VERIFY** — confirm CI green for the commit.
12. **DONE** — only after the Definition of Done gate (see README) is fully satisfied.

## Concurrency safety

- Before starting a feature, inspect `docs/state/active-work.json`.
- If a valid run holds the lock for the same feature: do not duplicate. Pick another READY feature
  or stop.
- If the lock is stale (run crashed): inspect commits + Matrix state, recover from the last valid
  checkpoint, resume safely, then take the lock.

## Checkpoint / resume

- Sessions end without warning (quota, timeout, crash). Leave feature state truthful.
- Next run MUST resume the active feature before any new work.

## Idempotency

Reruns must not duplicate scenes, scripts, Matrix rows, feature IDs, save IDs, or mission
rewards; must not overwrite valid work or reset VERIFIED/DONE features.

## Milestone completion gate

A milestone is complete only when every required P0 feature is VERIFIED or DONE, the full
suite passes, Web export passes, the live build works, critical controls work, and there is
no known critical regression.
