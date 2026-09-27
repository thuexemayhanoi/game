extends GutTest
## Integration test: the MOTO HOP main scene boots with all required children
## (GAME-0266 / TEST-0007).

func test_boot_game() -> void:
	var game: MotoHop = load("res://src/core/moto_hop.tscn").instantiate()
	add_child_autofree(game)
	for i in range(30):
		await get_tree().physics_frame
	assert_not_null(game.bike, "game must spawn the player bike")
	assert_not_null(game.obstacles, "game must have an obstacle manager")
	assert_not_null(game.background, "game must have the parallax background")
	assert_not_null(game.hud, "game must have a HUD")
	assert_not_null(game.menu, "game must have menu screens")
	assert_eq(game.obstacles.get_child_count(), ObstacleManager.POOL_SIZE,
		"obstacle pool must be pre-created (no runtime allocation)")
	assert_gt(game.background._strips.size(), 0, "parallax layers must exist")

func test_pool_is_reused_not_leaked() -> void:
	var game: MotoHop = load("res://src/core/moto_hop.tscn").instantiate()
	add_child_autofree(game)
	for i in range(5):
		await get_tree().physics_frame
	var params := game.obstacles.difficulty.get_params(0)
	for i in range(200):
		game.obstacles.step(0.016, params, 180.0)
	assert_lte(game.obstacles.active_count(), ObstacleManager.POOL_SIZE,
		"active obstacles must never exceed the pool size")
