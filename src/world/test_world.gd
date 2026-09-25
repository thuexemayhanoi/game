class_name TestWorld
extends Node3D
## Minimal test track world: ground, crossing roads, reference buildings,
## a controllable motorbike, chase camera, HUD and touch controls.
## All geometry is procedural primitives (original placeholder assets only).

var bike: Motorbike
var camera: ChaseCamera
var hud: BikeHud
var spawn_point: Node3D

func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_roads()
	_build_buildings()
	_spawn_bike()

func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.7, 0.9)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.62, 0.68)
	env.ambient_light_energy = 1.0
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)
	var light := DirectionalLight3D.new()
	light.name = "Sun"
	light.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	light.light_energy = 1.2
	add_child(light)

func _build_ground() -> void:
	var ground := StaticBody3D.new()
	ground.name = "Ground"
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(500.0, 1.0, 500.0)
	cs.shape = shape
	cs.position = Vector3(0, -0.5, 0)
	ground.add_child(cs)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(500.0, 1.0, 500.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.34, 0.44, 0.3)
	box.material = mat
	mesh.mesh = box
	mesh.position = Vector3(0, -0.5, 0)
	ground.add_child(mesh)
	add_child(ground)

func _build_roads() -> void:
	var road_defs := [Vector3(12.0, 0.1, 420.0), Vector3(420.0, 0.1, 12.0)]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.22)
	for i in range(road_defs.size()):
		var m := MeshInstance3D.new()
		m.name = "Road" + str(i)
		var b := BoxMesh.new()
		b.size = road_defs[i]
		b.material = mat
		m.mesh = b
		m.position = Vector3(0, 0.05, 0)
		add_child(m)

func _build_buildings() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.58, 0.5)
	for i in range(10):
		var m := MeshInstance3D.new()
		m.name = "Building" + str(i)
		var b := BoxMesh.new()
		var h := 6.0 + (i % 4) * 3.0
		b.size = Vector3(8.0, h, 8.0)
		b.material = mat
		m.mesh = b
		var side := -1.0 if i % 2 == 0 else 1.0
		m.position = Vector3(side * 14.0, h / 2.0, -80.0 + 18.0 * i)
		add_child(m)

func _spawn_bike() -> void:
	spawn_point = Node3D.new()
	spawn_point.name = "SpawnPoint"
	spawn_point.position = Vector3(0, 1.2, 0)
	add_child(spawn_point)
	var scene := load("res://src/vehicles/motorbike.tscn")
	bike = scene.instantiate()
	bike.name = "PlayerBike"
	add_child(bike)
	bike.global_position = spawn_point.global_position
	bike.spawn_transform = bike.global_transform
	camera = ChaseCamera.new()
	camera.name = "ChaseCamera"
	camera.target = bike
	add_child(camera)
	camera.global_position = bike.global_position + Vector3(0, 3.0, 6.0)
	hud = BikeHud.new()
	hud.name = "HUD"
	hud.bike = bike
	add_child(hud)
	var touch := TouchControls.new()
	touch.name = "TouchControls"
	add_child(touch)
