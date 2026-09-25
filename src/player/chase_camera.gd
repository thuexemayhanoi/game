extends Camera3D
## Smooth chase camera for the bike. Cheap and jitter-free on web/mobile.

@export var target: Node3D
@export var distance := 6.5
@export var height := 2.6
@export var lerp_speed := 6.0

var _offset := Vector3.ZERO

func _ready() -> void:
	make_current()

func _physics_process(delta: float) -> void:
	if target == null:
		return
	var desired: Vector3 = target.global_position + 		(target.global_transform.basis * Vector3(0.0, height, distance))
	global_position = global_position.lerp(desired, clampf(lerp_speed * delta, 0.0, 1.0))
	look_at(target.global_position + Vector3(0, 1.0, 0), Vector3.UP)
