extends Player

func _on_step_timeout():
	is_step = false

func _on_slide_timeout() -> void:
	if is_on_floor() and !ceiling:
		can_shoot = true
		sprite_controller.play_animation("slide_end")
		velocity.x = 0
		state = STATES.GROUND

func _on_animation_finished() -> void:
	match sprite_controller.get_current_animation():

		"teleport":
			apply_gravity = true
			can_shoot = true
			state = STATES.GROUND

		"land":
			sprite_controller.play_animation("idle")

		"slide_end":
			sprite_controller.play_animation("idle")
