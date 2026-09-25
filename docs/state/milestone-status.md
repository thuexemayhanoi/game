# Milestone Status

## M0 — Repository Foundation (IN PROGRESS — recovery)

| Area | Status |
|------|--------|
| Repository control system (docs, matrix, state, validators) | VERIFIED |
| Master Matrix backlog | IMPLEMENTED (extended to 250 rows in the recovery commit; validator expected to PASS) |
| Godot project + vertical slice (bike, controls, HUD, world) | IMPLEMENTED in commit ae2f794 — pending CI verification |
| CI workflow (validation, import, boot, GUT, web export, browser smoke) | IMPLEMENTED in commit ae2f794 — first run pending |
| GitHub Pages deployment workflow | IMPLEMENTED in commit ae2f794 — requires Pages source set to "GitHub Actions" |

### Recovery note (2026-09-26)

A previous run recorded 28 features as IMPLEMENTED in the Matrix, but no Godot
project, CI, tests or game code existed in the repository — only docs and
validators. This recovery run committed the real implementation instead of
resetting statuses. Evidence fields now record the implementing commit.
Features stay IMPLEMENTED (not VERIFIED) until CI and the live site are green.

## Milestone gates

M0 is DONE when: all validators PASS, Godot import PASS, headless boot PASS,
GUT PASS, Web export PASS, browser smoke PASS, Pages deploy PASS, live site
LOADS.

Later milestones: see docs/matrix/game-master-matrix.csv.
