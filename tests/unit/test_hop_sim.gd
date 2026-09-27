extends GutTest
## Unit tests for the deterministic HopSim physics core (GAME-0253 / TEST-0013).

func _sim() -> HopSim:
	return HopSim.new()

func test_hop_sets_upward_velocity() -> void:
	var s := _sim()
	s.hop()
	assert_lt(s.velocity.y, 0.0, "hop must launch the bike upward")

func test_gravity_pulls_down() -> void:
	var s := _sim()
	s.hop()
	var before: float = s.velocity.y
	s.advance(0.1)
	assert_gt(s.velocity.y, before, "gravity must increase downward velocity")

func test_position_integrates_velocity() -> void:
	var s := _sim()
	s.hop()
	s.advance(0.0)
	assert_eq(s.position.y, 0.0, "delta <= 0 must be ignored (test safety)")
	s.advance(0.5)
	assert_gt(s.position.y, 0.0, "bike must fall below the start after time passes")

func test_fall_speed_is_capped() -> void:
	var s := _sim()
	for i in range(600):
		s.advance(0.016)
	assert_lte(s.velocity.y, s.max_fall_speed + 0.01, "terminal fall speed must be respected")

func test_rotation_tilts_up_on_hop_and_down_while_falling() -> void:
	var s := _sim()
	s.hop()
	for i in range(10):
		s.advance(0.016)
	assert_lt(s.rotation, 0.0, "boosting bike must tilt up (negative rotation)")
	for i in range(240):
		s.advance(0.016)
	assert_gt(s.rotation, 0.0, "falling bike must tilt down (positive rotation)")
	assert_lte(s.rotation, 0.6, "rotation must stay gentle (child friendly)")

func test_forward_speed_moves_x() -> void:
	var s := _sim()
	s.advance(0.5, 200.0)
	assert_almost_eq(s.position.x, 100.0, 0.01)
	assert_gt(s.distance_traveled, 0.0)

func test_reset_restores_start() -> void:
	var s := _sim()
	s.hop()
	s.advance(0.3, 100.0)
	s.reset(Vector2(7.0, 9.0))
	assert_eq(s.position, Vector2(7.0, 9.0))
	assert_eq(s.velocity, Vector2.ZERO)
	assert_eq(s.rotation, 0.0)

func test_invalid_config_falls_back_to_defaults() -> void:
	var s := HopSim.new(NAN, NAN, NAN)
	assert_eq(s.gravity, HopSim.DEFAULT_GRAVITY)
	assert_eq(s.hop_impulse, HopSim.DEFAULT_HOP_IMPULSE)
	assert_eq(s.max_fall_speed, HopSim.DEFAULT_MAX_FALL)
