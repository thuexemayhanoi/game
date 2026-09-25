extends GutTest
## Parse the master matrix CSV from GDScript and verify invariants.

const MATRIX := "res://docs/matrix/game-master-matrix.csv"

func test_matrix_loads_and_has_250_rows():
	var file := FileAccess.open(MATRIX, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return
	var lines: PackedStringArray = file.get_as_text().strip_edges().split("\n")
	assert_gt(lines.size(), 250, "matrix must have at least 250 rows")

func test_matrix_header():
	var file := FileAccess.open(MATRIX, FileAccess.READ)
	if file == null:
		fail_test("matrix missing")
		return
	var header: PackedStringArray = file.get_line().split(",")
	assert_has(header, "id")
	assert_has(header, "status")
	assert_has(header, "acceptance")

func test_unique_ids():
	var file := FileAccess.open(MATRIX, FileAccess.READ)
	if file == null:
		fail_test("matrix missing")
		return
	var seen := {}
	file.get_line() # header
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		var id := line.split(",")[0]
		assert_false(seen.has(id), "duplicate id: " + id)
		seen[id] = true
