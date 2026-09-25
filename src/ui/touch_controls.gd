extends CanvasLayer
## Touch overlay: throttle, brake, left/right steer, reset. Shown only in touch mode.
## Buttons are generated in code — no textures required, no duplicated scenes.

var _left: Button
var _right: Button
var _throttle: Button
var _brake: Button
var _reset: Button

func _ready() -> void:
	if not InputAdapter.is_touch_device():
		queue_free()
		return
	_build()

func _build() -> void:
	_left = _make_button("◀", Vector2(20, -180), _set_steer, -1.0)
	_right = _make_button("▶", Vector2(110, -180), _set_steer, 1.0)
	_brake = _make_button("BRAKE", Vector2(-230, -100), _set_brake, 1.0)
	_throttle = _make_button("GO", Vector2(-120, -100), _set_throttle, 1.0)
	_reset = _make_button("RESET", Vector2(20, -60), null, 0.0)
	_reset.pressed.connect(func():
		InputAdapter.touch.reset = true
		await get_tree().create_timer(0.1).timeout
		InputAdapter.touch.reset = false)

func _make_button(text: String, offset: Vector2, setter: Callable, value: float) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(80, 80)
	b.position = Vector2(get_viewport().get_visible_rect().size) + offset - Vector2(0, 0)
	b.anchor_left = 1.0
	b.anchor_top = 1.0
	b.anchor_right = 1.0
	b.anchor_bottom = 1.0
	b.offset_left = offset.x
	b.offset_top = offset.y
	b.offset_right = offset.x + 80
	b.offset_bottom = offset.y + 80
	b.toggle_mode = false
	b.button_down.connect(func(): setter.call(value) if setter.is_valid() else null)
	b.button_up.connect(func():
		if setter == _set_steer: InputAdapter.touch.steer = 0.0
		elif setter == _set_throttle: InputAdapter.touch.throttle = 0.0
		elif setter == _set_brake: InputAdapter.touch.brake = 0.0)
	add_child(b)
	return b

func _set_steer(v: float) -> void: InputAdapter.touch.steer = v
func _set_throttle(v: float) -> void: InputAdapter.touch.throttle = v
func _set_brake(v: float) -> void: InputAdapter.touch.brake = v
