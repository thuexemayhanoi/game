extends GutTest
## Project boot: main scene loads and wires the slice.

func test_main_scene_loads():
	var tree := get_tree()
	var world := load("res://src/world/test_world.tscn").instantiate()
	assert_not_null(world)
	add_child_autofree(world)
	await wait_seconds(0.2)
	assert_true(world is Node3D)

func test_autoloads_present():
	assert_not_null(GameState)
	assert_not_null(InputAdapter)

func test_world_spawns_bike_and_hud():
	var world := load("res://src/world/test_world.tscn").instantiate()
	add_child_autofree(world)
	await wait_seconds(0.3)
	var bikes := world.find_children("*", "BikeController", true, false)
	assert_gt(bikes.size(), 0, "world must spawn a bike")
	var huds := world.find_children("*", "CanvasLayer", true, false)
	assert_gt(huds.size(), 0, "world must have a HUD")
