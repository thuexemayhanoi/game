extends GutTest
## Unit tests for the MOTO HOP input map (GAME-0261 / TEST-0012).

const ACTIONS := ["hop", "pause", "toggle_mute"]

func test_all_actions_exist() -> void:
	for a in ACTIONS:
		assert_true(InputMap.has_action(a), "missing action: " + a)

func test_all_actions_have_events() -> void:
	for a in ACTIONS:
		assert_gt(InputMap.action_get_events(a).size(), 0, "action has no events: " + a)

func test_hop_has_space_up_and_gamepad() -> void:
	var codes := {}
	for ev in InputMap.action_get_events("hop"):
		if ev is InputEventKey:
			codes[ev.physical_keycode] = true
		elif ev is InputEventJoypadButton:
			codes[ev.button_index] = true
	assert_true(codes.has(KEY_SPACE), "Space must hop")
	assert_true(codes.has(KEY_UP), "Up arrow must hop")
	assert_true(codes.has(JOY_BUTTON_A), "Gamepad A must hop")
