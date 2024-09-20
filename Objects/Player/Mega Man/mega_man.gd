extends Player

func _on_step_timeout():
	is_step = false

func _on_slide_timeout() -> void:
	if is_on_floor() and !ceiling:
		state = STATES.GROUND
