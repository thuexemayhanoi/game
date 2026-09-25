extends CanvasLayer
## Touch overlay: throttle, brake, left/right steer, reset. Shown only in touch mode.
## Buttons are generated in code — no textures required, no duplicated scenes.

func _ready() -> void:
	if not InputAdapter.is_touch_device():
		queue_free()
		return
	_build()

func _build() -> void:
	_make_button("◀", Vector2(-190, -90), Callable(self, "_set_steer"), -1.0)
	_make_button("▶", Vector2(-100, -90), Callable(self, "_set_steer"), 1.0)
	_make_button("BRAKE", Vector2(-190, -180), Callable(self, "_set_brake"), 1.0)
	_make_button("GO", Vector2(-100, -180), Callable(self, "_set_throttle"), 1.0)
	var reset := _make_button("RESET", Vector2(20, -70), Callable(), 0.0)
	reset.pressed.connect(_on_reset)

func _make_button(text: String, offset: Vector2, setter: Callable, value: float) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(80, 80)
	b.anchor_left = 1.0
	b.anchor_top = 1.0
	b.anchor_right = 1.0
	b.anchor_bottom = 1.0
	b.offset_left = offset.x
	b.offset_top = offset.y
	b.offset_right = offset.x + 84
	b.offset_bottom = offset.y + 84
	if setter.is_valid():
		b.button_down.connect(_on_down.bind(setter, value))
		b.button_up.connect(_on_up.bind(setter))
	add_child(b)
	return b

func _on_down(setter: Callable, value: float) -> void:
	setter.call(value)

func _on_up(setter: Callable) -> void:
	if setter == Callable(self, "_set_steer"):
		InputAdapter.touch.steer = 0.0
	elif setter == Callable(self, "_set_throttle"):
		InputAdapter.touch.throttle = 0.0
	elif setter == Callable(self, "_set_brake"):
		InputAdapter.touch.brake = 0.0

func _on_reset() -> void:
	InputAdapter.touch.reset = true
	await get_tree().create_timer(0.1).timeout
	InputAdapter.touch.reset = false

func _set_steer(v: float) -> void: InputAdapter.touch.steer = v
func _set_throttle(v: float) -> void: InputAdapter.touch.throttle = v
func _set_brake(v: float) -> void: InputAdapter.touch.brake = v
