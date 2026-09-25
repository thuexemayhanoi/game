# HANOI RIDER: OPEN CITY

Original open-world motorbike action/adventure game set in a fictional, Hanoi-inspired city.
Built with **Godot 4.7.2 stable** (Compatibility renderer) in **GDScript**.
Primary continuous deployment target: **GitHub Pages** — <https://thuexemayhanoi.github.io/game/>

## ⚠️ MANDATORY READING ORDER FOR EVERY AI AGENT / CONTRIBUTOR

Before implementing **anything**:

1. Read `README.md` (this file)
2. Read `docs/WORKFLOW.md`
3. Read `docs/ARCHITECTURE.md`
4. Read `docs/GAME-DESIGN.md`
5. Read `docs/matrix/game-master-matrix.csv`
6. Inspect `docs/state/active-work.json`
7. Run validation: `python3 scripts/validate_project.py`
8. Resume unfinished work FIRST

### Priority rule (always in this order)

> RESUME → FIX → VERIFY → NEW FEATURE

Never start new feature work while another feature is IN_PROGRESS, QA_FAILED, or the
validation suite is failing.

## Project identity

- **Repository:** thuexemayhanoi/game (only this repository; never touch sibling repos)
- **Working title:** HANOI RIDER: OPEN CITY
- **Engine:** Godot 4.7.2 stable, GDScript, Compatibility (gl_compatibility) renderer
- **Web baseline:** single-threaded Web export
- **IP rule:** 100% original content. No assets, maps, names, music, models, storylines or
  branding from GTA or any other game. See `docs/ASSET-POLICY.md`.

## Vision

A systemic open-world city built around motorbike freedom: dense traffic, delivery and
ride-hailing missions, street races, a light police pursuit system, garages, tuning, and a
living day/night city — playable in a browser, on phones, and later as native apps.

## Platform goals

| Tier | Platforms |
|------|-----------|
| Primary now | Desktop/laptop browsers, mobile browsers, tablets, keyboard+mouse, gamepads |
| Future | Android, iOS, Windows, Linux, macOS native builds |

See `docs/PLATFORMS.md`. Do NOT claim "mobile supported" until tested on real devices.

## Architecture (summary)

Separable systems under `src/`: core, player, vehicles, world, traffic, npc, police,
missions, economy, progression, ui, audio, platform, data. Content is data-driven.
The world is district + chunk + streaming based; there is no single giant world scene.
Mission logic never requires rendering; save logic never depends on UI; vehicle simulation
is testable outside the full open world. Full detail: `docs/ARCHITECTURE.md`.

## Master Matrix (authoritative backlog)

`docs/matrix/game-master-matrix.csv` is the single source of truth for all features.

- IDs: GAME-0001 … (unique, never reused)
- Statuses: PLANNED, READY, IN_PROGRESS, IMPLEMENTED, QA_FAILED, BLOCKED, VERIFIED, DONE
- Milestones: M0 Repository Foundation → M14 Stretch systems
- `docs/matrix/test-matrix.csv` maps features to automated tests
- `docs/matrix/release-matrix.csv` tracks releases

## Workflow & state machine

Every feature follows: SELECT → LOCK → IMPLEMENT → TEST → QA → REPAIR → FULL VALIDATION →
UPDATE MATRIX → COMMIT → CHECKPOINT → VERIFY → DONE.

- Lock state lives in `docs/state/active-work.json`.
- Scheduled runs may overlap: check the lock before starting; recover stale locks from the
  last valid checkpoint.
- Max 3 automatic repair attempts for the same root failure; then set QA_FAILED or BLOCKED
  with recorded evidence. Never hide failure.
- Full rules: `docs/WORKFLOW.md`, `docs/AI-AGENT-RULES.md`.

## Testing strategy

- Python validators (schema, matrix, assets, save schema, build budget) — run in CI
- GUT 9.7.1 unit/integration tests for GDScript
- Headless Godot boot smoke test
- Playwright browser smoke tests over the Web build (5 viewports)
- No fake passing tests. See `docs/TESTING.md`.

## CI / CD

- `.github/workflows/ci.yml` — validation, Godot import, headless boot, GUT, Web export, browser smoke
- `.github/workflows/pages.yml` — deploys only verified main builds to GitHub Pages
- Never deploy when required CI fails.

## Checkpoint / resume

A session ending is NOT completion. If a run dies (quota, timeout, crash), leave the
feature in its real state; the next run must resume it, never silently skip it.
Reruns must be idempotent: no duplicate scenes, scripts, Matrix rows, feature IDs, or save IDs.

## Definition of Done (feature)

Implementation exists; acceptance criteria satisfied; focused test passes; required
integration test passes; repository validation passes; project imports; game boots;
required platform export passes; no known blocking regression; evidence recorded.
**Code existing does NOT mean DONE.**

## Current milestone

**M0 — Repository Foundation** (foundation + CI + first playable vertical slice).
See `docs/state/milestone-status.md`.

## Copyright & assets

All content original or permissively licensed. Track every third-party asset in
`docs/ASSET-POLICY.md` (asset, source, author, license, attribution, modifications).
No unlicensed commercial-game assets, ever.

## Current project status

See the bottom of this README — **PROJECT STATUS** section — kept in sync with the Matrix.
This bootstrap run established: project control system, Master Matrix, validators, CI,
Godot project, and a first playable vertical slice (drive a motorbike, keyboard/controller/
touch input, speed HUD, Web export, GitHub Pages). The vast majority of Matrix rows remain
PLANNED — by design.

---

## PROJECT STATUS (live)

- Milestone: M0 in progress
- Matrix: see `docs/matrix/game-master-matrix.csv`
- Live build: <https://thuexemayhanoi.github.io/game/>
