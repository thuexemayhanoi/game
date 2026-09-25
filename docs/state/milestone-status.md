# Milestone Status

## M0 — Repository Foundation (DONE)

Completed on 2026-09-26 when the full bootstrap gate chain passed:

| Gate | Result |
|------|--------|
| Python validators (project, matrix, assets, save schema, build budget) | PASS |
| Godot 4.7.2 import (0 script errors) | PASS |
| Headless boot smoke | PASS |
| GUT 9.7.1 test suite | PASS — 40/40 |
| Web export (single-threaded, compatibility renderer) | PASS |
| Browser smoke (Playwright, 5 viewports) | PASS — 5/5 |
| GitHub Pages deployment from verified main build | PASS |
| Live site https://thuexemayhanoi.github.io/game/ | LOADS (canvas + wasm + pck verified) |

First fully green CI: commit 3995992. All M0 P0 rows are VERIFIED (see
docs/matrix/game-master-matrix.csv).

### Bootstrap history (honest record)

- Early runs created the docs/control system and validators (aaa0f42, d8a240e).
- A concurrent scheduled run (ae2f794, 284efc7) landed a second, more complete
  Godot project. Its architecture (EventBus/GameState/InputManager autoloads,
  Motorbike + BikeSim) was kept as authoritative; duplicate files from the
  earlier bootstrap were removed in 87e9380 and follow-up deletions.
- CI was repaired across three fixes (GUT install path, export template
  extraction, Playwright webServer path ../../build/web). Failure evidence was
  captured in GitHub issues #1-#3 rather than guessed at.

### Known caveats (not blockers)

- Gameplay interaction (keyboard/gamepad/touch) is covered by GUT tests and a
  headless browser smoke, but NOT yet validated on real devices. These stay
  IMPLEMENTED, not VERIFIED, in the Matrix (GAME-0020..GAME-0198 slice rows).
- The legacy "pages build and deployment" (Jekyll from branch) still runs on
  pushes and briefly serves the README rendering until the verified Actions
  deploy overwrites it. Fix by setting the Pages source to "GitHub Actions"
  in repo settings (requires admin UI/API access unavailable to this run).

## Milestone gates

M0 is DONE when: all validators PASS, Godot import PASS, headless boot PASS,
GUT PASS, Web export PASS, browser smoke PASS, Pages deploy PASS, live site
LOADS. — All satisfied 2026-09-26.

M1 (Player & Motorbike Core) is next: pick READY P0 rows from the Matrix.
Later milestones: see docs/matrix/game-master-matrix.csv.
