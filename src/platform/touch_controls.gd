class_name TouchControls
extends CanvasLayer
## Virtual overlay: steering, throttle, brake and reset buttons.
## Only visible on touch devices or narrow (mobile) viewports.

var btn_steer_left: Button
var btn_steer_right: Button
var btn_throttle: Button
var btn_brake: Button
var btn_reset: Button
var root: Control

func _ready() -> void:
	layer = 20
	_build()
	visible = _should_show()
	root.resized.connect(_layout)
	_layout()

func _should_show() -> bool:
	if DisplayServer.is_touchscreen_available():
		return true
	return get_viewport().get_visible_rect().size.x < 900.0

func _build() -> void:
	if root != null:
		return
	root = Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	btn_steer_left = _make_button("<")
	btn_steer_right = _make_button(">")
	btn_throttle = _make_button("GAS")
	btn_brake = _make_button("BRK")
	btn_reset = _make_button("RESET")
	root.add_child(btn_steer_left)
	root.add_child(btn_steer_right)
	root.add_child(btn_throttle)
	root.add_child(btn_brake)
	root.add_child(btn_reset)
	_bind_axis(btn_steer_left, "steer", -1.0)
	_bind_axis(btn_steer_right, "steer", 1.0)
	_bind_axis(btn_throttle, "throttle", 1.0)
	_bind_axis(btn_brake, "brake", 1.0)
	btn_reset.button_down.connect(func() -> void: InputManager.touch_reset = true)

func _bind_axis(btn: Button, action: String, value: float) -> void:
	btn.button_down.connect(func() -> void: _set(action, value))
	btn.button_up.connect(func() -> void: _set(action, 0.0))

func _set(action: String, value: float) -> void:
	match action:
		"steer":
			InputManager.touch_steer = value
		"throttle":
			InputManager.touch_throttle = value
		"brake":
			InputManager.touch_brake = value

func _layout() -> void:
	var size := root.size
	var b := 96.0
	var pad := 18.0
	btn_steer_left.position = Vector2(pad, size.y - b - pad)
	btn_steer_right.position = Vector2(pad + b + 12.0, size.y - b - pad)
	btn_throttle.position = Vector2(size.x - b - pad, size.y - b - pad)
	btn_brake.position = Vector2(size.x - b - pad, size.y - 2.0 * b - pad - 12.0)
	btn_reset.custom_minimum_size = Vector2(120.0, 54.0)
	btn_reset.position = Vector2(size.x - 120.0 - pad, pad)

func _make_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(96.0, 96.0)
	btn.add_theme_font_size_override("font_size", 22)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(1, 1, 1, 0.22)
	st.set_corner_radius_all(48)
	var stp := StyleBoxFlat.new()
	stp.bg_color = Color(1, 1, 1, 0.45)
	stp.set_corner_radius_all(48)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("pressed", stp)
	btn.focus_mode = Control.FOCUS_NONE
	return btn
