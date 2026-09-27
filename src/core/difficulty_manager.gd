class_name DifficultyManager
extends RefCounted
## Data-driven difficulty (MOTO HOP). Tiers load from res://src/data/difficulty.json.
## Every parameter is sanitized and capped so difficulty can never become
## impossible: the minimum gap always exceeds the bike's collision size.

const DATA_PATH := "res://src/data/difficulty.json"

## Hard safety bounds (virtual pixels at 540x960 base resolution).
const MIN_GAP := 200.0
const MAX_GAP := 400.0
const MIN_SPEED := 120.0
const MAX_SPEED := 400.0
const MIN_SPACING := 280.0
const MAX_SPACING := 620.0

var tiers: Array = []

func _init(p_tiers: Array = []) -> void:
	if p_tiers.is_empty():
		tiers = load_tiers()
	else:
		tiers = p_tiers

## Parses the JSON difficulty config; falls back to built-in defaults on error.
static func load_tiers() -> Array:
	var fallback := default_tiers()
	if not FileAccess.file_exists(DATA_PATH):
		return fallback
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("tiers")) != TYPE_ARRAY:
		return fallback
	var out: Array = []
	for entry in parsed["tiers"]:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var t := sanitize_tier(entry)
		if t.get("min_score", -1) >= 0:
			out.append(t)
	if out.is_empty():
		return fallback
	out.sort_custom(func(a, b): return int(a["min_score"]) < int(b["min_score"]))
	return out

static func default_tiers() -> Array:
	return [
		{"min_score": 0, "scroll_speed": 180.0, "gap": 320.0, "spacing": 380.0},
		{"min_score": 10, "scroll_speed": 210.0, "gap": 290.0, "spacing": 350.0},
		{"min_score": 25, "scroll_speed": 240.0, "gap": 265.0, "spacing": 320.0},
		{"min_score": 50, "scroll_speed": 280.0, "gap": 240.0, "spacing": 300.0},
		{"min_score": 100, "scroll_speed": 320.0, "gap": 220.0, "spacing": 290.0},
		{"min_score": 200, "scroll_speed": 340.0, "gap": 210.0, "spacing": 280.0},
	]

## Clamps one raw tier dictionary into safe, playable values.
## Invalid/negative numbers are treated as 0 and clamped to the safe minimum,
## so a misconfigured JSON can never make the game impossible.
static func sanitize_tier(t: Dictionary) -> Dictionary:
	return {
		"min_score": max(0, int(t.get("min_score", 0))),
		"scroll_speed": clampf(_raw_num(t, "scroll_speed", 180.0), MIN_SPEED, MAX_SPEED),
		"gap": clampf(_raw_num(t, "gap", 320.0), MIN_GAP, MAX_GAP),
		"spacing": clampf(_raw_num(t, "spacing", 380.0), MIN_SPACING, MAX_SPACING),
	}

static func _raw_num(t: Dictionary, key: String, fallback: float) -> float:
	var v = t.get(key, fallback)
	if typeof(v) != TYPE_FLOAT and typeof(v) != TYPE_INT:
		return fallback
	var f := float(v)
	if not is_finite(f):
		return fallback
	return f

## Effective parameters for a score. Scores above the last tier stay capped.
func get_params(score: int) -> Dictionary:
	var chosen: Dictionary = tiers[0] if not tiers.is_empty() else sanitize_tier({})
	for t in tiers:
		if score >= int(t["min_score"]):
			chosen = t
	return {
		"scroll_speed": float(chosen.get("scroll_speed", 180.0)),
		"gap": float(chosen.get("gap", 320.0)),
		"spacing": float(chosen.get("spacing", 380.0)),
	}

static func _num(t: Dictionary, key: String, fallback: float) -> float:
	var v = t.get(key, fallback)
	if typeof(v) != TYPE_FLOAT and typeof(v) != TYPE_INT:
		return fallback
	var f := float(v)
	if not is_finite(f) or f <= 0.0:
		return fallback
	return f
