class_name HopSim
extends RefCounted
## Deterministic one-button hop physics for the player bike (MOTO HOP).
## Pure logic: no rendering, no scene dependencies, fully unit-testable.

const DEFAULT_GRAVITY := 2600.0
const DEFAULT_HOP_IMPULSE := -720.0
const DEFAULT_MAX_FALL := 1100.0
const DEFAULT_ROTATION_SPEED := 6.0

## Rotation limits (radians) — friendly, never extreme.
const MAX_UP_TILT := -0.45
const MAX_DOWN_TILT := 0.55

var gravity := DEFAULT_GRAVITY
var hop_impulse := DEFAULT_HOP_IMPULSE
var max_fall_speed := DEFAULT_MAX_FALL
var rotation_speed := DEFAULT_ROTATION_SPEED

var position := Vector2.ZERO
var velocity := Vector2.ZERO
var rotation := 0.0
var distance_traveled := 0.0

func _init(p_gravity: float = DEFAULT_GRAVITY, p_hop_impulse: float = DEFAULT_HOP_IMPULSE,
		p_max_fall: float = DEFAULT_MAX_FALL) -> void:
	gravity = _safe(p_gravity, DEFAULT_GRAVITY)
	hop_impulse = _safe(p_hop_impulse, DEFAULT_HOP_IMPULSE)
	max_fall_speed = _safe(p_max_fall, DEFAULT_MAX_FALL)

## One-button hop: replaces vertical velocity for an immediate, forgiving boost.
func hop() -> void:
	velocity.y = hop_impulse

func is_falling() -> bool:
	return velocity.y > 0.0

## Advances physics deterministically. delta <= 0 is ignored (test safety).
func advance(delta: float, forward_speed: float = 0.0) -> void:
	if not is_finite(delta) or delta <= 0.0:
		return
	forward_speed = _safe(forward_speed, 0.0)
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	position.x += forward_speed * delta
	position.y += velocity.y * delta
	distance_traveled += absf(forward_speed) * delta
	# Bike tilts up while boosting and down while falling; clamped, gentle.
	var target := remap(clampf(velocity.y, hop_impulse, max_fall_speed),
		hop_impulse, max_fall_speed, MAX_UP_TILT, MAX_DOWN_TILT)
	rotation = lerpf(rotation, target, clampf(rotation_speed * delta, 0.0, 1.0))

func reset(start_position: Vector2) -> void:
	position = start_position
	velocity = Vector2.ZERO
	rotation = 0.0
	distance_traveled = 0.0

func _safe(v: float, fallback: float) -> float:
	if not is_finite(v):
		return fallback
	return v
