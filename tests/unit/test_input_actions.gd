extends GutTest
## Unit tests for the input map (GAME-0020..0022 / TEST-0012).

const ACTIONS := ["throttle", "brake", "steer_left", "steer_right", "reset"]

func test_all_actions_exist() -> void:
	for a in ACTIONS:
		assert_true(InputMap.has_action(a), "missing action: " + a)

func test_all_actions_have_events() -> void:
	for a in ACTIONS:
		assert_gt(InputMap.action_get_events(a).size(), 0, "action has no events: " + a)

func test_idle_input_is_neutral() -> void:
	assert_eq(InputManager.get_throttle(), 0.0)
	assert_eq(InputManager.get_brake(), 0.0)
	assert_eq(InputManager.get_steer(), 0.0)

func test_touch_overrides_feed_input() -> void:
	InputManager.touch_throttle = 1.0
	InputManager.touch_brake = 1.0
	InputManager.touch_steer = -1.0
	assert_eq(InputManager.get_throttle(), 1.0)
	assert_eq(InputManager.get_brake(), 1.0)
	assert_eq(InputManager.get_steer(), -1.0)
	InputManager.touch_throttle = 0.0
	InputManager.touch_brake = 0.0
	InputManager.touch_steer = 0.0

func test_deadzone_rejects_small_values() -> void:
	InputManager.touch_steer = 0.1
	assert_eq(InputManager.get_steer(), 0.0, "values below dead zone must be ignored")
	InputManager.touch_steer = 0.0
