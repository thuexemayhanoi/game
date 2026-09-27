extends GutTest
## Unit tests for ScoreManager (GAME-0259 / TEST-0014).

func test_pass_scores_exactly_once() -> void:
	var m := ScoreManager.new()
	m.register_pass(1)
	m.register_pass(1)
	m.register_pass(1)
	assert_eq(m.score, 1, "one obstacle pair must give exactly one point")
	assert_eq(m.passed_count(), 1)
	assert_true(m.has_passed(1))
	assert_false(m.has_passed(2))

func test_multiple_obstacles_score_separately() -> void:
	var m := ScoreManager.new()
	m.register_pass(1)
	m.register_pass(2)
	m.register_pass(3)
	assert_eq(m.score, 3)

func test_milestones_fire_once() -> void:
	var m := ScoreManager.new()
	var hit := {}
	for i in range(1, 101):
		var milestone := m.register_pass(i)
		if milestone > 0:
			hit[milestone] = i
	assert_eq(m.score, 100)
	assert_has(hit, 10)
	assert_has(hit, 25)
	assert_has(hit, 50)
	assert_has(hit, 100)
	assert_eq(hit.size(), 4, "milestones must fire exactly at 10/25/50/100")

func test_milestone_for_returns_zero_otherwise() -> void:
	var m := ScoreManager.new()
	assert_eq(m.milestone_for(9), 0)
	assert_eq(m.milestone_for(11), 0)
	assert_eq(m.milestone_for(10), 10)

func test_reset_clears_everything() -> void:
	var m := ScoreManager.new()
	m.register_pass(1)
	m.reset()
	assert_eq(m.score, 0)
	assert_false(m.has_passed(1))
