class_name Motorbike
extends CharacterBody3D
## Player-controlled motorbike for the vertical slice.
## Arcade physics driven by the deterministic BikeSim core.

const GRAVITY := 25.0

var bike_data: BikeData
var sim: BikeSim
var spawn_transform: Transform3D

func _ready() -> void:
	if bike_data == null:
		bike_data = BikeData.load_default()
	sim = BikeSim.from_bike_data(bike_data)
	_build_collision()
	_build_visuals()
	spawn_transform = global_transform

func _physics_process(delta: float) -> void:
	if InputManager.get_reset_requested():
		reset_to_spawn()
		return
	sim.apply_input(InputManager.get_throttle(), InputManager.get_brake(), InputManager.get_steer(), delta)
	rotate_y(sim.consume_heading_delta())
	var vy := velocity.y
	velocity = -global_transform.basis.z * sim.speed
	if is_on_floor():
		vy = 0.0
	else:
		vy -= GRAVITY * delta
	velocity.y = vy
	move_and_slide()
	EventBus.speed_changed.emit(get_speed_kmh())

func reset_to_spawn() -> void:
	global_transform = spawn_transform
	sim.reset_motion()
	velocity = Vector3.ZERO
	EventBus.bike_reset.emit(global_position)

func get_speed_kmh() -> float:
	return sim.get_speed_kmh()

func _build_collision() -> void:
	if has_node("Collision"):
		return
	var cs := CollisionShape3D.new()
	cs.name = "Collision"
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.7, 1.1, 2.0)
	cs.shape = shape
	add_child(cs)

func _build_visuals() -> void:
	if has_node("Body"):
		return
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color(0.91, 0.39, 0.16)
	var body := MeshInstance3D.new()
	body.name = "Body"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.6, 0.5, 1.9)
	mesh.material = paint
	body.mesh = mesh
	body.position = Vector3(0, 0.62, 0)
	add_child(body)
	var rubber := StandardMaterial3D.new()
	rubber.albedo_color = Color(0.12, 0.12, 0.14)
	for i in range(2):
		var wheel := MeshInstance3D.new()
		wheel.name = "Wheel" + str(i)
		var wmesh := CylinderMesh.new()
		wmesh.top_radius = 0.3
		wmesh.bottom_radius = 0.3
		wmesh.height = 0.12
		wmesh.radial_segments = 16
		wmesh.material = rubber
		wheel.mesh = wmesh
		wheel.rotation = Vector3(0, 0, PI / 2)
		wheel.position = Vector3(0, 0.3, -0.75 if i == 0 else 0.75)
		add_child(wheel)
	var rider := MeshInstance3D.new()
	rider.name = "Rider"
	var rmesh := BoxMesh.new()
	rmesh.size = Vector3(0.42, 0.6, 0.3)
	var rmat := StandardMaterial3D.new()
	rmat.albedo_color = Color(0.2, 0.45, 0.75)
	rmesh.material = rmat
	rider.mesh = rmesh
	rider.position = Vector3(0, 1.18, -0.1)
	add_child(rider)
