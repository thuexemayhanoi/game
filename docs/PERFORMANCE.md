# PERFORMANCE — HANOI RIDER

Must run from phones to desktops. Degrade gracefully; never crash on weak hardware.

## Strategy

- Bounded simulation radius; entity pooling for traffic/NPCs.
- Chunk streaming + unload; LOD; distance culling.
- Quality profiles: LOW / MEDIUM / HIGH (ULTRA later), controlling render distance,
  traffic/NPC density, shadows, particles, effects, texture/reflection quality, sim radius.
- Budgets tracked by scripts/check_build_budget.py (baseline first, enforcement later):
  web build size, large files, texture size, audio size.

## Web specifics

Single-threaded export, compatibility renderer, no threads in baseline gameplay code paths,
loading screen, lifecycle pause/resume, adaptive traffic/NPC density.

## CI

Browser smoke tests assert load + boot, not visual gameplay, until suitable test hooks exist.
