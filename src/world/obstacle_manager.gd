class_name ObstacleManager
extends Node2D
## Pooled endless obstacle spawner (MOTO HOP), driven by DifficultyManager
## params and the deterministic ObstacleGenerator. Nodes are pre-created once
## and recycled — no per-frame allocation.

const POOL_SIZE := 6
const SPAWN_X := 700.0
const RECYCLE_X := -160.0
const FIELD_TOP := 70.0
const FIELD_BOTTOM := 880.0

var difficulty := DifficultyManager.new()
var generator := ObstacleGenerator.new()

var _pool: Array[Obstacle] = []
var _active: Array[Obstacle] = []
var _next_id := 1
var _next_spawn_x := SPAWN_X
var _theme_cycle := 0

func _ready() -> void:
	for i in range(POOL_SIZE):
		var o := Obstacle.new()
		o.name = "Obstacle" + str(i)
		o.visible = false
		add_child(o)
		_pool.append(o)

func reset(seed_value: int = 20260927) -> void:
	generator.reseed(seed_value)
	for o in _active:
		o.visible = false
		_pool.append(o)
	_active.clear()
	_next_id = 1
	_next_spawn_x = SPAWN_X
	_theme_cycle = 0

func active_count() -> int:
	return _active.size()

## Advances all obstacles by scroll_speed * delta. Returns the ids of pairs the
## player passed during this step (for exactly-once scoring).
func step(delta: float, params: Dictionary, player_x: float) -> Array:
	var speed := maxf(0.0, float(params.get("scroll_speed", 180.0)))
	var passed: Array = []
	for o in _active:
		o.position.x -= speed * delta
		if not o.scored and o.has_passed(player_x):
			o.scored = true
			passed.append(o.id)
		o.queue_redraw()
	# Recycle obstacles behind the player.
	var still_active: Array[Obstacle] = []
	for o in _active:
		if o.position.x < RECYCLE_X:
			o.visible = false
			_pool.append(o)
		else:
			still_active.append(o)
	_active = still_active
	# Spawn when the frontier has room.
	if _active.is_empty() or (_next_spawn_x - _active[_active.size() - 1].position.x) <= 0.0:
		_spawn(params)
	elif _active[_active.size() - 1].position.x <= SPAWN_X - float(params.get("spacing", 380.0)):
		_spawn(params)
	return passed

func _spawn(params: Dictionary) -> void:
	if _pool.is_empty():
		return
	var placement := generator.generate(params)
	var o: Obstacle = _pool.pop_front()
	o.position = Vector2(SPAWN_X, 0.0)
	o.setup(_next_id, float(placement["gap_center"]), float(placement["gap_size"]),
		_theme_cycle % Obstacle.THEME_COUNT, FIELD_TOP, FIELD_BOTTOM)
	o.visible = true
	_next_id += 1
	_theme_cycle += 1
	_active.append(o)

## True when the player circle overlaps any active obstacle rect.
func check_collision(player_circle: Dictionary) -> bool:
	var c: Vector2 = player_circle.get("center", Vector2.ZERO)
	var r: float = player_circle.get("radius", 0.0)
	for o in _active:
		for rect in o.get_collision_rects():
			var closest := Vector2(clampf(c.x, rect.position.x, rect.end.x),
				clampf(c.y, rect.position.y, rect.end.y))
			if c.distance_squared_to(closest) <= r * r:
				return true
	return false
