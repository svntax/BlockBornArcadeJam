extends "res://StateMachine.gd"

# IDLE, WALK, ATTACK, HURT, DEAD

func _ready():
	call_deferred("set_state", "IDLE")

func _state_logic(_delta):
	pass

func _state_transition(_delta):
	if state == "IDLE":
		if Input.is_action_just_pressed("attack"):
			set_state("ATTACK")
		else:
			if is_move_pressed():
				set_state("WALK")
	elif state == "WALK":
		if Input.is_action_just_pressed("attack"):
			set_state("ATTACK")
		else:
			if not is_move_pressed():
				set_state("IDLE")
	elif state == "ATTACK":
		pass

func _enter_state(new_state, _old_state):
	if new_state == "IDLE":
		actor.animation_player.play("idle")
	elif new_state == "WALK":
		actor.animation_player.play("walk")
	elif new_state == "ATTACK":
		actor.velocity = Vector2()
		actor.animation_player.play("attack")
	elif new_state == "HURT":
		actor.velocity = Vector2()
		actor.animation_player.play("hurt")
	elif new_state == "DEAD":
		actor.die()

func _exit_state(old_state, _new_state):
	if old_state == "ATTACK":
		actor.call_deferred("reset_damage_areas")

func is_move_pressed() -> bool:
	return Input.is_action_pressed("move_left") \
		or Input.is_action_pressed("move_right") \
		or Input.is_action_pressed("move_up") \
		or Input.is_action_pressed("move_down")
