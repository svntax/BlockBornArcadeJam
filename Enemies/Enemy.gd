extends KinematicBody2D

export (int) var speed = 32
export (int) var melee_distance_x = 24
export (int) var melee_distance_y = 8
onready var velocity = Vector2()

onready var body_root = $Body
onready var hitboxes = $Hitboxes
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var damage_immunity_timer = $DamageImmunityTimer

onready var player = null

func _ready():
	player = get_tree().get_nodes_in_group("Players")[0]

func _physics_process(_delta: float) -> void:
	if can_move():
		move()
	
	move_and_slide(velocity)
	# Face the right direction
	if velocity.x < 0:
		body_root.scale.x = -1
		hitboxes.scale.x = -1
	elif velocity.x > 0:
		body_root.scale.x = 1
		hitboxes.scale.x = 1

func walk_towards_player() -> void:
	var dir = global_position.direction_to(player.global_position)
	velocity = dir * speed

func close_to_player() -> bool:
	var dist_x = abs(global_position.x - player.global_position.x)
	var dist_y = abs(global_position.y - player.global_position.y)
	return dist_x <= melee_distance_x and dist_y <= melee_distance_y

func move() -> void:
	if state_machine.state == "WALK":
		walk_towards_player()
	elif state_machine.state == "IDLE":
		velocity.x = 0
		velocity.y = 0

func can_move() -> bool:
	return state_machine.state in ["IDLE", "WALK"]

func damage(amount: int) -> void:
	if can_take_damage():
		state_machine.set_state("HURT")
		damage_immunity_timer.start()

func can_take_damage() -> bool:
	return damage_immunity_timer.is_stopped()

func _on_AnimationPlayer_animation_finished(anim_name):
	if state_machine.state == "ATTACK" and anim_name == "attack":
		state_machine.set_state("IDLE")
	if state_machine.state == "HURT" and anim_name == "hurt":
		state_machine.set_state("IDLE")

func _on_HurtBox_area_entered(area):
	# Assumes that only PLAYER damage areas are detected
	damage(1)
