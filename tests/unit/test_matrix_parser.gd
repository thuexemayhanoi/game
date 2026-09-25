extends GutTest
## Unit tests: the master matrix parses with unique well-formed IDs (TEST-0006).

const MATRIX := "res://docs/matrix/game-master-matrix.csv"

func _rows() -> Array:
	var f := FileAccess.open(MATRIX, FileAccess.READ)
	if f == null:
		return []
	var text := f.get_as_text()
	f.close()
	var lines := text.split("\n", false)
	if lines.size() < 2:
		return []
	return lines.slice(1)

func test_matrix_has_at_least_250_rows() -> void:
	assert_gt(_rows().size(), 249, "master matrix must contain at least 250 rows")

func test_ids_are_unique_and_wellformed() -> void:
	var seen := {}
	for row in _rows():
		var id := String(row).split(",")[0]
		assert_true(id.begins_with("GAME-"), "bad id: " + id)
		assert_false(seen.has(id), "duplicate id: " + id)
		seen[id] = true
