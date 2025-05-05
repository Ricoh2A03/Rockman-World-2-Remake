extends Player

func _on_slide_timeout() -> void:
	if is_on_floor() and !ceiling:
		can_shoot = true
		sprite_controller.play_animation("slide_end")
		velocity.x = 0
		state_machine.current_state.next_state = $PlayerStateMachine/StateGround

func _on_animation_finished() -> void:
	match sprite_controller.get_current_animation():

		"teleport":
			#apply_gravity = true
			#can_shoot = true
			#state = STATES.GROUND
			pass

		"land":
			sprite_controller.play_animation("idle")

		"slide_end":
			sprite_controller.play_animation("idle")

		"hurt":
			#allow_movement = true
			#can_shoot = true
			#state = STATES.GROUND
			pass
