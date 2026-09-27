class_name MotoMenu
extends CanvasLayer
## Screens (MOTO HOP): MENU (title, best, PLAY, hint), READY countdown
## (3 2 1 GO!), GAME OVER (score, best, PLAY AGAIN, HOME) and a PAUSE panel.
## Everything is code-built, responsive, and safe-area friendly.

signal play_pressed
signal home_pressed

var root: Control
var panel: ColorRect
var title_label: Label
var best_label: Label
var big_label: Label
var score_label: Label
var play_button: Button
var again_button: Button
var home_button: Button
var hint_label: Label

func _ready() -> void:
	layer = 20
	_build()
	_show_menu()

func _build() -> void:
	root = Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	panel = ColorRect.new()
	panel.name = "Panel"
	panel.color = Color(0.08, 0.14, 0.3, 0.0)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(panel)

	title_label = _make_label("MOTO HOP", 58, Color(1.0, 0.45, 0.2))
	title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title_label.offset_left = -250.0
	title_label.offset_right = 250.0
	title_label.offset_top = 120.0
	title_label.offset_bottom = 200.0
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title_label)

	best_label = _make_label("Best Score: 0", 30, Color(1.0, 0.95, 0.6))
	best_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	best_label.offset_left = -250.0
	best_label.offset_right = 250.0
	best_label.offset_top = 210.0
	best_label.offset_bottom = 260.0
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(best_label)

	hint_label = _make_label("Tap / Space to Hop", 26, Color(0.95, 0.95, 1.0))
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hint_label.offset_left = -250.0
	hint_label.offset_right = 250.0
	hint_label.offset_top = -150.0
	hint_label.offset_bottom = -100.0
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hint_label)

	big_label = _make_label("3", 120, Color(1.0, 1.0, 1.0))
	big_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	big_label.offset_left = -200.0
	big_label.offset_right = 200.0
	big_label.offset_top = -120.0
	big_label.offset_bottom = 120.0
	big_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	big_label.visible = false
	root.add_child(big_label)

	score_label = _make_label("Score: 0", 44, Color(1.0, 1.0, 1.0))
	score_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	score_label.offset_left = -250.0
	score_label.offset_right = 250.0
	score_label.offset_top = -170.0
	score_label.offset_bottom = -110.0
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.visible = false
	root.add_child(score_label)

	play_button = _make_button("PLAY", 300.0)
	play_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	play_button.offset_left = -150.0
	play_button.offset_right = 150.0
	play_button.offset_top = -40.0
	play_button.offset_bottom = 60.0
	play_button.pressed.connect(func() -> void:
		EventBus.button_clicked.emit()
		play_pressed.emit())
	root.add_child(play_button)

	again_button = _make_button("PLAY AGAIN", 320.0)
	again_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	again_button.offset_left = -160.0
	again_button.offset_right = 160.0
	again_button.offset_top = -30.0
	again_button.offset_bottom = 70.0
	again_button.pressed.connect(func() -> void:
		EventBus.button_clicked.emit()
		play_pressed.emit())
	again_button.visible = false
	root.add_child(again_button)

	home_button = _make_button("HOME", 320.0)
	home_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	home_button.offset_left = -160.0
	home_button.offset_right = 160.0
	home_button.offset_top = 90.0
	home_button.offset_bottom = 170.0
	home_button.pressed.connect(func() -> void:
		EventBus.button_clicked.emit()
		home_pressed.emit())
	home_button.visible = false
	root.add_child(home_button)

func set_best(best: int) -> void:
	best_label.text = "Best Score: " + str(best)

func show_ready_step(step: int) -> void:
	_hide_all()
	big_label.visible = true
	big_label.text = str(step) if step > 0 else "GO!"

func show_menu(best: int) -> void:
	_hide_all()
	set_best(best)
	title_label.visible = true
	best_label.visible = true
	play_button.visible = true
	hint_label.visible = true
	panel.color = Color(0.08, 0.14, 0.3, 0.25)

func show_game_over(score: int, best: int) -> void:
	_hide_all()
	title_label.text = "GAME OVER"
	title_label.visible = true
	score_label.text = "Score: " + str(score)
	if score >= best:
		score_label.text = "Score: " + str(score) + "  —  New Best!"
	score_label.visible = true
	best_label.text = "Best Score: " + str(best)
	best_label.visible = true
	again_button.visible = true
	home_button.visible = true
	hint_label.visible = true
	panel.color = Color(0.08, 0.14, 0.3, 0.45)

func show_pause() -> void:
	_hide_all()
	title_label.text = "PAUSED"
	title_label.visible = true
	again_button.text = "RESUME"
	again_button.visible = true
	home_button.visible = true
	panel.color = Color(0.08, 0.14, 0.3, 0.45)

func hide_all() -> void:
	_hide_all()
	panel.color = Color(0.08, 0.14, 0.3, 0.0)

func _show_menu() -> void:
	_hide_all()

func _hide_all() -> void:
	for n in [title_label, best_label, big_label, score_label, play_button,
			again_button, home_button, hint_label]:
		n.visible = false
	again_button.text = "PLAY AGAIN"

func _make_label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.1, 0.15, 0.25, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _make_button(text: String, min_width: float) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(min_width, 72.0)
	btn.add_theme_font_size_override("font_size", 34)
	btn.focus_mode = Control.FOCUS_NONE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(1.0, 0.45, 0.2)
	st.set_corner_radius_all(24)
	var stp := StyleBoxFlat.new()
	stp.bg_color = Color(1.0, 0.6, 0.3)
	stp.set_corner_radius_all(24)
	var sth := StyleBoxFlat.new()
	sth.bg_color = Color(0.9, 0.4, 0.18)
	sth.set_corner_radius_all(24)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("pressed", stp)
	btn.add_theme_stylebox_override("hover", sth)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_outline_color", Color(0.35, 0.12, 0.05, 0.6))
	btn.add_theme_constant_override("outline_size", 5)
	return btn
