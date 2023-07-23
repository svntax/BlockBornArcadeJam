extends Position2D

export (String, FILE, "*.tscn") var enemy_scene
var Enemy

export (NodePath) var target_parent_path = NodePath()
var target_parent

export (float) var spawn_time = 1.0

export (int, 1, 8) var repeat_count = 1
onready var num_repeats = 0

onready var spawn_timer = Timer.new()
onready var battle_room = null

func _ready():
	Enemy = load(enemy_scene)
	target_parent = get_node(target_parent_path)
	
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_time
	spawn_timer.one_shot = true
	spawn_timer.connect("timeout", self, "_on_spawn_timer_timeout")

# Called by a battle room when the player enters one.
func start_spawning() -> void:
	spawn_timer.start()

func _on_spawn_timer_timeout():
	spawn_enemy()
	num_repeats += 1
	if num_repeats < repeat_count:
		spawn_timer.start()

func spawn_enemy() -> void:
	var enemy = Enemy.instance()
	target_parent.add_child(enemy)
	enemy.set_face_direction(-1) # Make enemies face left when they spawn
	enemy.global_position = global_position
	
	# Connect enemy death event to battle room
	enemy.connect("death", battle_room, "_on_enemy_death")
	var game_ui_list = get_tree().get_nodes_in_group("GameUI")
	if game_ui_list.empty():
		printerr("WARNING: Could not find the GameUI when spawning enemy.")
		return
	var game_ui = game_ui_list[0]
	enemy.connect("enemy_health_changed", game_ui, "set_enemy_stats")
	enemy.connect("death", game_ui, "_on_enemy_death")

func get_enemy_count() -> int:
	return repeat_count
