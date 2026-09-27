class_name MotoHud
extends CanvasLayer
## In-game HUD (MOTO HOP): big centered score, best score, pause + mute buttons.
## Large touch targets; readable outdoors; responsive from 320px width.

signal pause_pressed
signal mute_pressed

var score_label: Label
var best_label: Label
var pause_button: Button
var mute_button: Button
var _pop := 0.0

func _ready() -> void:
	layer = 10
	score_label = _make_label("0", 64, Color(1.0, 1.0, 1.0))
	score_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	score_label.offset_left = -160.0
	score_label.offset_right = 160.0
	score_label.offset_top = 26.0
	score_label.offset_bottom = 116.0
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(score_label)

	best_label = _make_label("BEST 0", 22, Color(1.0, 0.95, 0.6))
	best_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	best_label.offset_left = -160.0
	best_label.offset_right = 160.0
	best_label.offset_top = 116.0
	best_label.offset_bottom = 148.0
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(best_label)

	pause_button = _make_button("II", 72.0)
	pause_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -92.0
	pause_button.offset_right = -16.0
	pause_button.offset_top = 16.0
	pause_button.offset_bottom = 88.0
	pause_button.pressed.connect(_on_pause)
	add_child(pause_button)

	mute_button = _make_button("M", 72.0)
	mute_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	mute_button.offset_left = -176.0
	mute_button.offset_right = -100.0
	mute_button.offset_top = 16.0
	mute_button.offset_bottom = 88.0
	mute_button.pressed.connect(_on_mute)
	add_child(mute_button)

func _process(delta: float) -> void:
	if _pop > 0.0:
		_pop = maxf(_pop - delta * 4.0, 0.0)
		var s := 1.0 + _pop * 0.25
		score_label.scale = Vector2(s, s)

func set_score(score: int) -> void:
	score_label.text = str(score)
	_pop = 1.0

func set_best(best: int) -> void:
	best_label.text = "BEST " + str(best)

func set_muted(muted: bool) -> void:
	mute_button.text = "M" if muted else "M"
	mute_button.modulate = Color(1, 1, 0.6, 1.0) if muted else Color(1, 1, 1, 1.0)

func set_visible_during_play(playing: bool) -> void:
	pause_button.visible = playing
	mute_button.visible = true
	score_label.visible = playing or _pop > 0.0
	best_label.visible = playing

func _on_pause() -> void:
	EventBus.button_clicked.emit()
	pause_pressed.emit()

func _on_mute() -> void:
	mute_button.text = "M"
	mute_pressed.emit()

func _make_label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.1, 0.15, 0.25, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _make_button(text: String, min_size: float) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(min_size, min_size)
	btn.add_theme_font_size_override("font_size", 30)
	btn.focus_mode = Control.FOCUS_NONE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(1, 1, 1, 0.35)
	st.set_corner_radius_all(20)
	var stp := StyleBoxFlat.new()
	stp.bg_color = Color(1, 1, 1, 0.6)
	stp.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("pressed", stp)
	return btn
