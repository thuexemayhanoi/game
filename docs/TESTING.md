# TESTING — HANOI RIDER

## Stack

- **Python validators** (scripts/): project schema, Matrix schema, assets, save schema, build budget.
- **GUT 9.7.1** for Godot 4.7.x — unit/integration tests in tests/unit, tests/integration, tests/smoke;
  fixtures in tests/fixtures.
- **Headless boot smoke test** — godot --headless import + main scene boot.
- **Playwright browser smoke** — 5 viewports (1920x1080, 1366x768, 390x844, 412x915, 844x390)
  against the exported Web build.

## Rules

- Map tests in docs/matrix/test-matrix.csv (test_id, feature_id, type, test_file, platform,
  required_for_done, status, last_result).
- Test categories: STATIC, UNIT, INTEGRATION, SMOKE, EXPORT, BROWSER, PERFORMANCE,
  SAVE_MIGRATION, E2E.
- Do not fake passing tests. A required test may never be silently skipped after the testing
  framework is installed.
- Minimum coverage now: project boot, settings, save schema, matrix parsing, input actions,
  first bike data, basic vehicle acceleration/braking.

## Gates

- Validators PASS, Godot import PASS, boot smoke PASS, GUT PASS, Web export PASS,
  browser smoke PASS, Pages deployment PASS, live site LOADS — before claiming bootstrap done.
