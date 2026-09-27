class_name SaveManager
extends RefCounted
## Versioned save system (MOTO HOP). Version 2; migrations never destroy data.
## Storage degrades gracefully: when user:// storage is unavailable (some web
## contexts / private mode), the game keeps working with in-memory defaults.

const CURRENT_SAVE_VERSION := 2
const SAVE_PATH := "user://moto_hop_save.json"

const REQUIRED_KEYS := ["save_version", "profile", "wallet", "arcade", "settings",
	"achievements", "statistics"]

static func default_save() -> Dictionary:
	return {
		"save_version": CURRENT_SAVE_VERSION,
		"profile": {"name": "Player", "created_at": 0},
		"wallet": {"coins": 0},
		"arcade": {"best_score": 0},
		"settings": {"muted": false},
		"achievements": [],
		"statistics": {"games_played": 0, "total_score": 0, "obstacles_passed": 0},
	}

## Returns a migrated, validated save. Unknown/corrupt input returns defaults.
static func load_from_dict(data: Dictionary) -> Dictionary:
	if typeof(data) != TYPE_DICTIONARY or not data.has("save_version"):
		return default_save()
	var version := int(data["save_version"])
	if version <= 0 or version > CURRENT_SAVE_VERSION:
		return default_save()
	var migrated: Dictionary = data.duplicate(true)
	while version < CURRENT_SAVE_VERSION:
		migrated = _migrate(migrated, version)
		version += 1
	migrated["save_version"] = CURRENT_SAVE_VERSION
	if not validate(migrated):
		return default_save()
	return migrated

static func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	match from_version:
		1:
			# v1 (open-world prototype) -> v2 (MOTO HOP arcade).
			# Preserve old data; add new sections with safe defaults.
			if not data.has("arcade"):
				data["arcade"] = {"best_score": 0}
			if not data.has("settings"):
				data["settings"] = {"muted": false}
			if not data.has("wallet"):
				data["wallet"] = {"coins": 0}
			if not data.has("profile"):
				data["profile"] = {"name": "Player", "created_at": 0}
			if not data.has("achievements"):
				data["achievements"] = []
			if not data.has("statistics"):
				data["statistics"] = {"games_played": 0, "total_score": 0, "obstacles_passed": 0}
		_:
			pass
	return data

static func validate(data: Dictionary) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	for key in REQUIRED_KEYS:
		if not data.has(key):
			return false
	return int(data.get("save_version", 0)) == CURRENT_SAVE_VERSION

## Persists to user:// storage. Returns false when storage is unavailable;
## the caller must treat that as non-fatal.
static func save_to_disk(data: Dictionary) -> bool:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data))
	f.close()
	return true

## Loads from user:// storage; returns a valid save (defaults on any failure).
static func load_from_disk() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_save()
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return default_save()
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return default_save()
	return load_from_dict(parsed)
