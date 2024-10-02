extends Player

func _on_step_timeout():
	is_step = false

func _on_slide_timeout() -> void:
	if is_on_floor():
		sprite_controller.play_animation("slide_end")
		velocity.x = 0
		state = STATES.GROUND

func _on_animation_finished() -> void:
	if sprite_controller.get_current_animation() == "teleport":
		state = STATES.GROUND

	if sprite_controller.get_current_animation() == "land":
		sprite_controller.play_animation("idle")

	if sprite_controller.get_current_animation() == "slide_end":
		sprite_controller.play_animation("idle")
