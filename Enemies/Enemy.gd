extends KinematicBody2D

signal death()
signal enemy_health_changed(enemy_name, current_hp, max_hp)

export (int) var speed = 32
export (int) var melee_distance_x = 24
export (int) var melee_distance_y = 8
export (int) var hp = 3
var max_hp

onready var velocity = Vector2()

onready var body_root = $Body
onready var hitboxes = $Hitboxes
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var damage_immunity_timer = $DamageImmunityTimer
onready var attack_timer = $AttackTimer
onready var remove_timer = $RemoveTimer
onready var flash_remove_count = 0 # Flashing effect when being removed

onready var attack_damage_areas = [
	$Hitboxes/MeleeAttack/CollisionShape2D
]

onready var player = null

func _ready():
	max_hp = hp
	player = get_tree().get_nodes_in_group("Players")[0]

func get_enemy_name() -> String:
	return "Adventurer"

func _physics_process(_delta: float) -> void:
	if can_move():
		move()
	
	move_and_slide(velocity)
	# Face the right direction
	set_face_direction(velocity.x)

func set_face_direction(dir: int) -> void:
	if sign(dir) < 0:
		body_root.scale.x = -1
		hitboxes.scale.x = -1
	elif sign(dir) > 0:
		body_root.scale.x = 1
		hitboxes.scale.x = 1

func walk_towards_player() -> void:
	var dir = global_position.direction_to(player.global_position)
	velocity = dir * speed

func face_player() -> void:
	var dir = 0
	if player.global_position.x < global_position.x:
		dir = -1
	else:
		dir = 1
	set_face_direction(dir)

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
		hp -= amount
		if hp > 0:
			state_machine.set_state("HURT")
			damage_immunity_timer.start()
		else:
			hp = 0
			state_machine.set_state("DEAD")
		emit_signal("enemy_health_changed", get_enemy_name(), hp, max_hp)

func can_take_damage() -> bool:
	return damage_immunity_timer.is_stopped() and state_machine.state != "DEAD"

func reset_damage_areas() -> void:
	for collision in attack_damage_areas:
		collision.disabled = true

func start_attack_timer() -> void:
	attack_timer.start(rand_range(0.25, 1))

func can_attack() -> bool:
	return state_machine.state == "IDLE"

func _on_AnimationPlayer_animation_finished(anim_name):
	if state_machine.state == "ATTACK" and anim_name == "attack":
		state_machine.set_state("IDLE")
	if state_machine.state == "HURT" and anim_name == "hurt":
		state_machine.set_state("IDLE")

func _on_HurtBox_area_entered(area):
	# Assumes that only PLAYER damage areas are detected
	damage(1)

func _on_AttackTimer_timeout():
	if can_attack():
		state_machine.set_state("ATTACK")

func _on_RemoveTimer_timeout():
	body_root.visible = !body_root.visible
	flash_remove_count += 1
	if flash_remove_count > 6:
		queue_free()
	else:
		remove_timer.start(0.1)
