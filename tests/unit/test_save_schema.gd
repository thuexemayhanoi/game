extends GutTest
## Save schema + SaveManager roundtrip, versioning, corruption fallback.

const SaveManager := preload("res://src/core/save_manager.gd")

func test_default_save_valid():
	var save: Dictionary = SaveManager.default_save()
	assert_true(SaveManager.validate(save))

func test_default_save_has_version():
	assert_eq(SaveManager.default_save()["save_version"], 1)

func test_load_from_dict_preserves_version():
	var save: Dictionary = SaveManager.load_from_dict(SaveManager.default_save())
	assert_eq(save["save_version"], SaveManager.CURRENT_SAVE_VERSION)

func test_corrupt_save_falls_back():
	var save: Dictionary = SaveManager.load_from_dict({"garbage": true})
	assert_true(save.get("migrated_from_corrupt", false), "corrupt save must be flagged")

func test_schema_json_has_required_keys():
	var file := FileAccess.open("res://src/data/save_schema.json", FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	assert_true(parsed is Dictionary)
	if parsed is Dictionary:
		for key in ["save_version", "profile", "wallet", "bikes", "mission_progress", "achievements"]:
			assert_has(parsed, key)
