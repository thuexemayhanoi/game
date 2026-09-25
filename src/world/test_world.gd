extends Node3D
## Vertical-slice test world: wires bike spawn, HUD and camera. All primitives.

const BIKE_SCENE := preload("res://src/vehicles/bike.tscn")
const TOUCH_CONTROLS := preload("res://src/ui/touch_controls.gd")

@onready var camera: Camera3D = $ChaseCamera
@onready var hud: CanvasLayer = $SpeedHud

func _ready() -> void:
	var bike := BIKE_SCENE.instantiate()
	bike.position = Vector3(0, 0.6, 0)
	add_child(bike)
	camera.target = bike
	hud.bind_bike(bike)
	var touch := CanvasLayer.new()
	touch.set_script(TOUCH_CONTROLS)
	add_child(touch)
