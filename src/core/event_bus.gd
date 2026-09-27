extends Node
## Global event bus autoload (MOTO HOP). Systems communicate through signals only.

signal state_changed(new_state: int, old_state: int)
signal score_changed(score: int)
signal best_changed(best: int)
signal milestone_reached(milestone: int)
signal crashed
signal hop_performed
signal mute_changed(muted: bool)
signal button_clicked
