extends GutTest
## Unit tests for data-driven bike stats (GAME-0044 / TEST-0013).

func test_default_bike_loads_from_data() -> void:
	var b := BikeData.load_default()
	assert_not_null(b)
	assert_gt(b.max_speed, 0.0)
	assert_gt(b.acceleration, 0.0)
	assert_gt(b.brake_force, 0.0)
	assert_gt(b.turn_rate, 0.0)

func test_load_by_id() -> void:
	var b := BikeData.load_by_id("scooter_default")
	assert_not_null(b)
	assert_eq(b.id, "scooter_default")

func test_unknown_id_returns_null() -> void:
	assert_null(BikeData.load_by_id("does_not_exist"))

func test_invalid_entries_fall_back_to_defaults() -> void:
	var b := BikeData.from_dict({"id": "x", "max_speed": -5.0, "acceleration": "bad"})
	assert_gt(b.max_speed, 0.0, "invalid values must fall back to safe defaults")
	assert_gt(b.acceleration, 0.0)

func test_all_bikes_have_unique_ids() -> void:
	var all := BikeData.load_all()
	assert_gt(all.size(), 0)
	var ids := {}
	for b in all:
		assert_false(ids.has(b.id), "duplicate bike id: " + b.id)
		ids[b.id] = true
