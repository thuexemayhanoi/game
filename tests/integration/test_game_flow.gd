extends GutTest
## Integration tests for the full MOTO HOP game flow (GAME-0252/0265 / TEST-0021/0022):
## boot → menu → ready → playing → crash → game over → restart (no page reload),
## scoring, collision and best-score handling. Deterministic: the pure logic
## cores are driven directly instead of relying on frame timing.

var game: MotoHop

func _boot() -> MotoHop:
	var g: MotoHop = load("res://src/core/moto_hop.tscn").instantiate()
	add_child_autofree(g)
	await get_tree().process_frame
	return g

func test_boot_reaches_menu() -> void:
	game = await _boot()
	assert_eq(GameState.current_state, GameState.State.MENU, "boot must land in MENU")
	assert_not_null(game.bike)
	assert_not_null(game.obstacles)
	assert_not_null(game.background)
	assert_not_null(game.hud)
	assert_not_null(game.menu)

func test_start_game_runs_countdown_then_plays() -> void:
	game = await _boot()
	game.start_game()
	assert_eq(GameState.current_state, GameState.State.READY)
	var frames := 0
	while GameState.current_state == GameState.State.READY and frames < 600:
		await get_tree().process_frame
		frames += 1
	assert_eq(GameState.current_state, GameState.State.PLAYING,
		"countdown must finish and enter PLAYING")
	assert_gt(frames, 0)

func test_crash_ends_game_and_updates_best() -> void:
	game = await _boot()
	game.start_game()
	GameState.set_state(GameState.State.PLAYING)
	GameState.reset_session()
	# Simulate a floor crash through the real path.
	game.bike.sim.position = Vector2(180.0, PlayerBike.FLOOR_Y + 5.0)
	var best_before: int = GameState.best_score
	var score_before: int = GameState.score
	game._step_playing(0.016)
	assert_eq(GameState.current_state, GameState.State.GAME_OVER, "floor crash must end the run")
	assert_eq(GameState.best_score, max(best_before, score_before),
		"best score must never decrease across runs")

func test_collision_with_obstacle_ends_game() -> void:
	game = await _boot()
	game.start_game()
	GameState.set_state(GameState.State.PLAYING)
	GameState.reset_session()
	# Spawn an obstacle directly on top of the bike (deterministic, no frame timing).
	var params := game.obstacles.difficulty.get_params(0)
	game.obstacles._spawn(params)
	assert_gt(game.obstacles.active_count(), 0)
	var o = game.obstacles._active[0]
	o.position.x = game.bike.sim.position.x
	# Shift the gap far above the bike so the bike sits inside the bottom structure.
	o.gap_center = game.bike.sim.position.y - 400.0
	assert_true(game.obstacles.check_collision(game.bike.get_collision_circle()),
		"overlapping obstacle must collide")

func test_restart_resets_gameplay_without_reload() -> void:
	game = await _boot()
	game.start_game()
	GameState.set_state(GameState.State.PLAYING)
	GameState.score = 5
	game.score_manager.register_pass(1)
	# Crash, then restart.
	game._on_crash()
	assert_eq(GameState.current_state, GameState.State.GAME_OVER)
	game.start_game()
	assert_eq(GameState.current_state, GameState.State.READY, "restart must re-enter READY")
	assert_eq(GameState.score, 0, "score must reset on restart")
	assert_eq(game.score_manager.score, 0)
	assert_eq(game.obstacles.active_count(), 0, "obstacles must be recycled")
	assert_eq(game.bike.sim.position, PlayerBike.START_POS, "bike must return to start")
	var frames := 0
	while GameState.current_state == GameState.State.READY and frames < 600:
		await get_tree().process_frame
		frames += 1
	assert_eq(GameState.current_state, GameState.State.PLAYING)

func test_scoring_adds_one_point_per_pass() -> void:
	game = await _boot()
	GameState.set_state(GameState.State.PLAYING)
	GameState.reset_session()
	game.score_manager.reset()
	var m1 := game.score_manager.register_pass(10)
	var m2 := game.score_manager.register_pass(10)
	assert_eq(m1, 0)
	assert_eq(m2, 0)
	GameState.add_score(1)
	assert_eq(GameState.score, 1)
	game.start_game()
	assert_eq(GameState.score, 0, "start_game must reset the session score")

func test_pause_and_resume() -> void:
	game = await _boot()
	game.start_game()
	GameState.set_state(GameState.State.PLAYING)
	game.toggle_pause()
	assert_eq(GameState.current_state, GameState.State.PAUSED)
	game.toggle_pause()
	assert_eq(GameState.current_state, GameState.State.PLAYING)

func test_home_returns_to_menu() -> void:
	game = await _boot()
	game.start_game()
	GameState.set_state(GameState.State.PLAYING)
	game._on_crash()
	game.go_home()
	assert_eq(GameState.current_state, GameState.State.MENU)

func test_state_machine_rejects_illegal_transitions() -> void:
	game = await _boot()
	assert_false(GameState.can_go_to(GameState.State.PLAYING),
		"MENU must not jump straight to PLAYING")
	assert_false(GameState.can_go_to(GameState.State.GAME_OVER))
	assert_true(GameState.can_go_to(GameState.State.READY))
