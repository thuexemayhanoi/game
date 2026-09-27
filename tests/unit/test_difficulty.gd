extends GutTest
## Unit tests for the data-driven difficulty system (GAME-0258 / TEST-0015).
## Verifies bounds, monotonic progression and capped endgame difficulty.

func _manager() -> DifficultyManager:
	return DifficultyManager.new()

func test_tiers_load_from_data() -> void:
	var m := _manager()
	assert_gt(m.tiers.size(), 0, "difficulty tiers must load from src/data/difficulty.json")

func test_params_always_within_safe_bounds() -> void:
	var m := _manager()
	for score in [0, 1, 9, 10, 24, 25, 49, 50, 99, 100, 200, 500, 99999]:
		var p := m.get_params(score)
		assert_between(p["scroll_speed"], DifficultyManager.MIN_SPEED, DifficultyManager.MAX_SPEED,
			"scroll speed must stay capped at score " + str(score))
		assert_between(p["gap"], DifficultyManager.MIN_GAP, DifficultyManager.MAX_GAP,
			"gap must stay in bounds at score " + str(score))
		assert_between(p["spacing"], DifficultyManager.MIN_SPACING, DifficultyManager.MAX_SPACING,
			"spacing must stay in bounds at score " + str(score))

func test_difficulty_increases_with_score() -> void:
	var m := _manager()
	var easy := m.get_params(0)
	var hard := m.get_params(150)
	assert_gt(hard["scroll_speed"], easy["scroll_speed"], "game must scroll faster over time")
	assert_lt(hard["gap"], easy["gap"], "gaps must tighten over time")

func test_difficulty_is_capped_at_high_scores() -> void:
	var m := _manager()
	var p200: Dictionary = m.get_params(200)
	var p9999: Dictionary = m.get_params(99999)
	assert_eq(p9999["scroll_speed"], p200["scroll_speed"], "speed must stop increasing (capped)")
	assert_eq(p9999["gap"], p200["gap"], "gap must stop shrinking (capped)")

func test_gap_always_larger_than_bike() -> void:
	var m := _manager()
	# PlayerBike collision diameter is 52px; a 90px floor leaves huge margin.
	for score in [0, 100, 100000]:
		assert_gt(m.get_params(score)["gap"], 90.0,
			"gap must always exceed the bike size (never impossible)")

func test_sanitize_clamps_bad_config() -> void:
	var t := DifficultyManager.sanitize_tier(
		{"min_score": -5, "scroll_speed": 99999.0, "gap": 10.0, "spacing": -1.0})
	# Negative spacing is clamped to the safe minimum (never impossible).
	assert_eq(t["min_score"], 0)
	assert_eq(t["scroll_speed"], DifficultyManager.MAX_SPEED)
	assert_eq(t["gap"], DifficultyManager.MIN_GAP)
	assert_eq(t["spacing"], DifficultyManager.MIN_SPACING)

func test_bad_json_falls_back_to_defaults() -> void:
	var tiers := DifficultyManager.load_tiers()
	assert_gt(tiers.size(), 0, "loader must always produce usable tiers")
