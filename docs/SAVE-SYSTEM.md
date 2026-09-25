# SAVE SYSTEM

- Versioned schema: every save contains `save_version`.
- Stable string IDs for all persistent entities (bikes, missions, districts, achievements).
- Contents: profile, wallet, bikes, upgrades, mission progress, world unlocks, settings,
  achievements, statistics.
- Schema changes require migration code + SAVE_MIGRATION tests. Never silently destroy
  older saves.
- Corrupted-save fallback: detect, back up, start fresh with a clear message.
- Anti-double-reward protection: mission completions are idempotent per save.
- Web: save via JavaScript localStorage bridge (user:// on web maps to IndexedDB).
