extends Control

var player

onready var player_healthbar = $PlayerHealthBar

onready var enemy_label = $EnemyLabel
onready var enemy_healthbar = $EnemyHealthBar
onready var hide_enemy_stats_timer = $HideEnemyStatsTimer
onready var game_over_timer = $GameOverTimer
onready var game_over_label = $"%GameOverLabel"
onready var game_over_finish_timer = $GameOverFinishTimer
onready var animation_player = $AnimationPlayer

func _ready():
	enemy_label.hide()
	enemy_healthbar.hide()
	game_over_label.hide()
	
	var players = get_tree().get_nodes_in_group("Players")
	if players.empty():
		return
	
	player = players[0]
	player_healthbar.max_value = player.get_max_hp()
	player_healthbar.value = player.get_hp()
	player.connect("health_changed", self, "_on_player_hp_changed")

func _on_player_hp_changed(new_hp: int, max_hp: int) -> void:
	player_healthbar.max_value = max_hp
	player_healthbar.value = new_hp
	
	# Game over
	if new_hp <= 0:
		game_over_timer.start()

func set_enemy_stats(name: String, current_hp: int, max_hp: int) -> void:
	hide_enemy_stats_timer.stop()
	enemy_label.show()
	enemy_healthbar.show()
	
	enemy_label.bbcode_text = name
	enemy_healthbar.max_value = max_hp
	enemy_healthbar.value = current_hp
	if current_hp == 0:
		hide_enemy_stats_timer.start()

func _on_HideEnemyStatsTimer_timeout():
	enemy_label.hide()
	enemy_healthbar.hide()

func _on_GameOverTimer_timeout():
	animation_player.play("game_over")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "game_over":
		game_over_finish_timer.start()

func _on_GameOverFinishTimer_timeout():
	# TODO: fade out to leaderboards screen
	get_tree().change_scene("res://UI/Screens/Gameplay.tscn")
