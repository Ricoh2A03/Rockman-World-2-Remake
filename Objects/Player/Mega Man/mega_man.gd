extends Player

func _on_step_timeout():
	is_step = false

func _on_slide_timeout() -> void:
	if is_on_floor() and !ceiling:
		sprite_controller.play_animation("slide_end")
		velocity.x = 0
		_change_state(STATES.GROUND)

func _on_animation_finished() -> void:
	match sprite_controller.get_current_animation():

		"teleport":
			_change_state(STATES.GROUND)

		"land":
			sprite_controller.play_animation("idle")

		"slide_end":
			sprite_controller.play_animation("idle")

		"hurt":
			if is_on_floor(): _change_state(STATES.GROUND)
			else: _change_state(STATES.AIR)
