extends Node2D

var ScoreEntry = preload("res://UI/ScoreEntry.tscn")
onready var scores_container = $"%Scores"

func _ready():
	# Clear the scores list
	for node in scores_container.get_children():
		node.queue_free()
	
	# DEBUG TEST
#	Globals.add_score_entry(500)
#	Globals.add_score_entry(12345, "TestPlayer")
#	Globals.add_score_entry(3200, "DevPlayer")
#	for i in range(10):
#		Globals.add_score_entry(i*10, "Player" + str(i))
	
	fetch_scores()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if not SceneManager.transition_running:
			SoundManager.play_menu_select_sound()
		SceneManager.change_scene("res://UI/Screens/TitleScreen.tscn", 0.5, "FADE")

func fetch_scores() -> void:
	var score_entries = Globals.get_high_scores()
	
	# score_arr is an Array where [0] = score and [1] = the player's name
	for score_arr in score_entries:
		var score = score_arr[0]
		var player_name = score_arr[1]
		var score_entry = ScoreEntry.instance()
		scores_container.add_child(score_entry)
		score_entry.set_score_text(str(score))
		score_entry.set_name_text(player_name)
