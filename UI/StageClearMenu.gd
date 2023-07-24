extends PanelContainer

signal time_bonus_finished(time_bonus_award)
signal level_bonus_finished(level_bonus_award)

onready var time_bonus_label = $"%TimeBonusLabel"
onready var level_bonus_label = $"%LevelBonusLabel"

onready var effect_wait = 0.02
onready var effect_step = 200
onready var score_change_timer = 0
onready var time_bonus_effect_playing = false
onready var level_bonus_effect_playing = false

onready var time_bonus = 9900
onready var time_bonus_to_award = time_bonus
onready var level_bonus = 10000
onready var level_bonus_to_award = level_bonus

onready var score_effect_trigger_timer = $ScoreEffectTriggerTimer

func _ready():
	hide()
	update_time_bonus_text()

func _process(delta):
	if time_bonus_effect_playing:
		score_change_timer += delta
		if score_change_timer > effect_wait:
			score_change_timer = 0
			time_bonus -= effect_step
			if time_bonus < 0:
				time_bonus = 0
				time_bonus_effect_playing = false
				level_bonus_effect_playing = true
				emit_signal("time_bonus_finished", time_bonus_to_award)
			update_time_bonus_text()
	elif level_bonus_effect_playing:
		score_change_timer += delta
		if score_change_timer > effect_wait:
			score_change_timer = 0
			level_bonus -= effect_step
			if level_bonus < 0:
				level_bonus = 0
				level_bonus_effect_playing = false
				emit_signal("level_bonus_finished", level_bonus_to_award)
			update_level_bonus_text()

func reveal() -> void:
	show()
	score_effect_trigger_timer.start()

func set_time_bonus(amount: int) -> void:
	time_bonus = amount
	time_bonus_to_award = time_bonus
	update_time_bonus_text()

func update_time_bonus_text() -> void:
	time_bonus_label.text = "Time Bonus\n" + str(time_bonus)

# Counts down the time and level bonus points (visual effect).
func play_score_effect() -> void:
	time_bonus_effect_playing = true

func update_level_bonus_text() -> void:
	level_bonus_label.text = "Level Bonus\n" + str(level_bonus)

func _on_ScoreEffectTriggerTimer_timeout():
	play_score_effect()
