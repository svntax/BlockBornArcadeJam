extends Sprite

export (NodePath) var sprite_target_path = NodePath()
onready var sprite_target

func _ready():
	sprite_target = get_node(sprite_target_path)

func _process(delta):
	self.frame = sprite_target.frame
