extends Node
## Global session state autoload. UI-free and headless-testable.
## Persistent data uses stable string IDs; save schema is versioned.

const SAVE_VERSION := 1

signal game_state_changed

var money := 0
var reputation := 0
var current_bike := "scooter_default"
var owned_bikes: Array[String] = ["scooter_default"]

func add_money(amount: int) -> void:
	if amount > 0:
		money += amount
		game_state_changed.emit()

func try_spend(amount: int) -> bool:
	if amount > 0 and money >= amount:
		money -= amount
		game_state_changed.emit()
		return true
	return false

func to_dict() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"money": money,
		"reputation": reputation,
		"current_bike": current_bike,
		"owned_bikes": owned_bikes.duplicate(),
	}

func from_dict(d: Dictionary) -> void:
	var v = d.get("money", 0)
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		money = int(v)
	v = d.get("reputation", 0)
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		reputation = int(v)
	var cb = d.get("current_bike", "scooter_default")
	if typeof(cb) == TYPE_STRING and not String(cb).is_empty():
		current_bike = String(cb)
	var ob = d.get("owned_bikes", [])
	owned_bikes.clear()
	if typeof(ob) == TYPE_ARRAY:
		for entry in ob:
			if typeof(entry) == TYPE_STRING:
				owned_bikes.append(String(entry))
	game_state_changed.emit()
