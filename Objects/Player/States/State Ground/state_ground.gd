extends PlayerState

@export var state_air: PlayerState
@export var state_slide: PlayerState

var can_step: bool = true
var is_step: bool = false

func _on_enter() -> void:
	ptr_player.set_collision_shapes("normal")
	if !ptr_player.move_vector:
		can_step = true
		is_step = false
	#elif ptr_player.move_vector and get_parent().previous_state != state_slide:
		#can_step = false
		#is_step = false

func _update_state(delta) -> void:

	if ptr_player.velocity.x != 0:
		if is_step:
			ptr_player.sprite_controller.play_animation("step")
		else: 
			ptr_player.sprite_controller.play_animation("walk")
	else: # Idle animation ONLY if not sliding / landing / ending slide
		if ptr_player.sprite_controller.get_current_animation() != "land" and \
		   ptr_player.sprite_controller.get_current_animation() != "slide_end" and \
		   ptr_player.sprite_controller.get_current_animation() != "slide":
				ptr_player.sprite_controller.play_animation("idle")

	if Input.is_action_just_pressed("slide"):
		next_state = state_slide

	if Input.is_action_just_pressed("jump"):
		ptr_player.velocity.y = -ptr_player.stats.jump_force
		ptr_player.snd_jump.play()
		next_state = state_air

	if !ptr_player.is_on_floor(): next_state = state_air

	if ptr_player.move_vector:
		if can_step:
			is_step = true
			can_step = false
			ptr_player.step_timer.start()
		if is_step: ptr_player.velocity.x = ptr_player.move_vector * ptr_player.stats.step_speed
		else: ptr_player.velocity.x = ptr_player.move_vector * ptr_player.stats.horizontal_speed
	else:
		ptr_player.velocity.x = move_toward(ptr_player.velocity.x, 0, ptr_player.stats.horizontal_speed)
		can_step = true

func _on_step_timeout() -> void:
	is_step = false
