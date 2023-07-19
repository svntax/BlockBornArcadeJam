extends KinematicBody2D

onready var speed = 64
onready var velocity = Vector2()

onready var body_root = $Body
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var damage_immunity_timer = $DamageImmunityTimer

func _physics_process(_delta: float) -> void:
	if can_move():
		move()
	
	# DEBUG: test damage remove later
	if Input.is_action_just_pressed("ui_accept"):
		damage(1)
	
	move_and_slide(velocity)
	# Face the right direction
	if velocity.x < 0:
		body_root.scale.x = -1
	elif velocity.x > 0:
		body_root.scale.x = 1

func move() -> void:
	# Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()
	velocity = input_dir * speed

func can_move() -> bool:
	return state_machine.state in ["IDLE", "WALK"]

func damage(amount: int) -> void:
	state_machine.set_state("HURT")
	damage_immunity_timer.start()

func can_take_damage() -> bool:
	return damage_immunity_timer.is_stopped()

func _on_AnimationPlayer_animation_finished(anim_name):
	if state_machine.state == "ATTACK" and anim_name == "attack":
		state_machine.set_state("IDLE")
	if state_machine.state == "HURT" and anim_name == "hurt":
		state_machine.set_state("IDLE")
