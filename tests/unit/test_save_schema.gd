extends GutTest
## Unit tests for the save schema, SaveManager migrations and GameState
## round-trip (TEST-0010/0011).

const SCHEMA := "res://src/data/save_schema.json"

func _schema() -> Dictionary:
	var f := FileAccess.open(SCHEMA, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func test_schema_parses() -> void:
	assert_gt(_schema().size(), 0, "save schema must parse as JSON")

func test_save_version_is_2() -> void:
	var v = _schema().get("save_version", 0)
	assert_true(typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT,
		"save_version must be numeric, got: " + str(typeof(v)))
	assert_eq(int(v), 2, "schema must document version 2 (MOTO HOP)")

func test_required_keys_present() -> void:
	var s := _schema()
	for k in ["profile", "wallet", "arcade", "settings", "achievements", "statistics", "migrations"]:
		assert_true(s.has(k), "schema missing key: " + k)
	assert_eq(typeof(s.get("migrations")), TYPE_ARRAY)

func test_default_save_is_valid_v2() -> void:
	var d := SaveManager.default_save()
	assert_eq(d["save_version"], 2)
	assert_true(SaveManager.validate(d))

func test_v1_save_migrates_to_v2_without_data_loss() -> void:
	var v1 := {
		"save_version": 1,
		"profile": {"name": "Rider", "created_at": 5},
		"wallet": {"balance": 42},
		"bikes": ["scooter_default"],
		"mission_progress": {"completed": ["m1"]},
		"settings": {},
		"achievements": [],
		"statistics": {"distance_ridden": 3.5},
	}
	var migrated := SaveManager.load_from_dict(v1)
	assert_eq(migrated["save_version"], 2, "migration must reach version 2")
	assert_eq(migrated["arcade"]["best_score"], 0, "arcade section added with default")
	assert_eq(migrated["profile"]["name"], "Rider", "old data must be preserved")
	assert_eq(migrated["wallet"]["balance"], 42, "old wallet must survive migration")

func test_corrupt_save_returns_defaults() -> void:
	assert_eq(SaveManager.load_from_dict({}).get("save_version"), 2)
	assert_eq(SaveManager.load_from_dict({"save_version": "junk"}).get("save_version"), 2)
	assert_eq(SaveManager.load_from_dict({"save_version": 99}).get("save_version"), 2)

func test_game_state_round_trip() -> void:
	GameState.best_score = 77
	GameState.coins = 12
	GameState.muted = true
	var d := GameState.to_dict()
	GameState.best_score = 0
	GameState.coins = 0
	GameState.muted = false
	GameState.from_dict(d)
	assert_eq(GameState.best_score, 77)
	assert_eq(GameState.coins, 12)
	assert_true(GameState.muted)

func test_game_state_rejects_invalid_data() -> void:
	GameState.best_score = 50
	GameState.from_dict({"best_score": "garbage", "coins": -9, "muted": "nope"})
	assert_eq(GameState.best_score, 50, "invalid values must not corrupt state")
	assert_eq(GameState.coins, 0, "negative values must be rejected")
