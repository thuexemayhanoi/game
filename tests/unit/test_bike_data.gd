extends GutTest
## Bike data loads from src/data/bikes.json and contains the slice bike.

func test_bikes_json_loads():
	var data: Dictionary = BikeController._load_bike_data()
	assert_gt(data.size(), 0)

func test_first_bike_has_required_stats():
	var data: Dictionary = BikeController._load_bike_data()
	assert_true(data.has("song_hong_50"))
	var bike: Dictionary = data.get("song_hong_50", {})
	for key in ["max_speed", "acceleration", "braking", "steer_speed"]:
		assert_has(bike, key)

func test_stats_load_into_controller():
	var bike := BikeController.new()
	add_child_autofree(bike)
	bike.load_stats("song_hong_50")
	assert_gt(float(bike.stats["max_speed"]), 0.0)
