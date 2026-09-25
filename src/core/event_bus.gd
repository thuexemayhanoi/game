extends Node
## Global event bus autoload. Systems communicate through signals only.

signal game_state_changed()
signal bike_reset(position: Vector3)
signal speed_changed(kmh: float)
