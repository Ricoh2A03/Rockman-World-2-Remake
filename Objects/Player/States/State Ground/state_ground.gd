extends PlayerState

@export var state_air: PlayerState
@export var state_slide: PlayerState

var can_step: bool = true
var is_step: bool = false

func _on_enter() -> void:
	print("GROUND STATE")
	ptr_player.set_collision_shapes("normal")

func _update_state(delta) -> void:
	if can_step and ptr_player.move_vector: # stepping
		is_step = true
		can_step = false
		ptr_player.step_timer.start()

	ptr_player.velocity.x = ptr_player.move_vector * ptr_player.stats.horizontal_speed

	### Set direction ###
	if ptr_player.move_vector == 1: ptr_player.direction = 1
	elif ptr_player.move_vector == -1: ptr_player.direction = -1
