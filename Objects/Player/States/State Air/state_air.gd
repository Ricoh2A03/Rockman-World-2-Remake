extends PlayerState

@export var state_ground: PlayerState

func _on_enter() -> void:
	ptr_player.set_collision_shapes("normal")
	if ptr_player.velocity.y < 0: ptr_player.sprite_controller.play_animation("jump")
	else: ptr_player.sprite_controller.play_animation("fall")

func _update_state(delta) -> void:
	if ptr_player.velocity.y < 0 and !Input.is_action_pressed("jump"):
		ptr_player.velocity.y += ptr_player.stats.gravity * 3.25 # Stronger Gravity
		ptr_player.velocity.y = 0

	if ptr_player.move_vector:
		ptr_player.velocity.x = ptr_player.move_vector * ptr_player.stats.horizontal_speed
	else:
		ptr_player.velocity.x = move_toward(ptr_player.velocity.x, 0, ptr_player.stats.horizontal_speed)

	if ptr_player.move_vector == 1: ptr_player.direction = 1
	elif ptr_player.move_vector == -1: ptr_player.direction = -1

	ptr_player.velocity.y += 1
	ptr_player._terminal_Y_velocity()

	if ptr_player.is_on_floor():
		ptr_player.sprite_controller.play_animation("land")
		ptr_player.snd_land.play()
		next_state = state_ground
