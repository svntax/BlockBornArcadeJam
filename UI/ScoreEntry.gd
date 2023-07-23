extends HBoxContainer

onready var name_label = $NameLabel
onready var score_label = $ScoreLabel

func set_score_text(txt: String) -> void:
	#var padded_score = txt.pad_zeros(8)
	score_label.text = txt #padded_score

func set_name_text(txt: String) -> void:
	name_label.text = txt
