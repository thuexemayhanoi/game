class_name PlayerBike
extends Node2D
## The original cartoon motorbike (MOTO HOP). Visuals + collisions wrap the
## pure HopSim core so physics stays deterministic and unit-testable.

const START_POS := Vector2(180.0, 460.0)
const FLOOR_Y := 880.0
const CEILING_Y := 60.0
const COLLISION_RADIUS := 26.0

var sim := HopSim.new()
var crashed := false
## Animation juice (all subtle, child-friendly).
var _wheel_spin := 0.0
var _squash := 0.0

func _ready() -> void:
	reset()

func reset() -> void:
	sim.reset(START_POS)
	crashed = false
	_wheel_spin = 0.0
	_squash = 0.0
	_update_transform()

func hop() -> void:
	if crashed:
		return
	sim.hop()
	_squash = 0.18
	EventBus.hop_performed.emit()

## One physics step. Returns "crashed" when the bike hits the road.
func step(delta: float, forward_speed: float) -> String:
	if crashed:
		return "crashed"
	sim.advance(delta, forward_speed)
	_wheel_spin += forward_speed * delta * 0.05
	_squash = maxf(_squash - delta, 0.0)
	# Friendly ceiling: bump softly, never crash.
	if sim.position.y < CEILING_Y:
		sim.position.y = CEILING_Y
		sim.velocity.y = maxf(sim.velocity.y, 0.0)
	_update_transform()
	queue_redraw()
	if sim.position.y >= FLOOR_Y:
		crashed = true
		EventBus.crashed.emit()
		return "crashed"
	return "ok"

func _update_transform() -> void:
	position = sim.position
	rotation = sim.rotation

## Circle used for obstacle collision (kept generous-forgiving for kids).
func get_collision_circle() -> Dictionary:
	return {"center": sim.position, "radius": COLLISION_RADIUS}

## True when this bike circle overlaps an axis-aligned rect.
func circle_overlaps_rect(rect: Rect2) -> bool:
	var c := sim.position
	var closest := Vector2(clampf(c.x, rect.position.x, rect.end.x),
		clampf(c.y, rect.position.y, rect.end.y))
	return c.distance_squared_to(closest) <= COLLISION_RADIUS * COLLISION_RADIUS

func _draw() -> void:
	var squash_scale: float = 1.0 + _squash
	var draw_scale := Vector2(1.0 + _squash * 0.5, 1.0 - _squash * 0.8)
	draw_set_transform(Vector2.ZERO, 0.0, draw_scale)
	# Wheels: dark tires, light hubs, spinning spokes.
	var wheel_r := 16.0
	for wx in [-22.0, 22.0]:
		draw_circle(Vector2(wx, 14.0), wheel_r, Color(0.15, 0.15, 0.18))
		draw_circle(Vector2(wx, 14.0), wheel_r - 5.0, Color(0.85, 0.85, 0.9))
		for i in range(3):
			var a := _wheel_spin + i * TAU / 3.0
			draw_line(Vector2(wx, 14.0),
				Vector2(wx + cos(a) * (wheel_r - 6.0), 14.0 + sin(a) * (wheel_r - 6.0)),
				Color(0.4, 0.4, 0.45), 2.5)
	# Body: cheerful scooter shell.
	var body_col := Color(0.99, 0.55, 0.15)
	var body := PackedVector2Array([
		Vector2(-24, 8), Vector2(-16, -4), Vector2(14, -6), Vector2(26, 4),
		Vector2(24, 12), Vector2(-20, 14),
	])
	draw_colored_polygon(body, body_col)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, -4), Vector2(-8, -18), Vector2(10, -14), Vector2(12, -6),
	]), Color(0.96, 0.72, 0.2))
	# Headlight (yellow) + tail light.
	draw_circle(Vector2(26, -2), 5.0, Color(1.0, 0.93, 0.4))
	draw_circle(Vector2(-23, 0), 3.0, Color(0.9, 0.2, 0.2))
	# Handlebar.
	draw_line(Vector2(12, -16), Vector2(18, -26), Color(0.3, 0.3, 0.35), 3.0)
	draw_circle(Vector2(18, -26), 3.5, Color(0.3, 0.3, 0.35))
	# Seat.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -8), Vector2(2, -8), Vector2(0, -13), Vector2(-10, -13),
	]), Color(0.35, 0.25, 0.55))
	# Rider: friendly helmeted silhouette.
	draw_circle(Vector2(-4, -22), 7.0, Color(0.25, 0.6, 0.95))
	draw_circle(Vector2(-1, -23), 5.5, Color(1.0, 0.95, 0.85))
	draw_circle(Vector2(-1, -23), 4.0, Color(0.2, 0.2, 0.25))
	draw_line(Vector2(-2, -14), Vector2(-6, -6), Color(0.25, 0.6, 0.95), 5.0)
