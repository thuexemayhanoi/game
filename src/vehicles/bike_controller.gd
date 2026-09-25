extends CharacterBody3D
## Arcade motorbike controller. Deterministic, testable outside the open world.
## Stats are data-driven from src/data/bikes.json by the spawn code.

signal speed_changed(kmh: float)

class_name BikeController

var stats := {"max_speed": 22.0, "acceleration": 9.0, "braking": 14.0,
	"steer_speed": 2.2, "drag": 1.2, "reverse_speed": 4.0}

var speed := 0.0        # forward m/s
var steer_angle := 0.0  # radians
var _spawn_transform: Transform3D

@export var bike_id := "song_hong_50"

func _ready() -> void:
	_spawn_transform = global_transform
	load_stats(bike_id)

func load_stats(id: String) -> void:
	var data := _load_bike_data()
	if data.has(id):
		for key in data[id]:
			stats[key] = data[id][key]

static func _load_bike_data() -> Dictionary:
	var path := "res://src/data/bikes.json"
	if not FileAccess.file_exists(path):
		push_warning("bikes.json missing; using defaults")
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _physics_process(delta: float) -> void:
	var throttle: float = 0.0
	var brake: float = 0.0
	var steer: float = 0.0
	var reset := false
	if Engine.is_editor_hint():
		return
	if InputMap.has_action("throttle"):
		throttle = InputAdapter.get_throttle()
		brake = InputAdapter.get_brake()
		steer = InputAdapter.get_steer()
		reset = InputAdapter.just_reset()
	drive(delta, throttle, brake, steer)
	if reset:
		reset_bike()

## Pure simulation step — callable directly from tests.
func drive(delta: float, throttle: float, brake: float, steer: float) -> void:
	if throttle > 0.0:
		speed += throttle * float(stats.acceleration) * delta
	else:
		speed -= float(stats.drag) * delta * signf(speed)
	if brake > 0.0:
		if speed > 0.0:
			speed = maxf(speed - brake * float(stats.braking) * delta, 0.0)
		else:
			speed = maxf(speed - brake * float(stats.acceleration) * 0.5 * delta, -float(stats.reverse_speed))
	speed = clampf(speed, -float(stats.reverse_speed), float(stats.max_speed))
	# Speed-sensitive steering: less angle at high speed.
	var steer_limit: float = float(stats.steer_speed) / (1.0 + absf(speed) * 0.12)
	steer_angle = steer * steer_limit
	if absf(speed) > 0.05:
		rotate_y(-steer_angle * delta * signf(speed) * clampf(absf(speed) * 0.35, 0.0, 1.6))
	velocity = -global_transform.basis.z * speed
	move_and_slide()
	speed_changed.emit(speed_kmh())

func reset_bike() -> void:
	global_transform = _spawn_transform
	speed = 0.0
	steer_angle = 0.0
	velocity = Vector3.ZERO

func speed_kmh() -> float:
	return absf(speed) * 3.6
