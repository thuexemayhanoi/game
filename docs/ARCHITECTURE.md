# ARCHITECTURE — MOTO HOP

## Engine baseline

- Godot 4.7.2 stable, GDScript, Compatibility renderer (gl_compatibility), single-threaded Web export.
- Do not change engine or language without documenting the migration reason in docs/.

## Design principles

1. Pure logic cores (RefCounted, no scene dependencies) are unit-testable headless.
2. Presentation nodes are thin wrappers over those cores.
3. Data-driven content (JSON under src/data) — no magic numbers scattered in code.
4. Pooled objects — no per-frame allocation during gameplay.
5. Original procedural art and audio — no external asset dependencies.

## Module layout (`src/`)

| Module | Responsibility |
|--------|----------------|
| core | autoloads (EventBus, GameState), game controller (moto_hop.gd), HopSim physics, ObstacleGenerator, DifficultyManager, ScoreManager, SaveManager |
| player | PlayerBike — playable cartoon bike wrapping HopSim; circle collision; juice (wheel spin, squash) |
| world | Obstacle + ObstacleManager (pooled, themed pairs), CityParallax background layers |
| ui | MotoHud (score, best, pause/mute), MotoMenu (menu, ready countdown, game over, pause panel) |
| audio | AudioManager autoload — original runtime-generated PCM tones, mute persistence |
| platform | InputManager autoload — runtime-registered actions (hop, pause, toggle_mute) |
| data | difficulty.json, save_schema.json |
| traffic, npc, police, missions, economy, progression, vehicles | reserved for future MH2+ rows; open-world runtime was removed in the MOTO HOP pivot (GAME-0251) |

## Game states

GameState (autoload) owns the strict state machine:
BOOT → MENU → READY → PLAYING → PAUSED → GAME_OVER with validated transitions
(illegal transitions are rejected and unit-tested). The controller (moto_hop.gd)
wires states to presentation; no system reads input or SceneTree state directly
inside the pure cores.

## Signals

All cross-system communication goes through the EventBus autoload signals
(state_changed, score_changed, best_changed, milestone_reached, crashed,
hop_performed, mute_changed, button_clicked). No hard cross-references beyond
autoloads.

## Hard rules

- No monolithic scripts: gameplay logic is separable and testable (HopSim,
  ObstacleGenerator, DifficultyManager, ScoreManager are pure RefCounted classes).
- Save logic does not depend on UI (SaveManager/GameState are headless-testable).
- Persistent data is versioned (`save_version`) with migrations; never silently
  destroy older saves (v1 open-world saves migrate to v2 preserving their data).
- Obstacles, audio players and UI are pooled/reused; gameplay allocates nothing.
- All difficulty and tuning constants live in src/data/difficulty.json with
  hard safety clamps in DifficultyManager.

## Scenes

Minimal scenes; logic in scripts under src/. The single main scene is
`src/core/moto_hop.tscn` + `src/core/moto_hop.gd`; all children are built in code
from pooled nodes. Tests live in tests/ (GUT) with fixtures in tests/fixtures/.
