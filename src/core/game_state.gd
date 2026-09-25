extends Node
## Autoload: GameState. Global game settings, quality profile, session helpers.
## Kept intentionally small: gameplay systems live in their own modules.

signal settings_changed(key: String, value: Variant)

const DEFAULT_SETTINGS := {
	"master_volume": 0.8,
	"music_volume": 0.6,
	"sfx_volume": 0.8,
	"ui_volume": 0.7,
	"quality_profile": "MEDIUM",
	"camera_shake": true,
	"vibration": true,
	"ui_scale": 1.0,
	"text_scale": 1.0,
}

var settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)
var session := {"play_time": 0.0, "distance_ridden": 0.0}

func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	settings_changed.emit(key, value)

func get_setting(key: String, fallback: Variant = null) -> Variant:
	return settings.get(key, fallback)

func reset_settings() -> void:
	settings = DEFAULT_SETTINGS.duplicate(true)
	settings_changed.emit("all", null)
