extends GutTest
## Integration tests for the motorbike vehicle (GAME-0019/0040/0055 / TEST-0014/0015).

func _make_bike() -> Motorbike:
	var bike: Motorbike = load("res://src/vehicles/motorbike.tscn").instantiate()
	add_child_autofree(bike)
	bike.global_position = Vector3(0, 1.2, 0)
	return bike

func _frames(n: int) -> void:
	for i in range(n):
		await get_tree().physics_frame

func test_throttle_accelerates_bike() -> void:
	var bike := _make_bike()
	_frames(5)
	InputManager.touch_throttle = 1.0
	_frames(60)
	InputManager.touch_throttle = 0.0
	assert_gt(bike.sim.speed, 0.5, "bike must accelerate under throttle")

func test_brake_reduces_speed() -> void:
	var bike := _make_bike()
	_frames(5)
	InputManager.touch_throttle = 1.0
	_frames(60)
	var before: float = bike.sim.speed
	InputManager.touch_throttle = 0.0
	InputManager.touch_brake = 1.0
	_frames(30)
	InputManager.touch_brake = 0.0
	assert_lt(bike.sim.speed, before, "braking must reduce bike speed")

func test_max_speed_is_respected() -> void:
	var bike := _make_bike()
	_frames(5)
	InputManager.touch_throttle = 1.0
	_frames(240)
	InputManager.touch_throttle = 0.0
	assert_true(bike.sim.speed <= bike.bike_data.max_speed + 0.01)

func test_reset_restores_spawn_transform() -> void:
	var bike := _make_bike()
	_frames(5)
	var spawn: Transform3D = bike.spawn_transform
	InputManager.touch_throttle = 1.0
	_frames(60)
	InputManager.touch_throttle = 0.0
	InputManager.touch_reset = true
	_frames(5)
	assert_almost_eq(bike.global_position.x, spawn.origin.x, 0.01)
	assert_almost_eq(bike.global_position.z, spawn.origin.z, 0.01)
	assert_eq(bike.sim.speed, 0.0, "reset must stop the bike")
	assert_almost_eq(bike.global_position.y, spawn.origin.y, 0.01)

func test_bike_data_loads() -> void:
	var bike := _make_bike()
	_frames(3)
	assert_not_null(bike.bike_data)
	assert_eq(bike.bike_data.id, "scooter_default")
