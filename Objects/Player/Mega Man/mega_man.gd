extends Player


func _on_step_timeout():
	_is_stepping = false


func _on_slide_timeout() -> void:
	if is_on_floor() and !_is_under_ceiling:
		sprite_controller.play_animation("slide_end")
		velocity.x = 0
		set_player_state(STATES.GROUND)


func _on_animation_finished() -> void:
	match sprite_controller.get_current_animation():

		"teleport":
			set_player_state(STATES.GROUND)

		"land":
			sprite_controller.play_animation("idle")

		"slide_end":
			sprite_controller.play_animation("idle")

		"hurt":
			if is_on_floor(): set_player_state(STATES.GROUND)
			else: set_player_state(STATES.AIR)
