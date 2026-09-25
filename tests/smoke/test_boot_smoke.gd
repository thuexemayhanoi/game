extends GutTest
## Smoke: project structure and boot essentials.

func test_required_dirs_exist():
	for dir in ["res://src/core", "res://src/vehicles", "res://tests/unit"]:
		assert_true(DirAccess.dir_exists_absolute(dir), "missing dir: " + dir)

func test_bike_scene_compiles():
	assert_not_null(load("res://src/vehicles/bike.tscn"))

func test_world_scene_compiles():
	assert_not_null(load("res://src/world/test_world.tscn"))
