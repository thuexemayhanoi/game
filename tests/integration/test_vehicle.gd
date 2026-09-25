extends GutTest
## Integration tests for the motorbike vehicle (GAME-0019/0040/0055 / TEST-0014/0015).
## Deterministic: drives the pure BikeSim core directly instead of relying on
## engine frame timing (which is not reliable under headless GUT runs).

func _make_bike() -> Motorbike:
	var bike: Motorbike = load("res://src/vehicles/motorbike.tscn").instantiate()
	add_child_autofree(bike)
	bike.global_position = Vector3(0, 1.2, 0)
	bike.spawn_transform = bike.global_transform
	return bike

func _step(bike: Motorbike, frames: int, throttle: float = 0.0, brake: float = 0.0, steer: float = 0.0) -> void:
	for i in range(frames):
		bike.sim.apply_input(throttle, brake, steer, 1.0 / 60.0)

func test_throttle_accelerates_bike() -> void:
	var bike := _make_bike()
	_step(bike, 60, 1.0)
	assert_gt(bike.sim.speed, 0.5, "bike must accelerate under throttle")

func test_brake_reduces_speed() -> void:
	var bike := _make_bike()
	_step(bike, 60, 1.0)
	var before: float = bike.sim.speed
	assert_gt(before, 0.5)
	_step(bike, 30, 0.0, 1.0)
	assert_lt(bike.sim.speed, before, "braking must reduce bike speed")

func test_max_speed_is_respected() -> void:
	var bike := _make_bike()
	_step(bike, 600, 1.0)
	assert_true(bike.sim.speed <= bike.bike_data.max_speed + 0.01)

func test_steering_changes_heading() -> void:
	var bike := _make_bike()
	_step(bike, 120, 1.0, 0.0, 1.0)
	assert_almost_ne(bike.sim.heading, 0.0, 0.01)

func test_reset_restores_spawn_and_stops_bike() -> void:
	var bike := _make_bike()
	var spawn: Transform3D = bike.spawn_transform
	_step(bike, 60, 1.0)
	assert_gt(bike.sim.speed, 0.5)
	bike.reset_to_spawn()
	assert_eq(bike.sim.speed, 0.0, "reset must stop the bike")
	assert_almost_eq(bike.global_position.x, spawn.origin.x, 0.01)
	assert_almost_eq(bike.global_position.y, spawn.origin.y, 0.01)
	assert_almost_eq(bike.global_position.z, spawn.origin.z, 0.01)

func test_bike_data_loads() -> void:
	var bike := _make_bike()
	assert_not_null(bike.bike_data)
	assert_eq(bike.bike_data.id, "scooter_default")
