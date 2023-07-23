extends Control

onready var score : int = 0
onready var score_label = $"%ScoreLabel"

# Not necessarily in seconds
onready var time_left : int = 99
onready var time_label = $"%TimeLabel"
onready var time_bonus_timer = $TimeBonusTimer

var player

onready var player_healthbar = $PlayerHealthBar

onready var enemy_label = $EnemyLabel
onready var enemy_healthbar = $EnemyHealthBar
onready var hide_enemy_stats_timer = $HideEnemyStatsTimer
onready var game_over_timer = $GameOverTimer
onready var game_over_label = $"%GameOverLabel"
onready var game_over_finish_timer = $GameOverFinishTimer
onready var animation_player = $AnimationPlayer
onready var go_label = $"%GoText"
onready var show_go_delay_timer = $ShowGoDelayTimer
onready var effects_player = $EffectsPlayer

func _ready():
	enemy_label.hide()
	enemy_healthbar.hide()
	game_over_label.hide()
	go_label.hide()
	
	time_bonus_timer.start()
	update_time_label()
	update_score_label()
	
	var players = get_tree().get_nodes_in_group("Players")
	if players.empty():
		return
	
	player = players[0]
	player_healthbar.max_value = player.get_max_hp()
	player_healthbar.value = player.get_hp()
	player.connect("health_changed", self, "_on_player_hp_changed")

func show_go_sign() -> void:
	show_go_delay_timer.start()

func _on_player_hp_changed(new_hp: int, max_hp: int) -> void:
	player_healthbar.max_value = max_hp
	player_healthbar.value = new_hp
	
	# Game over
	if new_hp <= 0:
		game_over_timer.start()

func _on_enemy_death(enemy_points_value: int) -> void:
	score += enemy_points_value
	update_score_label()

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

func update_time_label() -> void:
	time_label.text = "TIME\n" + str(time_left)

func _on_TimeBonusTimer_timeout():
	time_left -= 1
	if time_left < 0:
		time_left = 0
	else:
		time_bonus_timer.start()
	update_time_label()

func update_score_label() -> void:
	var padded_score = str(score).pad_zeros(8)
	score_label.text = "SCORE\n" + padded_score

func _on_ShowGoDelayTimer_timeout():
	effects_player.play("flash_go")
