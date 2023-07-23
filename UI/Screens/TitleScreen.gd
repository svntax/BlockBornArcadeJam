extends Node2D

func _ready():
	Globals.reset_score()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		get_tree().change_scene("res://UI/Screens/Gameplay.tscn")
