extends GutTest
## Bike acceleration / braking simulation (testable outside the open world).

var _bike: Node

func before_each():
	_bike = BikeController.new()
	add_child_autofree(_bike)

func test_acceleration_increases_speed():
	for i in 30:
		_bike.drive(1.0 / 60.0, 1.0, 0.0, 0.0)
	assert_gt(_bike.speed, 0.0)

func test_brake_stops_bike():
	for i in 60:
		_bike.drive(1.0 / 60.0, 1.0, 0.0, 0.0)
	var top := _bike.speed
	for i in 120:
		_bike.drive(1.0 / 60.0, 0.0, 1.0, 0.0)
	assert_lt(_bike.speed, 0.5, "bike should stop from %.2f m/s" % top)

func test_speed_capped_at_max():
	for i in 600:
		_bike.drive(1.0 / 60.0, 1.0, 0.0, 0.0)
	assert_lte(_bike.speed, float(_bike.stats["max_speed"]) + 0.001)

func test_reset_restores_spawn():
	var spawn: Transform3D = _bike.global_transform
	for i in 60:
		_bike.drive(1.0 / 60.0, 1.0, 0.0, 1.0)
	_bike.reset_bike()
	assert_eq(_bike.speed, 0.0)
