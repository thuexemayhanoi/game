extends Node
## Autoload (MOTO HOP): registers one-button arcade actions at runtime so they
## exist headless and in tests; exposes small polling helpers.
## Touch and mouse taps are handled by the game controller via _unhandled_input,
## so tapping anywhere in the gameplay area always works without hover.

func _ready() -> void:
	_ensure_default_actions()

func _ensure_default_actions() -> void:
	if not InputMap.has_action("hop"):
		InputMap.add_action("hop")
		_add_key("hop", KEY_SPACE)
		_add_key("hop", KEY_UP)
		_add_joy_button("hop", JOY_BUTTON_A)
	if not InputMap.has_action("pause"):
		InputMap.add_action("pause")
		_add_key("pause", KEY_ESCAPE)
		_add_key("pause", KEY_P)
		_add_joy_button("pause", JOY_BUTTON_START)
	if not InputMap.has_action("toggle_mute"):
		InputMap.add_action("toggle_mute")
		_add_key("toggle_mute", KEY_M)

func _add_key(action: String, key: Key) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	InputMap.action_add_event(action, ev)

func _add_joy_button(action: String, button: JoyButton) -> void:
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)

## Poll once per frame from _process.
func hop_requested() -> bool:
	return Input.is_action_just_pressed("hop")

func pause_requested() -> bool:
	return Input.is_action_just_pressed("pause")

func mute_requested() -> bool:
	return Input.is_action_just_pressed("toggle_mute")
