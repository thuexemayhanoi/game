class_name ChaseCamera
extends Camera3D
## Smooth follow camera behind the bike.

@export var target: Node3D
@export var offset := Vector3(0.0, 2.6, 5.5)
@export var follow_speed := 5.0

func _ready() -> void:
	make_current()

func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var desired: Vector3 = target.global_position + target.global_transform.basis * offset
	global_position = global_position.lerp(desired, clampf(follow_speed * delta, 0.0, 1.0))
	look_at(target.global_position + Vector3.UP * 1.0, Vector3.UP)
