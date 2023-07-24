extends Area2D

onready var score_value = 300

onready var is_collected = false

func _ready():
	self.connect("body_entered", self, "_on_body_entered")

func get_score_value() -> int:
	return score_value

func _on_body_entered(other):
	if is_collected:
		return
	
	if other.has_method("collect_object"):
		is_collected = true
		other.collect_object(self)
		queue_free()
