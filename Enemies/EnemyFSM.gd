extends "res://StateMachine.gd"

# IDLE, WALK, ATTACK, HURT, DEAD, INACTIVE

func _ready():
	call_deferred("set_state", "INACTIVE")

func _state_logic(_delta):
	if state == "IDLE":
		actor.face_player()
		if actor.attack_timer.is_stopped():
			actor.start_attack_timer()

func _state_transition(delta):
	if state == "IDLE":
		if not actor.close_to_player():
			set_state("WALK")
	elif state == "WALK":
		if actor.close_to_player():
			set_state("IDLE")
		elif not actor.check_player_in_range():
			set_state("INACTIVE")
	elif state == "INACTIVE":
		actor.inactive_process(delta)

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
		# Yield to make the sounds more scattered
		yield(get_tree().create_timer(rand_range(0.01, 0.075), false), "timeout")
		SoundManager.play_punch_hit_sound()
	elif new_state == "DEAD":
		actor.emit_signal("death", actor.get_score_value())
		actor.velocity = Vector2()
		actor.attack_timer.stop()
		actor.remove_timer.start(0.55)
		actor.hurtbox.collision_layer = 0
		actor.hurtbox.collision_mask = 0
		# Yield to make the sounds more scattered
		yield(get_tree().create_timer(rand_range(0.01, 0.075), false), "timeout")
		actor.animation_player.play("death")
		SoundManager.play_punch_hit_big_sound()
	elif new_state == "INACTIVE":
		actor.animation_player.play("idle")
		actor.attack_timer.stop()
		actor.velocity = Vector2()

func _exit_state(old_state, _new_state):
	if old_state == "IDLE":
		if not actor.attack_timer.is_stopped():
			actor.attack_timer.paused = true
	elif old_state == "ATTACK":
		actor.call_deferred("reset_damage_areas")
