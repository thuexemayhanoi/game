extends GutTest
## Integration test: the test world boots with all required children (TEST-0007).

func test_boot_world() -> void:
	var world: TestWorld = load("res://src/world/test_world.tscn").instantiate()
	add_child_autofree(world)
	for i in range(30):
		await get_tree().physics_frame
	assert_not_null(world.bike, "world must spawn a player bike")
	assert_true(is_instance_valid(world.bike))
	assert_not_null(world.camera, "world must have a chase camera")
	assert_not_null(world.hud, "world must have a HUD")
	assert_true(world.get_node_or_null("Ground") != null)
	assert_true(world.get_child_count() > 4)

func test_bike_has_collision_and_visuals() -> void:
	var world: TestWorld = load("res://src/world/test_world.tscn").instantiate()
	add_child_autofree(world)
	for i in range(5):
		await get_tree().physics_frame
	assert_true(world.bike.get_node_or_null("Collision") != null)
	assert_true(world.bike.get_node_or_null("Body") != null)
	assert_true(world.bike.sim != null)
