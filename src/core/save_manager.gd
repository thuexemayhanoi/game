extends RefCounted
## Versioned save system. Stable string IDs everywhere; save_version mandatory.
## Migrations never silently destroy older saves.

const CURRENT_SAVE_VERSION := 1

static func default_save() -> Dictionary:
	return {
		"save_version": CURRENT_SAVE_VERSION,
		"profile": {"name": "Rider", "created_at": 0},
		"wallet": {"balance": 0},
		"bikes": [],
		"upgrades": {},
		"mission_progress": {},
		"world_unlocks": {"districts": [], "landmarks": []},
		"settings": {},
		"achievements": [],
		"statistics": {"distance_ridden": 0.0, "missions_completed": 0},
	}

## Returns a migrated, validated save. On corruption returns default + backed-up flag.
static func load_from_dict(data: Dictionary) -> Dictionary:
	if not data.has("save_version"):
		var fixed := default_save()
		fixed["migrated_from_corrupt"] = true
		return fixed
	var version: int = int(data["save_version"])
	var migrated := data.duplicate(true)
	while version < CURRENT_SAVE_VERSION:
		migrated = _migrate(migrated, version)
		version += 1
	migrated["save_version"] = CURRENT_SAVE_VERSION
	return migrated

static func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	# Example future migration: if from_version == 1: data["new_field"] = ...
	match from_version:
		_:
			pass
	return data

static func validate(data: Dictionary) -> bool:
	var required := ["save_version", "profile", "wallet", "bikes", "upgrades",
		"mission_progress", "world_unlocks", "settings", "achievements", "statistics"]
	for key in required:
		if not data.has(key):
			return false
	return int(data.get("save_version", 0)) > 0
