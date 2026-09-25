extends GutTest
## Unit tests for the deterministic BikeSim arcade simulation core.

func test_throttle_increases_forward_speed() -> void:
	var sim := BikeSim.new()
	sim.apply_input(1.0, 0.0, 0.0, 0.1)
	assert_gt(sim.speed, 0.0, "throttle must increase forward speed")

func test_brake_reduces_speed() -> void:
	var sim := BikeSim.new()
	sim.apply_input(1.0, 0.0, 0.0, 5.0)
	var before: float = sim.speed
	sim.apply_input(0.0, 1.0, 0.0, 0.5)
	assert_lt(sim.speed, before, "braking must reduce speed")

func test_maximum_configured_speed_is_respected() -> void:
	var sim := BikeSim.new(30.0, 8.0, 14.0, 2.2)
	for i in range(600):
		sim.apply_input(1.0, 0.0, 0.0, 0.1)
	assert_true(sim.speed <= 30.0, "speed must never exceed max configured speed")
	assert_true(sim.speed >= 0.0)

func test_invalid_input_cannot_create_nan() -> void:
	var sim := BikeSim.new()
	sim.apply_input(NAN, NAN, NAN, -1.0)
	assert_true(is_finite(sim.speed), "NaN inputs must be sanitized")
	sim.apply_input(INF, 0.0, 0.0, 0.1)
	assert_true(is_finite(sim.speed), "INF inputs must be sanitized")
	sim.apply_input(1.0, 1.0, 1.0, 0.1)
	assert_true(is_finite(sim.speed))
	assert_true(is_finite(sim.heading))

func test_reverse_is_clamped() -> void:
	var sim := BikeSim.new()
	for i in range(200):
		sim.apply_input(0.0, 1.0, 0.0, 0.1)
	assert_true(sim.speed >= -sim.max_reverse, "reverse must be clamped")
	assert_true(sim.speed < 0.0)

func test_reset_restores_valid_state() -> void:
	var sim := BikeSim.new()
	sim.apply_input(1.0, 0.0, 0.5, 3.0)
	sim.reset_motion()
	assert_eq(sim.speed, 0.0)
	assert_eq(sim.consume_heading_delta(), 0.0)
	assert_true(sim.is_healthy())

func test_damage_stays_within_range() -> void:
	var sim := BikeSim.new()
	sim.apply_damage(2.0)
	assert_true(sim.condition >= 0.0, "condition has a lower bound")
	sim.apply_damage(-5.0)
	assert_true(sim.condition <= 1.0, "condition has an upper bound")
	var top_before: float = sim.max_speed
	sim.apply_input(1.0, 0.0, 0.0, 5.0)
	assert_true(sim.speed >= 0.0)

func test_damaged_bike_caps_speed() -> void:
	var sim := BikeSim.new(30.0, 8.0, 14.0, 2.2)
	sim.apply_damage(0.5)
	for i in range(600):
		sim.apply_input(1.0, 0.0, 0.0, 0.1)
	assert_true(sim.speed <= 15.0 + 0.01, "damage must reduce effective top speed")
