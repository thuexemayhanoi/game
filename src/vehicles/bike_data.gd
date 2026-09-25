class_name BikeData
extends Resource
## Data-driven bike stats, loaded from res://src/data/bikes.json.

@export var id := "scooter_default"
@export var display_name := "City Scooter"
@export var category := "scooter"
@export var max_speed := 30.0
@export var acceleration := 8.0
@export var brake_force := 14.0
@export var turn_rate := 2.2

static func from_dict(d: Dictionary) -> BikeData:
	var b := BikeData.new()
	if typeof(d.get("id")) == TYPE_STRING and not String(d["id"]).is_empty():
		b.id = String(d["id"])
	if typeof(d.get("display_name")) == TYPE_STRING:
		b.display_name = String(d["display_name"])
	if typeof(d.get("category")) == TYPE_STRING:
		b.category = String(d["category"])
	b.max_speed = _pos(d, "max_speed", b.max_speed)
	b.acceleration = _pos(d, "acceleration", b.acceleration)
	b.brake_force = _pos(d, "brake_force", b.brake_force)
	b.turn_rate = _pos(d, "turn_rate", b.turn_rate)
	return b

static func load_all() -> Array:
	var path := "res://src/data/bikes.json"
	if not FileAccess.file_exists(path):
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_ARRAY:
		return []
	var out: Array = []
	for entry in parsed:
		if typeof(entry) == TYPE_DICTIONARY:
			out.append(BikeData.from_dict(entry))
	return out

static func load_by_id(bike_id: String) -> BikeData:
	for b in BikeData.load_all():
		if b.id == bike_id:
			return b
	return null

static func load_default() -> BikeData:
	var all := BikeData.load_all()
	if all.size() > 0:
		return all[0]
	return BikeData.new()

static func _pos(d: Dictionary, key: String, fallback: float) -> float:
	var v = d.get(key, fallback)
	if typeof(v) != TYPE_FLOAT and typeof(v) != TYPE_INT:
		return fallback
	var f := float(v)
	if not is_finite(f) or f <= 0.0:
		return fallback
	return f
