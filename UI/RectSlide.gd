extends ColorRect

onready var slide_tween : Tween = $SlideTween

onready var initial_size = Vector2(self.rect_size.x, self.rect_size.y)

func trigger_slide_effect_out(duration: float = 1.0, delay: float = 0) -> void:
	slide_tween.stop_all()
	show()
	if delay > 0:
		yield(get_tree().create_timer(delay, false), "timeout")
	slide_tween.interpolate_property(self, "rect_size:y", initial_size.y, 0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	slide_tween.start()

func trigger_slide_effect_in(duration: float = 1.0, delay: float = 0) -> void:
	slide_tween.stop_all()
	show()
	if delay > 0:
		yield(get_tree().create_timer(delay, false), "timeout")
	slide_tween.interpolate_property(self, "rect_size:y", 0, initial_size.y, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	slide_tween.start()

func set_full_size(flag: bool) -> void:
	slide_tween.stop_all()
	if flag:
		show()
		rect_size.y = initial_size.y
	else:
		hide()
		rect_size.y = 0
