extends GutTest
## Smoke test: the configured main scene boots without fatal errors (TEST-0008/0016).

func test_main_scene_boots() -> void:
	var main := str(ProjectSettings.get_setting("application/run/main_scene"))
	var inst = load(main).instantiate()
	add_child_autofree(inst)
	for i in range(60):
		await get_tree().physics_frame
	assert_true(is_instance_valid(inst))
	var bike = inst.get_node_or_null("PlayerBike")
	assert_not_null(bike, "booted world must contain the player bike")
	var speed: float = bike.sim.get_speed_kmh()
	assert_true(is_finite(speed))
	var hud = inst.get_node_or_null("HUD")
	assert_not_null(hud, "booted world must contain the HUD")
