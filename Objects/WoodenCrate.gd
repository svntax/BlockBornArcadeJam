extends KinematicBody2D

export (int) var hp = 1
var max_hp

export (String, FILE, "*.tscn") var loot_object_scene
var LootObject

onready var velocity = Vector2()
onready var aggro_range = 248

onready var body_root = $Body
onready var hurtbox = $HurtBox
onready var animation_player = $AnimationPlayer
onready var remove_timer = $RemoveTimer
onready var flash_remove_count = 0 # Flashing effect when being removed

func _ready():
	max_hp = hp
	LootObject = load(loot_object_scene)

func damage(_amount: int) -> void:
	remove_timer.start(0.55)
	collision_layer = 0
	collision_mask = 0
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 0
	animation_player.play("break")
	call_deferred("drop_loot")

func _on_HurtBox_area_entered(area):
	# Assumes that only PLAYER damage areas are detected
	damage(1)

func drop_loot() -> void:
	var loot_object = LootObject.instance()
	get_parent().add_child(loot_object)
	loot_object.global_position = global_position + Vector2(0, 1)

func _on_RemoveTimer_timeout():
	body_root.visible = !body_root.visible
	flash_remove_count += 1
	if flash_remove_count > 6:
		queue_free()
	else:
		remove_timer.start(0.1)
