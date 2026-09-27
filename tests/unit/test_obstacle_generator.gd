extends GutTest
## Unit tests for the deterministic obstacle generator (GAME-0256 / TEST-0016).
## Verifies seed determinism and that every generated route is passable.

const FIELD_TOP := 70.0
const FIELD_BOTTOM := 880.0

func _gen(seed_value := 12345) -> ObstacleGenerator:
	return ObstacleGenerator.new(seed_value, FIELD_TOP, FIELD_BOTTOM)

func test_same_seed_same_sequence() -> void:
	var a := _gen()
	var b := _gen()
	var params := {"gap": 300.0, "scroll_speed": 200.0, "spacing": 380.0}
	for i in range(20):
		var pa: Dictionary = a.generate(params)
		var pb: Dictionary = b.generate(params)
		assert_almost_eq(pa["gap_center"], pb["gap_center"], 0.001, "seeded runs must match")

func test_every_placement_is_passable() -> void:
	var gen := _gen()
	var diff := DifficultyManager.new()
	for score in [0, 10, 25, 50, 100, 200, 100000]:
		var params := diff.get_params(score)
		for i in range(50):
			var p: Dictionary = gen.generate(params)
			assert_true(ObstacleGenerator.is_passable(p, FIELD_TOP, FIELD_BOTTOM),
				"gap must fit inside the play field")
			assert_gt(p["gap_size"], 90.0, "gap must always be wide enough for the bike")

func test_gap_never_hugs_edges() -> void:
	var gen := _gen()
	var params := {"gap": 320.0}
	for i in range(50):
		var p: Dictionary = gen.generate(params)
		assert_gt(p["gap_center"] - p["gap_size"] * 0.5, FIELD_TOP - 1.0)
		assert_lt(p["gap_center"] + p["gap_size"] * 0.5, FIELD_BOTTOM + 1.0)

func test_impossible_gap_request_is_shrunk_not_broken() -> void:
	# A gap larger than the field must be shrunk, never produce an impossible obstacle.
	var gen := _gen()
	var p: Dictionary = gen.generate({"gap": 5000.0})
	assert_true(ObstacleGenerator.is_passable(p, FIELD_TOP, FIELD_BOTTOM),
		"oversized gap must be shrunk to a possible one")

func test_reseed_changes_sequence() -> void:
	var a := _gen(1)
	var b := _gen(2)
	var params := {"gap": 300.0}
	var same := true
	for i in range(10):
		if absf(a.generate(params)["gap_center"] - b.generate(params)["gap_center"]) > 0.001:
			same = false
	assert_false(same, "different seeds must produce different levels")
