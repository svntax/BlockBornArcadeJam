extends Node

onready var current_score = 0
onready var high_scores = []

func get_current_score() -> int:
	return current_score

func set_score(score: int) -> void:
	current_score = score

func reset_score() -> void:
	current_score = 0

func get_high_scores() -> Array:
	return high_scores

func add_score_entry(score: int, player_name: String = "Player"):
	# Should we add scores of 0?
#	if score <= 0:
#		return

	high_scores.append([score, player_name])
	high_scores.sort_custom(self, "_compare_scores")
	
	if high_scores.size() > 10:
		high_scores.resize(10)

func _compare_scores(a, b):
	return b[0] < a[0]
