# SAVE SYSTEM

- Versioned schema: every save contains `save_version` (currently 2).
- Version 2 (MOTO HOP): profile, wallet (coins), arcade (best_score), settings
  (muted), achievements, statistics (games_played, total_score, obstacles_passed).
- Schema definition: src/data/save_schema.json; validator: scripts/validate_save_schema.py.
- v1 → v2 migration preserves old open-world data untouched and adds the arcade
  sections with safe defaults (SaveManager._migrate, unit-tested).
- Corrupt or unknown-version saves fall back to defaults; the game never crashes on
  bad saves and stays fully playable when storage is unavailable (web private mode).
- Best score and mute preference persist; mute is also written immediately on toggle.
- Web: user:// storage (IndexedDB); the game degrades gracefully without it.
- No personal data is collected or stored.
