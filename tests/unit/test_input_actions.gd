extends GutTest
## Input actions registered by the InputAdapter autoload.

func test_actions_registered():
	for action in ["throttle", "brake", "steer_left", "steer_right", "reset_bike"]:
		assert_true(InputMap.has_action(action), "missing action: " + action)

func test_keyboard_binding():
	var has_w := false
	for ev in InputMap.action_get_events("throttle"):
		if ev is InputEventKey and ev.physical_keycode == KEY_W:
			has_w = true
	assert_true(has_w, "throttle must be bound to W")

func test_steer_combines_touch():
	InputAdapter.touch.steer = 0.5
	assert_eq(InputAdapter.get_steer(), 0.5)
	InputAdapter.touch.steer = 0.0
