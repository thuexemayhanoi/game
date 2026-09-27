extends Node
## Global arcade session state autoload (MOTO HOP). UI-free, headless-testable.
## Persistent data goes through the versioned SaveManager (see src/data/save_schema.json).

## Strict, testable game states. Transitions are validated; illegal changes are rejected.
enum State { BOOT, MENU, READY, PLAYING, PAUSED, GAME_OVER }

const SAVE_VERSION := 2

signal state_changed(new_state: int, old_state: int)

const VALID_TRANSITIONS := {
	State.BOOT: [State.MENU],
	State.MENU: [State.READY],
	State.READY: [State.PLAYING, State.MENU],
	State.PLAYING: [State.PAUSED, State.GAME_OVER],
	State.PAUSED: [State.PLAYING, State.MENU],
	State.GAME_OVER: [State.READY, State.MENU],
}

var current_state: int = State.BOOT
var score := 0
var best_score := 0
var coins := 0
var muted := false

func set_state(new_state: int) -> bool:
	if new_state == current_state:
		return false
	if not VALID_TRANSITIONS.get(current_state, []).has(new_state):
		return false
	var old := current_state
	current_state = new_state
	state_changed.emit(new_state, old)
	EventBus.state_changed.emit(new_state, old)
	return true

func can_go_to(new_state: int) -> bool:
	return VALID_TRANSITIONS.get(current_state, []).has(new_state)

## Adds points only while actually playing — never during menus or pause.
func add_score(points := 1) -> void:
	if points > 0 and current_state == State.PLAYING:
		score += points
		EventBus.score_changed.emit(score)

## Resets per-run values (score). Best score is persistent, never reset here.
func reset_session() -> void:
	score = 0
	EventBus.score_changed.emit(score)

## Called once at game over; promotes the best score and notifies listeners.
func record_game_over() -> void:
	if score > best_score:
		best_score = score
		EventBus.best_changed.emit(best_score)

func to_dict() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"best_score": best_score,
		"coins": coins,
		"muted": muted,
	}

func from_dict(d: Dictionary) -> void:
	var v = d.get("best_score", 0)
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		best_score = max(0, int(v))
	v = d.get("coins", 0)
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		coins = max(0, int(v))
	var m = d.get("muted", false)
	if typeof(m) == TYPE_BOOL:
		muted = m
		EventBus.mute_changed.emit(muted)
