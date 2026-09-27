class_name Obstacle
extends Node2D
## One original Hanoi-flavored obstacle pair (MOTO HOP): a structure above and
## below a guaranteed safe gap. Themes are original procedural drawings —
## construction barriers, stacked delivery boxes, street gates.

const WIDTH := 92.0
const THEME_COUNT := 3

enum Kind { BARRIER, BOXES, GATE }

var id := -1
var gap_center := 480.0
var gap_size := 300.0
var field_top := 70.0
var field_bottom := 880.0
var theme := Kind.BARRIER
var scored := false

## Configures this (pooled) obstacle for a new spawn.
func setup(p_id: int, p_gap_center: float, p_gap_size: float, p_theme: int,
		p_field_top: float = 70.0, p_field_bottom: float = 880.0) -> void:
	id = p_id
	gap_center = p_gap_center
	gap_size = p_gap_size
	theme = wrapi(int(p_theme), 0, THEME_COUNT)
	field_top = p_field_top
	field_bottom = p_field_bottom
	scored = false
	queue_redraw()

func gap_top() -> float:
	return gap_center - gap_size * 0.5

func gap_bottom() -> float:
	return gap_center + gap_size * 0.5

## Axis-aligned collision rects for the top and bottom structures.
func get_collision_rects() -> Array:
	var x := position.x
	return [
		Rect2(x - WIDTH * 0.5, field_top - 4.0, WIDTH, gap_top() - field_top + 4.0),
		Rect2(x - WIDTH * 0.5, gap_bottom(), WIDTH, field_bottom - gap_bottom() + 4.0),
	]

## True when the player has fully passed this obstacle pair.
func has_passed(player_x: float) -> bool:
	return player_x > position.x + WIDTH * 0.5 + 10.0

func _draw() -> void:
	match theme:
		Kind.BARRIER:
			_draw_barrier()
		Kind.BOXES:
			_draw_boxes()
		_:
			_draw_gate()

func _draw_barrier() -> void:
	# Top and bottom construction barriers with friendly stripes.
	_draw_striped(gap_top(), true)
	_draw_striped(gap_bottom(), false)

func _draw_striped(edge_y: float, is_top: bool) -> void:
	var height := 999.0
	var y0 := edge_y - height if is_top else edge_y
	var y1 := edge_y if is_top else edge_y + height
	draw_rect(Rect2(-WIDTH * 0.5, y0, WIDTH, 24.0), Color(0.95, 0.75, 0.2))
	draw_rect(Rect2(-WIDTH * 0.5, y0 + (24.0 if is_top else 0.0), WIDTH,
		absf(y1 - y0) - 24.0), Color(0.35, 0.4, 0.5))
	# Diagonal hazard stripes on the edge band.
	var band := Rect2(-WIDTH * 0.5, y0 if is_top else y1 - 24.0, WIDTH, 24.0)
	var stripe_col := Color(0.25, 0.25, 0.3)
	var step := 14.0
	var x := band.position.x
	while x < band.end.x:
		var p0 := Vector2(x, band.position.y)
		var p1 := Vector2(x + 7.0, band.position.y)
		var p2 := Vector2(x + 7.0 - 12.0, band.end.y)
		var p3 := Vector2(x - 12.0, band.end.y)
		draw_colored_polygon(PackedVector2Array([p0, p1, p2, p3]), stripe_col)
		x += step
	# Danger caps at the gap edges.
	draw_rect(Rect2(-WIDTH * 0.5 - 4.0, (y0 if is_top else y1 - 8.0), WIDTH + 8.0, 8.0),
		Color(0.9, 0.3, 0.25))

func _draw_boxes() -> void:
	# Stacked delivery boxes with a friendly sign board at the gap edge.
	_draw_box_stack(gap_top(), true)
	_draw_box_stack(gap_bottom(), false)

func _draw_box_stack(edge_y: float, is_top: bool) -> void:
	var colors := [Color(0.87, 0.62, 0.35), Color(0.78, 0.5, 0.3), Color(0.95, 0.72, 0.45)]
	var box_w := WIDTH * 0.9
	var box_h := 34.0
	var span := absf(edge_y - field_top) if is_top else absf(field_bottom - edge_y)
	var count := clampi(int(ceil(span / box_h)), 1, 40)
	for i in range(count):
		var cy := edge_y - box_h * (i + 0.5) if is_top else edge_y + box_h * (i + 0.5)
		var c: Color = colors[i % colors.size()]
		draw_rect(Rect2(-box_w * 0.5, cy - box_h * 0.5, box_w, box_h - 3.0), c)
		draw_rect(Rect2(-box_w * 0.5, cy - box_h * 0.5, box_w, 5.0), c.darkened(0.2))
	# Tape band at the gap edge.
	draw_rect(Rect2(-box_w * 0.5 - 3.0, edge_y - (4.0 if is_top else 0.0), box_w + 6.0, 4.0),
		Color(0.9, 0.3, 0.25))

func _draw_gate() -> void:
	# Street gate: posts + sign board + hanging lantern-ish lamp (original).
	for side in [true, false]:
		var edge_y := gap_top() if side else gap_bottom()
		var y0 := field_top - 4.0 if side else edge_y
		var y1 := edge_y if side else field_bottom + 4.0
		draw_rect(Rect2(-WIDTH * 0.5 - 8.0, y0, 16.0, y1 - y0), Color(0.55, 0.3, 0.25))
		draw_rect(Rect2(WIDTH * 0.5 - 8.0, y0, 16.0, y1 - y0), Color(0.55, 0.3, 0.25))
		draw_rect(Rect2(-WIDTH * 0.5, y0, WIDTH, y1 - y0), Color(0.96, 0.9, 0.8))
		# Sign board near the gap edge.
		var sb := Rect2(-WIDTH * 0.5, edge_y - 34.0 if side else edge_y, WIDTH, 30.0)
		draw_rect(sb, Color(0.2, 0.55, 0.5))
		draw_rect(Rect2(sb.position.x + 8.0, sb.position.y + 8.0, sb.size.x - 16.0, 6.0),
			Color(0.95, 0.95, 0.9))
		draw_rect(Rect2(sb.position.x + 8.0, sb.position.y + 18.0, sb.size.x - 28.0, 4.0),
			Color(0.8, 0.9, 0.88))
