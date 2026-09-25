# AI AGENT RULES

1. **Verify repository**: work ONLY on thuexemayhanoi/game. Never touch sibling repos.
2. **Read before writing**: README → WORKFLOW → ARCHITECTURE → GAME-DESIGN →
   game-master-matrix.csv → active-work.json → run validators.
3. **RESUME → FIX → VERIFY → NEW FEATURE.** Never skip unfinished work.
4. **Lock** active-work.json before starting a feature; checkpoint every commit; release the
   lock when done. Respect locks held by other runs; recover stale locks from checkpoints.
5. **Idempotency**: never duplicate scenes, scripts, Matrix rows, feature IDs, save IDs, or
   rewards; never reset VERIFIED/DONE features.
6. **Honest status**: never fake passing tests, never overclaim (no "game complete", no
   "mobile supported", no "App Store ready" until actually true). Report exact state.
7. **Failure protocol**: max 3 repair attempts per root failure, then QA_FAILED or BLOCKED
   with recorded evidence. Do not hide failure.
8. **Commit hygiene**: conventional messages, inspected diffs, no secrets/caches/binaries.
9. **Engine discipline**: Godot 4.7.2 stable, GDScript, compatibility renderer,
   single-threaded web. No engine/language upgrades without documented migration reason.
10. **Scope discipline**: do not begin hundreds of features in one run. Bootstrap runs build
    infrastructure + one vertical slice. Future runs continue the Matrix.
11. **Session ends are not completion.** Leave truthful state for the next run.
