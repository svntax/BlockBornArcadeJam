tool
extends Area2D

signal cleared_final_room()

const ROOM_WIDTH = 256

export (NodePath) var camera_node_path = NodePath()
var camera_node

export (bool) var final_room = false

var game_ui

var debug_color = Color(1, 0, 0, 0.5)
var room_rect = Rect2(0, 0, ROOM_WIDTH, 224)

onready var enemy_count = 0

func _ready():
	if not Engine.is_editor_hint():
		camera_node = get_node(camera_node_path)
		self.connect("body_entered", self, "_on_body_entered")
		
		var game_ui_list = get_tree().get_nodes_in_group("GameUI")
		if game_ui_list.empty():
			printerr("WARNING: Could not find the GameUI when connecting BattleRoom.")
			return
		game_ui = game_ui_list[0]

func is_final_room() -> bool:
	return final_room

func _process(_delta):
	if Engine.is_editor_hint():
		update()
		return

func _on_body_entered(other):
	if other.is_in_group("Players"):
		# A player has entered the room. Start a battle.
		enter_room()
		# Disable the collisions to prevent triggering again.
		collision_layer = 0
		collision_mask = 0

func enter_room() -> void:
	# Limit the camera bounds to this room
	camera_node.set_follow_target(self)
	camera_node.limit_right = global_position.x + ROOM_WIDTH
	
	# Start spawning enemies
	for node in get_children():
		if node.has_method("start_spawning"):
			node.battle_room = self # Must be set before spawning starts
			node.start_spawning()
			enemy_count += node.get_enemy_count()

func clear_room() -> void:
	# The current room is the new left limit
	camera_node.limit_left = global_position.x
	
	if final_room:
		emit_signal("cleared_final_room")
	else:
		# Reset the camera limits only if there's still more rooms to clear.
		camera_node.limit_right = 100000
		camera_node.smoothing_enabled = false
		camera_node.reset_follow_target_to_player()
		# Show the GO sign
		if game_ui != null:
			game_ui.show_go_sign()

func _on_enemy_death(_enemy_points_value: int) -> void:
	enemy_count -= 1
	if enemy_count <= 0:
		clear_room()

func _draw():
	if Engine.is_editor_hint():
		draw_rect(room_rect, debug_color, false, 2)
