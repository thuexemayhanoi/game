extends GutTest
## Unit tests for the save schema and GameState round-trip (TEST-0010/0011).

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

func test_save_version_is_int() -> void:
	assert_eq(typeof(_schema().get("save_version")), TYPE_INT)

func test_required_keys_present() -> void:
	var s := _schema()
	for k in ["profile", "wallet", "bikes", "upgrades", "mission_progress", "world_unlocks", "settings", "achievements", "statistics", "migrations"]:
		assert_true(s.has(k), "schema missing key: " + k)
	assert_eq(typeof(s.get("migrations")), TYPE_ARRAY)

func test_game_state_round_trip() -> void:
	GameState.money = 150
	GameState.reputation = 7
	GameState.current_bike = "scooter_default"
	var d := GameState.to_dict()
	GameState.money = 0
	GameState.reputation = 0
	GameState.from_dict(d)
	assert_eq(GameState.money, 150)
	assert_eq(GameState.reputation, 7)
	assert_eq(GameState.current_bike, "scooter_default")

func test_game_state_rejects_invalid_data() -> void:
	GameState.money = 100
	GameState.from_dict({"money": "garbage", "current_bike": 42})
	assert_eq(GameState.money, 100, "invalid values must not corrupt state")
	assert_eq(GameState.current_bike, "scooter_default")
