class_name ScoreManager
extends RefCounted
## Pure scoring logic (MOTO HOP): exactly one point per obstacle pair and
## milestone detection. No scene dependencies.

const MILESTONES := [10, 25, 50, 100]

var score := 0
var _passed_ids := {}

## Registers that the obstacle pair with this id was passed.
## Returns the milestone reached this pass (0 when none). Idempotent per id.
func register_pass(obstacle_id: int) -> int:
	if _passed_ids.has(obstacle_id):
		return 0
	_passed_ids[obstacle_id] = true
	score += 1
	return milestone_for(score)

## Returns the milestone for a score value when it matches exactly, else 0.
func milestone_for(value: int) -> int:
	for m in MILESTONES:
		if value == m:
			return m
	return 0

func has_passed(obstacle_id: int) -> bool:
	return _passed_ids.has(obstacle_id)

func passed_count() -> int:
	return _passed_ids.size()

func reset() -> void:
	score = 0
	_passed_ids.clear()
