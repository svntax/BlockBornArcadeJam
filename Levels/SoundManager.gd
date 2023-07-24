extends Node

# This singleton manages sound effects that can overlap in order to prevent
# them from increasing in volume.

onready var punch_hit_sound = $PunchHitSound
onready var punch_hit_big_sound = $PunchHitBigSound
onready var hit_ground_single_sound = $HitGroundSingle
onready var hit_ground_double_sound = $HitGroundDouble

onready var start_game_sound = $StartGameSound
onready var menu_select_sound = $MenuSelectSound

func play_punch_hit_sound() -> void:
	punch_hit_sound.play()

func play_punch_hit_big_sound() -> void:
	punch_hit_big_sound.play()

func play_hit_ground_single_sound() -> void:
	hit_ground_single_sound.play()

func play_hit_ground_double_sound() -> void:
	hit_ground_double_sound.play()

func play_start_game_sound() -> void:
	start_game_sound.play()

func play_menu_select_sound() -> void:
	menu_select_sound.play()
