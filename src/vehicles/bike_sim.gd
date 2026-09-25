class_name BikeSim
extends RefCounted
## Deterministic arcade bike simulation core.
## Pure logic: no rendering, no scene dependencies, fully unit-testable.

var speed := 0.0
var heading := 0.0
var condition := 1.0

var max_speed := 30.0
var max_reverse := 4.0
var acceleration := 8.0
var brake_force := 14.0
var drag := 1.2
var turn_rate := 2.2

var _heading_consumed := 0.0

func _init(p_max_speed: float = 30.0, p_acceleration: float = 8.0, p_brake_force: float = 14.0, p_turn_rate: float = 2.2) -> void:
	max_speed = _safe(p_max_speed, 30.0)
	acceleration = _safe(p_acceleration, 8.0)
	brake_force = _safe(p_brake_force, 14.0)
	turn_rate = _safe(p_turn_rate, 2.2)

static func from_bike_data(data: BikeData) -> BikeSim:
	return BikeSim.new(data.max_speed, data.acceleration, data.brake_force, data.turn_rate)

func apply_input(throttle: float, brake: float, steer: float, delta: float) -> void:
	throttle = _unit(throttle)
	brake = _unit(brake)
	steer = _unit(steer)
	if not is_finite(delta) or delta <= 0.0:
		delta = 0.0
	# Damage reduces effective top speed but never below a crawl margin.
	var top := maxf(max_speed * clampf(condition, 0.1, 1.0), 1.0)
	if throttle > 0.0:
		speed += acceleration * throttle * delta
	if brake > 0.0:
		speed -= brake_force * brake * delta
	# Rolling drag proportional to speed.
	var drag_loss: float = minf(absf(speed), drag * delta * (1.0 + absf(speed) * 0.05))
	speed -= signf(speed) * drag_loss
	speed = clampf(speed, -max_reverse, top)
	# Speed-sensitive steering; reversing inverts steering.
	var sf := clampf(absf(speed) / 8.0, 0.0, 1.0)
	heading += steer * turn_rate * sf * signf(speed) * delta
	heading = wrapf(heading, -TAU, TAU)

func consume_heading_delta() -> float:
	var d := heading - _heading_consumed
	_heading_consumed = heading
	return d

func reset_motion() -> void:
	speed = 0.0
	heading = 0.0
	_heading_consumed = 0.0

func apply_damage(amount: float) -> void:
	condition = clampf(condition - _safe(amount, 0.0), 0.0, 1.0)

func get_speed_kmh() -> float:
	return absf(speed) * 3.6

func is_healthy() -> bool:
	return is_finite(speed) and condition > 0.0

func _unit(v: float) -> float:
	v = _safe(v, 0.0)
	return clampf(v, 0.0, 1.0)

func _safe(v: float, fallback: float) -> float:
	if not is_finite(v):
		return fallback
	return v
