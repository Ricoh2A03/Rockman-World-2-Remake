extends PlayerState

@export var state_ground: PlayerState
@export var state_air: PlayerState

func _on_enter() -> void:
	ptr_player.set_collision_shapes("slide")
	ptr_player.velocity.x = ptr_player.stats.slide_speed * ptr_player.direction
	ptr_player.slide_timer.start()
	ptr_player.snd_slide.play()
	ptr_player.sprite_controller.play_animation("slide")

func _update_state(delta) -> void:

	# Cancel slide if pressing the opposite direction
	if !ptr_player.ceiling and ((ptr_player.velocity.x > 0 and Input.is_action_pressed("left")) or \
							  (ptr_player.velocity.x < 0 and Input.is_action_pressed("right"))):
			ptr_player.slide_timer.stop()
			next_state = state_ground
