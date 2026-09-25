extends GutTest
## GameState settings behavior.

func test_default_settings():
	assert_eq(GameState.get_setting("quality_profile"), "MEDIUM")

func test_set_setting():
	GameState.set_setting("quality_profile", "LOW")
	assert_eq(GameState.get_setting("quality_profile"), "LOW")
	GameState.set_setting("quality_profile", "MEDIUM")

func test_unknown_setting_fallback():
	assert_eq(GameState.get_setting("does_not_exist", "fallback"), "fallback")

func test_reset_settings():
	GameState.set_setting("master_volume", 0.1)
	GameState.reset_settings()
	assert_eq(GameState.get_setting("master_volume"), 0.8)
