extends GutTest
## Integration tests for project settings (GAME-0006/0007 / TEST-0009).

func test_compatibility_renderer_is_configured() -> void:
	assert_eq(ProjectSettings.get_setting("rendering/renderer/rendering_method"), "gl_compatibility")

func test_mobile_renderer_is_compatibility() -> void:
	assert_eq(ProjectSettings.get_setting("rendering/renderer/rendering_method.mobile"), "gl_compatibility")

func test_main_scene_is_set_and_loadable() -> void:
	var main := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	assert_gt(main.length(), 0)
	assert_true(ResourceLoader.exists(main), "main scene resource missing: " + main)

func test_window_size_is_positive() -> void:
	assert_gt(int(ProjectSettings.get_setting("display/window/size/viewport_width", 0)), 0)
	assert_gt(int(ProjectSettings.get_setting("display/window/size/viewport_height", 0)), 0)

func test_autoloads_registered() -> void:
	var autoloads: Dictionary = ProjectSettings.get_setting("autoload", {})
	for a in ["EventBus", "GameState", "InputManager"]:
		assert_true(autoloads.has(a), "missing autoload: " + a)
