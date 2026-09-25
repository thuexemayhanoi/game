class_name BikeHud
extends CanvasLayer
## Minimal HUD: title and speedometer (km/h). Mobile-responsive via anchors.

var bike: Motorbike
var title_label: Label
var speed_label: Label

func _ready() -> void:
	layer = 10
	title_label = _make_label("HANOI RIDER", 26, Color(1, 0.85, 0.3))
	title_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	title_label.offset_left = 16.0
	title_label.offset_top = 12.0
	title_label.offset_right = 420.0
	title_label.offset_bottom = 56.0
	add_child(title_label)
	speed_label = _make_label("0 km/h", 32, Color(1, 1, 1))
	speed_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	speed_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	speed_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	speed_label.offset_left = -280.0
	speed_label.offset_top = -76.0
	speed_label.offset_right = -16.0
	speed_label.offset_bottom = -16.0
	add_child(speed_label)

func _process(_delta: float) -> void:
	if bike != null and is_instance_valid(bike):
		speed_label.text = str(int(round(bike.get_speed_kmh()))) + " km/h"
	else:
		speed_label.text = "0 km/h"

func _make_label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 6)
	return l
