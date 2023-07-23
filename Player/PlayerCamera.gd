extends Camera2D

const SCREEN_WIDTH = 256

onready var drag_margin_left_custom = 48
onready var drag_margin_right_custom = 4
onready var drag_speed = 1

export (NodePath) var player_path = NodePath()
var player

# Moving wall that prevents the player from moving back
export (NodePath) var left_wall_path = NodePath()
var left_wall

onready var target = null

func _ready():
	player = get_node(player_path)
	left_wall = get_node(left_wall_path)
	target = player

func set_follow_target(node: Node2D) -> void:
	target = node

func reset_follow_target_to_player() -> void:
	set_follow_target(player)

func _process(_delta):
	# Left wall should always be on the left camera limit
	left_wall.global_position.x = max(limit_left, global_position.x)
	
	var target_x = target.global_position.x
	var cam_x = global_position.x
	if target == player:
		target_x -= SCREEN_WIDTH / 2
		if target_x < cam_x - drag_margin_left_custom:
			global_position.x += -drag_speed
		elif target_x > cam_x + drag_margin_right_custom:
			global_position.x += drag_speed
	else:
		# Don't do drag margin calculations for other targets
		if target_x < cam_x:
			global_position.x += -drag_speed
		elif target_x > cam_x:
			global_position.x += drag_speed
	
	# Keep updating the camera's left limit
	if global_position.x > limit_left:
		limit_left = global_position.x
