extends Node2D

onready var game_ui = $"%GameUI"
onready var misc_enemies = $"%MiscEnemies"
onready var rooms = $Rooms

onready var level_complete = false

func _ready():
	# Enemies not tied to a specific room must also have their signals connected.
	for enemy in misc_enemies.get_children():
		enemy.connect("enemy_health_changed", game_ui, "set_enemy_stats")
		enemy.connect("death", game_ui, "_on_enemy_death")
	
	for room in rooms.get_children():
		if room.is_final_room():
			room.connect("cleared_final_room", self, "_on_final_room_cleared")

func _process(delta):
	# DEBUG: test stage clear TODO remove later
	if Input.is_action_just_pressed("ui_focus_next"):
		_on_final_room_cleared()

func _on_final_room_cleared() -> void:
	if level_complete:
		return
	
	level_complete = true
	game_ui.show_level_complete()
