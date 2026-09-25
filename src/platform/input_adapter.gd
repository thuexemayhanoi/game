extends Node
## Autoload: InputAdapter. Single source for input from keyboard, gamepad and touch.
## Actions are registered idempotently so reruns never duplicate them.

const ACTIONS := ["throttle", "brake", "steer_left", "steer_right", "reset_bike"]

# Touch state, written by TouchControls (src/ui/touch_controls.gd)
var touch := {"throttle": 0.0, "brake": 0.0, "steer": 0.0, "reset": false}

func _ready() -> void:
	_register_actions()

func _register_actions() -> void:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	_bind_key("throttle", KEY_W)
	_bind_key("throttle", KEY_UP)
	_bind_key("brake", KEY_S)
	_bind_key("brake", KEY_DOWN)
	_bind_key("steer_left", KEY_A)
	_bind_key("steer_left", KEY_LEFT)
	_bind_key("steer_right", KEY_D)
	_bind_key("steer_right", KEY_RIGHT)
	_bind_key("reset_bike", KEY_R)
	# Gamepad
	_bind_joy_axis("throttle", JOY_AXIS_LEFT_Y, -1.0)
	_bind_joy_axis("brake", JOY_AXIS_LEFT_Y, 1.0)
	_bind_joy_axis("steer_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_joy_axis("steer_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_joy_button("throttle", JOY_BUTTON_A)
	_bind_joy_button("brake", JOY_BUTTON_B)
	_bind_joy_button("reset_bike", JOY_BUTTON_Y)

func _bind_key(action: String, key: Key) -> void:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and ev.physical_keycode == key:
			return
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	InputMap.action_add_event(action, ev)

func _bind_joy_axis(action: String, axis: int, value: float) -> void:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadMotion and ev.axis == axis and signf(ev.axis_value) == signf(value):
			return
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	InputMap.action_add_event(action, ev)

func _bind_joy_button(action: String, button: int) -> void:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton and ev.button_index == button:
			return
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)

func is_touch_device() -> bool:
	if DisplayServer.is_touchscreen_available():
		return true
	return OS.has_feature("web") and 		JavaScriptBridge.is_instance_valid() and 		bool(JavaScriptBridge.eval("('ontouchstart' in window) || (navigator.maxTouchPoints > 0)", false)) if OS.has_feature("web") else false

func get_throttle() -> float:
	return clampf(Input.get_action_strength("throttle") + touch.throttle, 0.0, 1.0)

func get_brake() -> float:
	return clampf(Input.get_action_strength("brake") + touch.brake, 0.0, 1.0)

## -1.0 (left) .. +1.0 (right)
func get_steer() -> float:
	var steer: = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	return clampf(steer + touch.steer, -1.0, 1.0)

func just_reset() -> bool:
	return Input.is_action_just_pressed("reset_bike") or touch.reset
