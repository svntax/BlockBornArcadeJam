extends Node2D

onready var start_game_timer = $StartGameTimer
onready var high_scores_timer = $HighScoresTimer

onready var start_button = $"%StartButton"
onready var high_scores_button = $"%HighScoresButton"

onready var is_menu_selected = false

onready var main_theme_short = $MainThemeShort

func _ready():
	Globals.reset_score()
	start_button.grab_focus()
	_on_focus_changed(start_button)
	
	start_button.connect("focus_entered", self, "_on_button_focused")
	high_scores_button.connect("focus_entered", self, "_on_button_focused")

	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")
	
	main_theme_short.play()

func _on_focus_changed(control: Control) -> void:
	if control == start_button:
		start_button.get_node("SelectArrow").show()
		high_scores_button.get_node("SelectArrow").hide()
	elif control == high_scores_button:
		high_scores_button.get_node("SelectArrow").show()
		start_button.get_node("SelectArrow").hide()

func _on_button_focused():
	if is_menu_selected:
		return
	
	SoundManager.play_menu_select_sound()

#func _process(delta):
#	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
#		if not is_menu_selected:
#			SoundManager.play_start_game_sound()
#			start_game_timer.start()
#		is_menu_selected = true

func _on_StartGameTimer_timeout():
	fade_out_music()
	SceneManager.change_scene("res://UI/Screens/Gameplay.tscn", 1.75, "FADE_THEN_CURTAIN")

func _on_StartButton_pressed():
	if is_menu_selected or SceneManager.transition_running:
		return
	
	high_scores_button.focus_mode = Control.FOCUS_NONE
	high_scores_button.disabled = true
	is_menu_selected = true
	SoundManager.play_start_game_sound()
	start_game_timer.start()

func fade_out_music() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(main_theme_short, "volume_db", -80, 1)

func _on_HighScoresTimer_timeout():
	fade_out_music()
	SceneManager.change_scene("res://UI/Screens/LeaderboardsScreen.tscn", 0.25, "CURTAIN")

func _on_HighScoresButton_pressed():
	if is_menu_selected or SceneManager.transition_running:
		return
	
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.disabled = true
	is_menu_selected = true
	SoundManager.play_menu_select_sound()
	high_scores_timer.start()

func _on_StartButton_mouse_entered():
	start_button.grab_focus()

func _on_HighScoresButton_mouse_entered():
	high_scores_button.grab_focus()
