# TESTING — MOTO HOP

## Stack

- **Python validators** (scripts/): project schema, Matrix schema, assets, save schema, build budget.
- **GUT 9.7.1** for Godot 4.7.x — unit/integration tests in tests/unit, tests/integration, tests/smoke;
  fixtures in tests/fixtures.
- **Headless boot smoke test** — godot --headless import + main scene boot.
- **Playwright browser smoke** — 6 viewports (320x568, 390x844, 430x932, 844x390, 768x1024,
  1920x1080) against the exported Web build: canvas visible, no horizontal scroll, tap works,
  no fatal console errors.

## Rules

- Map tests in docs/matrix/test-matrix.csv (test_id, feature_id, type, test_file, platform,
  required_for_done, status, last_result).
- Test categories: STATIC, UNIT, INTEGRATION, SMOKE, EXPORT, BROWSER, PERFORMANCE,
  SAVE_MIGRATION, E2E.
- Do not fake passing tests. A required test may never be silently skipped.
- Tests drive actual behavior: hop physics, gravity, scoring exactly-once, collisions,
  restart, best score, difficulty bounds, passable-gap guarantees, state transitions,
  save migrations.

## Minimum coverage

Project boot, settings, save schema + v1→v2 migration, matrix parsing, input actions,
hop physics, score manager, difficulty bounds, obstacle generator, full game flow
(boot → menu → ready → play → crash → restart), web export boot, browser smoke.
