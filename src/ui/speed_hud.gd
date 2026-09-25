extends CanvasLayer
## Minimal vertical-slice HUD: speedometer + control hints.

var bike: Node
var _label: Label

func _ready() -> void:
	_layer_name()

func _layer_name() -> void:
	var panel := PanelContainer.new()
	panel.name = "SpeedPanel"
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	_label = Label.new()
	_label.name = "SpeedLabel"
	_label.text = "0 km/h"
	margin.add_child(_label)
	panel.add_child(margin)
	add_child(panel)
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	var hints := Label.new()
	hints.name = "Hints"
	hints.text = "W/Up throttle - S/Down brake - A/D steer - R reset\nGamepad: left stick + A/B/Y"
	hints.position = Vector2(12, 8)
	add_child(hints)

func bind_bike(p_bike: Node) -> void:
	bike = p_bike
	if bike and bike.has_signal("speed_changed"):
		bike.speed_changed.connect(_on_speed_changed)

func _on_speed_changed(kmh: float) -> void:
	if _label:
		_label.text = "%d km/h" % int(round(kmh))
