extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var bg_rect = $Bg
onready var duration_timer = $DurationTimer
onready var horizontal_rects = $HorizontalRects

onready var next_scene = ""
onready var transition_running = false
onready var transition_type = ""

onready var transitions = {
	"SLIDE_LEFT_SIDE": ["slide_right_in", "slide_left_out"],
	"FADE_THEN_CURTAIN": ["fade_in", "curtain_vertical_out"],
	"CURTAIN": ["curtain_vertical_in", "curtain_vertical_out"],
	"FADE": ["fade_in", "fade_out"]
}

func _ready():
	reset_effects()

func change_scene(scene_path: String, duration: float = 0.5, type: String = "SLIDE_LEFT_SIDE") -> void:
	if transition_running:
		return
	
	reset_effects()
	transition_running = true
	next_scene = scene_path
	transition_type = type
	duration_timer.wait_time = duration
	animation_player.play(transitions.get(type)[0])

func reset_effects() -> void:
	bg_rect.hide()
	horizontal_rects.hide()

func play_horizontal_bars_in() -> void:
	var delay = 0
	for rect_slide in horizontal_rects.get_children():
		rect_slide.set_full_size(false)
		rect_slide.trigger_slide_effect_in(0.4, delay)
		delay += 0.04

func play_horizontal_bars_out() -> void:
	var delay = 0
	for rect_slide in horizontal_rects.get_children():
		rect_slide.set_full_size(true)
		rect_slide.trigger_slide_effect_out(0.4, delay)
		delay += 0.04

func _on_AnimationPlayer_animation_finished(anim_name):
	var transitions_pair = transitions.get(transition_type, ["slide_right_in", "slide_left_out"])
	if anim_name == transitions_pair[0]:
		get_tree().change_scene(next_scene)
		duration_timer.start()
	elif anim_name == transitions_pair[1]:
		transition_running = false

# Transition out runs after this timer
func _on_DurationTimer_timeout():
	var transitions_pair = transitions.get(transition_type, ["slide_right_in", "slide_left_out"])
	animation_player.play(transitions_pair[1])
