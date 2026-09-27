# MOTO HOP

Original one-button arcade game for children: a cute cartoon motorbike hops through a
bright, Hanoi-inspired city. Built with **Godot 4.7.2 stable** (Compatibility renderer)
in **GDScript**. Primary deployment: **GitHub Pages** — <https://thuexemayhanoi.github.io/game/>

> TAP → MOTORBIKE HOPS → PASS OBSTACLE → SCORE → CRASH → PLAY AGAIN.

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
- **Working title:** MOTO HOP (subtitle: City Adventure)
- **Engine:** Godot 4.7.2 stable, GDScript, Compatibility (gl_compatibility) renderer
- **Web baseline:** single-threaded Web export, portrait, mobile-first (works at 320px width)
- **IP rule:** 100% original content. The one-button endless-obstacle genre is generic;
  all artwork, obstacle designs, audio, names and UI are original. Nothing is copied from
  Flappy Bird or any commercial game. See `docs/ASSET-POLICY.md`.

## Direction change (honest history)

This repository was previously **HANOI RIDER: OPEN CITY**, an open-world motorbike
concept that reached a verified bootstrap (M0) plus one driving vertical slice
(GAME-0019, first green CI on 3995992, deployed 2026-09-26). On 2026-09-27 the product
direction changed to **MOTO HOP** (see GAME-0251 in the Master Matrix). The open-world
runtime (BikeSim/Motorbike/TestWorld) was cleanly removed and replaced by the arcade
runtime; the project control system, validators, CI chain and all M0 infrastructure
were preserved. The old open-world backlog rows remain in the Matrix for history,
marked as deferred/superseded in their notes — they do not describe the current product.

## Vision

A cheerful, polished, lightweight arcade game a child understands immediately:
one button, immediate feedback, forgiving difficulty that slowly tightens,
original Hanoi-flavored obstacles (construction barriers, stacked delivery boxes,
street gates) — never green pipes. No ads, no tracking, no login, no backend.

## Platform goals

| Tier | Platforms |
|------|-----------|
| Primary now | Mobile browsers (touch), desktop browsers (Space/click/Up), tablets |
| Future | Android, iOS, Windows, Linux, macOS native builds |

See `docs/PLATFORMS.md`. Do NOT claim "mobile supported" until tested on real devices.

## Architecture (summary)

Pure, testable cores under `src/core` (HopSim physics, ObstacleGenerator,
DifficultyManager, ScoreManager, SaveManager) with thin presentation nodes:
`src/player/player_bike.gd`, `src/world/obstacle*.gd`, `src/world/parallax_background.gd`,
`src/ui/hud.gd`, `src/ui/menu.gd`, `src/audio/audio_manager.gd`, and the
`src/core/moto_hop.gd` game controller. Full detail: `docs/ARCHITECTURE.md`.

## Master Matrix (authoritative backlog)

`docs/matrix/game-master-matrix.csv` is the single source of truth for all features.

- IDs: GAME-0001 … (unique, never reused). MOTO HOP features start at GAME-0251 (milestones MH1/MH2).
- Statuses: PLANNED, READY, IN_PROGRESS, IMPLEMENTED, QA_FAILED, BLOCKED, VERIFIED, DONE
- `docs/matrix/test-matrix.csv` maps features to automated tests
- `docs/matrix/release-matrix.csv` tracks releases

## Workflow & state machine

Every feature follows: SELECT → LOCK → IMPLEMENT → TEST → QA → REPAIR → FULL VALIDATION →
UPDATE MATRIX → COMMIT → CHECKPOINT → VERIFY → DONE.

- Lock state lives in `docs/state/active-work.json`.
- Max 3 automatic repair attempts for the same root failure; then QA_FAILED or BLOCKED
  with recorded evidence. Never hide failure.
- Full rules: `docs/WORKFLOW.md`, `docs/AI-AGENT-RULES.md`.

## Testing strategy

- Python validators (project, matrix, assets, save schema, build budget) — run in CI
- GUT 9.7.1 unit/integration tests for the pure logic cores and game flow
- Headless Godot boot smoke test
- Playwright browser smoke tests over the Web build (6 viewports incl. 320x568)
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

## Copyright & assets

All content original. All art is procedural (drawn in code); all audio is generated
at runtime as original PCM tones. Track every third-party asset in `docs/ASSET-POLICY.md`.
No unlicensed commercial-game assets, ever.

## Current project status

See the bottom of this README — **PROJECT STATUS** section — kept in sync with the Matrix.

---

## PROJECT STATUS (live)

- Milestone: MH1 — MOTO HOP core game (see docs/state/milestone-status.md)
- Matrix: see `docs/matrix/game-master-matrix.csv` (MOTO HOP rows GAME-0251+)
- Live build: <https://thuexemayhanoi.github.io/game/>
