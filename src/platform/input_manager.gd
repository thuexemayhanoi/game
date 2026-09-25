extends Node
## Autoload: unified bike input from keyboard, gamepad and touch overlays.
## Actions are registered at runtime so they are available headless and in tests.

const DEAD_ZONE := 0.15

var touch_throttle := 0.0
var touch_brake := 0.0
var touch_steer := 0.0
var touch_reset := false

func _ready() -> void:
	_ensure_default_actions()

func _ensure_default_actions() -> void:
	if not InputMap.has_action("throttle"):
		InputMap.add_action("throttle")
		_add_key("throttle", KEY_W)
		_add_key("throttle", KEY_UP)
		_add_axis("throttle", JOY_AXIS_LEFT_Y, -1.0)
	if not InputMap.has_action("brake"):
		InputMap.add_action("brake")
		_add_key("brake", KEY_S)
		_add_key("brake", KEY_DOWN)
		_add_axis("brake", JOY_AXIS_LEFT_Y, 1.0)
		_add_joy_button("brake", JOY_BUTTON_A)
	if not InputMap.has_action("steer_left"):
		InputMap.add_action("steer_left")
		_add_key("steer_left", KEY_A)
		_add_key("steer_left", KEY_LEFT)
		_add_axis("steer_left", JOY_AXIS_LEFT_X, -1.0)
	if not InputMap.has_action("steer_right"):
		InputMap.add_action("steer_right")
		_add_key("steer_right", KEY_D)
		_add_key("steer_right", KEY_RIGHT)
		_add_axis("steer_right", JOY_AXIS_LEFT_X, 1.0)
	if not InputMap.has_action("reset"):
		InputMap.add_action("reset")
		_add_key("reset", KEY_R)
		_add_joy_button("reset", JOY_BUTTON_Y)

func _add_key(action: String, key: Key) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	InputMap.action_add_event(action, ev)

func _add_axis(action: String, axis: int, axis_value: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = axis_value
	InputMap.action_add_event(action, ev)

func _add_joy_button(action: String, button: JoyButton) -> void:
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)

func _apply_deadzone(v: float) -> float:
	var a := absf(v)
	if a <= DEAD_ZONE:
		return 0.0
	return signf(v) * ((a - DEAD_ZONE) / (1.0 - DEAD_ZONE))

func get_throttle() -> float:
	return clampf(maxf(Input.get_action_strength("throttle"), touch_throttle), 0.0, 1.0)

func get_brake() -> float:
	return clampf(maxf(Input.get_action_strength("brake"), touch_brake), 0.0, 1.0)

func get_steer() -> float:
	var v := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	return clampf(_apply_deadzone(v + touch_steer), -1.0, 1.0)

func get_reset_requested() -> bool:
	var v: bool = touch_reset or Input.is_action_just_pressed("reset")
	touch_reset = false
	return v
