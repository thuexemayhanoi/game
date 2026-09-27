class_name ObstacleGenerator
extends RefCounted
## Deterministic, seeded obstacle placement (MOTO HOP). Pure logic.
## Guarantees a possible route: every gap fits inside the play field with margin.

const DEFAULT_SEED := 20260927

var rng := RandomNumberGenerator.new()
var field_top := 70.0
var field_bottom := 880.0
## Safety margin so gaps never hug the screen edges.
const EDGE_MARGIN := 46.0

func _init(seed_value: int = DEFAULT_SEED, p_field_top: float = 70.0, p_field_bottom: float = 880.0) -> void:
	rng.seed = seed_value
	field_top = maxf(0.0, p_field_top)
	field_bottom = maxf(field_top + 1.0, p_field_bottom)

## Generates the next gap placement for the given difficulty params.
## Returns {"gap_center": float, "gap_size": float}.
func generate(params: Dictionary) -> Dictionary:
	var gap_size := maxf(float(params.get("gap", 300.0)), 10.0)
	var half := gap_size * 0.5
	var lowest := field_top + half + EDGE_MARGIN
	var highest := field_bottom - half - EDGE_MARGIN
	# Defensive: if a (misconfigured) gap cannot fit, shrink it to the largest
	# size that fits instead of ever producing an impossible obstacle.
	if lowest > highest:
		gap_size = (field_bottom - field_top) - 2.0 * EDGE_MARGIN
		half = gap_size * 0.5
		lowest = field_top + half
		highest = field_bottom - half
	var center := rng.randf_range(lowest, highest)
	return {"gap_center": center, "gap_size": gap_size}

## True when a generated placement leaves a passable corridor.
static func is_passable(placement: Dictionary, p_field_top: float, p_field_bottom: float) -> bool:
	var center := float(placement.get("gap_center", -1.0))
	var size := float(placement.get("gap_size", 0.0))
	if not is_finite(center) or not is_finite(size) or size <= 0.0:
		return false
	return center - size * 0.5 >= p_field_top and center + size * 0.5 <= p_field_bottom

func reseed(seed_value: int) -> void:
	rng.seed = seed_value
