extends "res://StateMachine.gd"

# IDLE, WALK, ATTACK, HURT

const CONTROLLABLE_STATES = ["IDLE", "WALK"]

func _ready():
	call_deferred("set_state", "IDLE")

func _state_logic(_delta):
	if state == "IDLE":
		if actor.attack_timer.is_stopped():
			actor.start_attack_timer()

func _state_transition(_delta):
	if state == "IDLE":
		if not actor.close_to_player():
			set_state("WALK")
	elif state == "WALK":
		if actor.close_to_player():
			set_state("IDLE")

func _enter_state(new_state, _old_state):
	if new_state == "IDLE":
		actor.animation_player.play("idle")
		if actor.attack_timer.paused:
			actor.attack_timer.paused = false
		else:
			actor.start_attack_timer()
	elif new_state == "WALK":
		actor.animation_player.play("walk", -1, 0.8)
	elif new_state == "ATTACK":
		actor.velocity = Vector2()
		actor.animation_player.play("attack")
	elif new_state == "HURT":
		actor.velocity = Vector2()
		actor.animation_player.play("hurt")
		actor.attack_timer.stop()

func _exit_state(old_state, _new_state):
	if old_state == "IDLE":
		if not actor.attack_timer.is_stopped():
			actor.attack_timer.paused = true
	elif old_state == "ATTACK":
		actor.call_deferred("reset_damage_areas")
