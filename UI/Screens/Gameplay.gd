extends Node2D

onready var game_ui = $"%GameUI"
onready var misc_enemies = $"%MiscEnemies"

func _ready():
	# Enemies not tied to a specific room must also have their signals connected.
	for enemy in misc_enemies.get_children():
		enemy.connect("enemy_health_changed", game_ui, "set_enemy_stats")
		enemy.connect("death", game_ui, "_on_enemy_death")
