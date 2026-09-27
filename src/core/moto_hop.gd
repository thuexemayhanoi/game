class_name MotoHop
extends Node2D
## MOTO HOP game controller. Owns the bike, obstacle manager, background,
## HUD, menu and audio; drives BOOT → MENU → READY → PLAYING → PAUSED →
## GAME_OVER. Gameplay logic (HopSim, ObstacleGenerator, DifficultyManager,
## ScoreManager) is pure and unit-tested; this node wires it to presentation.

const READY_STEPS := [3, 2, 1, 0]  # 0 == GO!
const STEP_TIME := 0.65

var bike: PlayerBike
var obstacles: ObstacleManager
var background: CityParallax
var hud: MotoHud
var menu: MotoMenu
var score_manager := ScoreManager.new()
var save_data: Dictionary = {}

var _ready_timer := 0.0
var _ready_index := 0

func _ready() -> void:
	_load_save()
	background = CityParallax.new()
	background.name = "Background"
	add_child(background)
	obstacles = ObstacleManager.new()
	obstacles.name = "Obstacles"
	add_child(obstacles)
	bike = PlayerBike.new()
	bike.name = "PlayerBike"
	add_child(bike)
	hud = MotoHud.new()
	hud.name = "HUD"
	add_child(hud)
	menu = MotoMenu.new()
	menu.name = "Menu"
	add_child(menu)
	_wire()
	_apply_save_to_state()
	GameState.set_state(GameState.State.MENU)
	_refresh_menu()

func _wire() -> void:
	menu.play_pressed.connect(func() -> void: start_game())
	menu.home_pressed.connect(func() -> void: go_home())
	hud.pause_pressed.connect(func() -> void: toggle_pause())
	hud.mute_pressed.connect(func() -> void: toggle_mute())
	EventBus.score_changed.connect(func(score: int) -> void: hud.set_score(score))
	EventBus.best_changed.connect(func(_best: int) -> void: hud.set_best(GameState.best_score))
	EventBus.milestone_reached.connect(func(_m: int) -> void: _celebrate())
	EventBus.hop_performed.connect(func() -> void: AudioManager.play_hop())
	EventBus.crashed.connect(func() -> void: _on_crash())

func _load_save() -> void:
	save_data = SaveManager.load_from_disk()
	GameState.best_score = int(save_data.get("arcade", {}).get("best_score", 0))
	GameState.coins = int(save_data.get("wallet", {}).get("coins", 0))
	GameState.muted = bool(save_data.get("settings", {}).get("muted", false))

func _apply_save_to_state() -> void:
	hud.set_best(GameState.best_score)
	hud.set_muted(GameState.muted)
	AudioManager.set_muted(GameState.muted)

func _save_progress() -> void:
	save_data["arcade"]["best_score"] = GameState.best_score
	save_data["wallet"]["coins"] = GameState.coins
	save_data["settings"]["muted"] = GameState.muted
	save_data["statistics"]["games_played"] = int(save_data.get("statistics", {}).get("games_played", 0)) + 1
	save_data["statistics"]["total_score"] = int(save_data.get("statistics", {}).get("total_score", 0)) + GameState.score
	save_data["statistics"]["obstacles_passed"] = int(save_data.get("statistics", {}).get("obstacles_passed", 0)) + score_manager.score
	SaveManager.save_to_disk(save_data)

func _process(delta: float) -> void:
	if InputManager.mute_requested():
		toggle_mute()
	match GameState.current_state:
		GameState.State.MENU:
			if InputManager.hop_requested():
				start_game()
		GameState.State.READY:
			_step_ready(delta)
		GameState.State.PLAYING:
			_step_playing(delta)
		_:
			pass

func _unhandled_input(event: InputEvent) -> void:
	# One-button controls: tap anywhere (touch) or left-click to hop.
	if not (event is InputEventScreenTouch or event is InputEventMouseButton):
		return
	var pressed := false
	if event is InputEventScreenTouch:
		pressed = event.pressed and event.index == 0
	elif event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not pressed:
		return
	match GameState.current_state:
		GameState.State.PLAYING:
			bike.hop()
		GameState.State.MENU:
			start_game()
		_:
			pass

## Round lifecycle -----------------------------------------------------------

func start_game() -> void:
	# Fast restart: everything is reset in place; the browser page never reloads.
	score_manager.reset()
	GameState.reset_session()
	hud.set_score(0)
	obstacles.reset()
	bike.reset()
	_ready_timer = STEP_TIME
	_ready_index = -1
	GameState.set_state(GameState.State.READY)
	menu.hide_all()
	hud.set_visible_during_play(true)

func _step_ready(delta: float) -> void:
	_ready_timer -= delta
	if _ready_timer <= 0.0:
		_ready_index += 1
		if _ready_index >= READY_STEPS.size():
			GameState.set_state(GameState.State.PLAYING)
			hud.set_visible_during_play(true)
			menu.hide_all()
			return
		menu.show_ready_step(READY_STEPS[_ready_index])
		_ready_timer = STEP_TIME

func _step_playing(delta: float) -> void:
	var params := obstacles.difficulty.get_params(GameState.score)
	var result := bike.step(delta, params["scroll_speed"])
	if result == "crashed":
		return
	background.step(params["scroll_speed"] * delta)
	var passed := obstacles.step(delta, params, bike.sim.position.x)
	for id in passed:
		var milestone := score_manager.register_pass(id)
		GameState.add_score(1)
		if milestone > 0:
			EventBus.milestone_reached.emit(milestone)
	if obstacles.check_collision(bike.get_collision_circle()):
		bike.crashed = true
		_on_crash()

func _on_crash() -> void:
	if not GameState.set_state(GameState.State.GAME_OVER):
		return
	AudioManager.play_crash()
	GameState.record_game_over()
	hud.set_best(GameState.best_score)
	menu.show_game_over(GameState.score, GameState.best_score)
	_save_progress()

func toggle_pause() -> void:
	if GameState.current_state == GameState.State.PLAYING:
		GameState.set_state(GameState.State.PAUSED)
		menu.show_pause()
	elif GameState.current_state == GameState.State.PAUSED:
		GameState.set_state(GameState.State.PLAYING)
		menu.hide_all()

func toggle_mute() -> void:
	GameState.muted = not GameState.muted
	AudioManager.set_muted(GameState.muted)
	hud.set_muted(GameState.muted)
	save_data["settings"]["muted"] = GameState.muted
	SaveManager.save_to_disk(save_data)

func go_home() -> void:
	if GameState.set_state(GameState.State.MENU):
		obstacles.reset()
		bike.reset()
		_refresh_menu()

func _refresh_menu() -> void:
	menu.show_menu(GameState.best_score)
	hud.set_visible_during_play(false)

func _celebrate() -> void:
	# Lightweight milestone feedback: sound + score pop; never blocks gameplay.
	AudioManager.play_milestone()
	hud.set_score(GameState.score)
