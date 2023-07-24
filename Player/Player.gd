extends KinematicBody2D

signal health_changed(new_hp, max_hp)
signal points_collected(amount)

onready var speed = 64
onready var velocity = Vector2()

onready var max_hp = 8
onready var hp = max_hp

onready var body_root = $Body
onready var hitboxes = $Hitboxes
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var damage_immunity_timer = $DamageImmunityTimer

onready var hit_dead_sound = $HitDeadSound
onready var punch_air_sound = $PunchAirSound

onready var attack_damage_areas = [
	$Hitboxes/MeleeAttack/CollisionShape2D
]

func _physics_process(_delta: float) -> void:
	if can_move():
		move()
	
	# DEBUG: test damage TODO remove later
	if Input.is_action_just_pressed("ui_accept"):
		damage(100)
	
	move_and_slide(velocity)
	# Face the right direction
	if velocity.x < 0:
		body_root.scale.x = -1
		hitboxes.scale.x = -1
	elif velocity.x > 0:
		body_root.scale.x = 1
		hitboxes.scale.x = 1

func collect_object(object: Node2D) -> void:
	var object_value = object.get_score_value()
	emit_signal("points_collected", object_value)

func move() -> void:
	# Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()
	velocity = input_dir * speed

func can_move() -> bool:
	return state_machine.state in ["IDLE", "WALK"]

func get_hp() -> int:
	return hp

func get_max_hp() -> int:
	return max_hp

func damage(amount: int) -> void:
	if can_take_damage():
		hp -= amount
		if hp > 0:
			state_machine.set_state("HURT")
			damage_immunity_timer.start()
		else:
			hp = 0
			state_machine.set_state("DEAD")
		emit_signal("health_changed", hp, max_hp)

func can_take_damage() -> bool:
	return damage_immunity_timer.is_stopped() and state_machine.state != "DEAD"

func reset_damage_areas() -> void:
	for collision in attack_damage_areas:
		collision.disabled = true

# Plays only if no enemies are about to be hit
func play_punch_air_sound() -> void:
	var is_overlapping_enemies = false
	var other_areas = []
	for attack_collision in attack_damage_areas:
		var attack_area = attack_collision.get_parent()
		var overlapping_areas = attack_area.get_overlapping_areas()
		if !overlapping_areas.empty():
			is_overlapping_enemies = true
			other_areas += overlapping_areas
			break
	if not is_overlapping_enemies:
		punch_air_sound.play()

func die() -> void:
	velocity = Vector2()
	animation_player.play("death", -1, 0.75)
	hit_dead_sound.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	if state_machine.state == "ATTACK" and anim_name == "attack":
		state_machine.set_state("IDLE")
	if state_machine.state == "HURT" and anim_name == "hurt":
		state_machine.set_state("IDLE")

func _on_HurtBox_area_entered(area):
	# Assumes that only ENEMY damage areas are detected
	damage(1)
