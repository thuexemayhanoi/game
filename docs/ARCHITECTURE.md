# ARCHITECTURE — HANOI RIDER

## Engine baseline

- Godot 4.7.2 stable, GDScript, Compatibility renderer (gl_compatibility), single-threaded Web export.
- Do not change engine or language without documenting the migration reason in docs/.

## Module layout (`src/`)

| Module | Responsibility |
|--------|----------------|
| core | autoloads, game state, event bus, session lifecycle |
| player | on-foot state machine, mounting, camera, checkpoints, respawn |
| vehicles | bike simulation (VehicleBody3D), bike categories, damage, fuel/battery, tuning |
| world | districts, chunks, streaming, LOD, day/night, weather, world events |
| traffic | lane graphs, traffic agents (cars/buses/taxis), lights, density profiles |
| npc | pedestrian archetypes, pooling, schedules, interactions |
| police | wanted model, pursuit director, chase AI, roadblocks, cooldown |
| missions | reusable objective framework + mission director (data-driven) |
| economy | wallet, prices, shops, rentals, rewards, anti-double-reward |
| progression | reputation, unlocks, chapters, achievements, statistics |
| ui | HUD, map, phone/menu, garage, shop, settings, accessibility |
| audio | buses, engine loops, ambience, original music |
| platform | input adapters (keyboard/gamepad/touch), quality profiles, lifecycle |
| data | Resources/JSON for bikes, missions, districts, traffic, weather, rewards |

## Hard rules

- No monolithic scripts. Core systems must be separable and testable.
- Mission logic must not require rendering (headless-testable).
- Save logic must not depend on UI.
- Vehicle simulation must be testable outside the full open world.
- No single giant world scene: districts → chunks → streaming → bounded simulation radius.
- Content is data-driven (Resources / JSON in src/data). Never hard-code hundreds of
  content variants into scripts.
- All persistent data uses stable string IDs. Save schema is versioned (`save_version`)
  with migrations; never silently destroy older saves. See docs/SAVE-SYSTEM.md.

## Scenes

Minimal scenes; logic in scripts under src/. Scenes live beside their module
(e.g. src/world/TestWorld.tscn). Tests live in tests/ (GUT) with fixtures in tests/fixtures/.
