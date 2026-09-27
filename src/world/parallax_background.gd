class_name CityParallax
extends Node2D
## Original bright daytime Hanoi-inspired parallax background (MOTO HOP).
## All layers are procedural drawings; no external assets. Layers scroll at
## different factors for depth; the road scrolls with gameplay.

const VIEW_WIDTH := 540.0
const GROUND_Y := 880.0

class Strip extends Node2D:
	enum Kind { SKYLINE, BUILDINGS, TREES, ROAD }
	var kind: int = Kind.SKYLINE
	var factor := 0.2
	var offset := 0.0
	var palette_seed := 1

	func _draw() -> void:
		var tile_w := VIEW_WIDTH
		var tiles := 2
		for t in range(tiles):
			var base_x := -tile_w + t * tile_w + fmod(offset, tile_w)
			match kind:
				Kind.SKYLINE:
					_draw_skyline(base_x, tile_w)
				Kind.BUILDINGS:
					_draw_buildings(base_x, tile_w)
				Kind.TREES:
					_draw_trees(base_x, tile_w)
				Kind.ROAD:
					_draw_road(base_x, tile_w)

	func _hash(i: int, s: int) -> float:
		return fmod(sin(float(i * 127 + s * 311) * 43758.5453), 1.0) * 0.5 + 0.5

	func _draw_skyline(base_x: float, tile_w: float) -> void:
		var color := Color(0.62, 0.78, 0.88)
		var count := 9
		for i in range(count):
			var w := tile_w / count
			var h := 90.0 + _hash(i, palette_seed) * 120.0
			var x := base_x + i * w
			draw_rect(Rect2(x, GROUND_Y - 420.0 - h, w * 0.85, h), color)
			draw_rect(Rect2(x + w * 0.2, GROUND_Y - 420.0 - h - 20.0, w * 0.45, 22.0), color.darkened(0.05))

	func _draw_buildings(base_x: float, tile_w: float) -> void:
		var color := Color(0.93, 0.72, 0.62)
		var roof := Color(0.85, 0.4, 0.35)
		var count := 7
		for i in range(count):
			var w := tile_w / count
			var h := 150.0 + _hash(i + 40, palette_seed) * 170.0
			var x := base_x + i * w
			draw_rect(Rect2(x, GROUND_Y - h, w * 0.9, h), color)
			draw_rect(Rect2(x, GROUND_Y - h - 14.0, w * 0.9, 14.0), roof)
			for r in range(3):
				draw_rect(Rect2(x + 6.0, GROUND_Y - h + 16.0 + r * 30.0, w * 0.9 - 12.0, 14.0),
					Color(0.75, 0.85, 0.9))

	func _draw_trees(base_x: float, tile_w: float) -> void:
		var trunk := Color(0.45, 0.32, 0.2)
		var leaf := Color(0.36, 0.7, 0.35)
		var count := 6
		for i in range(count):
			var x := base_x + i * (tile_w / count) + 12.0
			var h := 110.0 + _hash(i + 90, palette_seed) * 50.0
			draw_rect(Rect2(x, GROUND_Y - h, 10.0, h), trunk)
			draw_circle(Vector2(x + 5.0, GROUND_Y - h), 26.0 + _hash(i, palette_seed) * 8.0, leaf)
			# Street lamp between trees.
			if i % 2 == 0:
				draw_line(Vector2(x + 30.0, GROUND_Y), Vector2(x + 30.0, GROUND_Y - 80.0),
					Color(0.4, 0.42, 0.5), 4.0)
				draw_circle(Vector2(x + 30.0, GROUND_Y - 84.0), 6.0, Color(1.0, 0.92, 0.5))

	func _draw_road(base_x: float, tile_w: float) -> void:
		draw_rect(Rect2(base_x, GROUND_Y, tile_w, 120.0), Color(0.42, 0.44, 0.5))
		var dash := Rect2(base_x + 20.0, GROUND_Y + 62.0, 36.0, 8.0)
		var x := dash.position.x
		while x < base_x + tile_w:
			draw_rect(Rect2(x, GROUND_Y + 62.0, 36.0, 8.0), Color(1.0, 0.95, 0.7))
			x += 72.0

var _strips: Array[Strip] = []

func _ready() -> void:
	add_child(_make_strip(Strip.Kind.SKYLINE, 0.15, 11))
	add_child(_make_strip(Strip.Kind.BUILDINGS, 0.35, 22))
	add_child(_make_strip(Strip.Kind.TREES, 0.65, 33))
	add_child(_make_strip(Strip.Kind.ROAD, 1.0, 44))

func _make_strip(kind: int, factor: float, seed_value: int) -> Strip:
	var s := Strip.new()
	s.kind = kind
	s.factor = factor
	s.palette_seed = seed_value
	s.name = "Strip" + str(_strips.size())
	_strips.append(s)
	return s

## Scrolls every layer by the gameplay scroll distance for this frame.
func step(scroll_delta: float) -> void:
	for s in _strips:
		s.offset += scroll_delta * s.factor
		s.queue_redraw()
