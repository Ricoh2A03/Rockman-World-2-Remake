extends Enemy

func _ready() -> void:
	look_at_player()

func _process(delta: float) -> void:
	if !health_component.is_dead():
		if platform_component._direction < 0: sprite_controller.flip_sprite_h(false)
		else: sprite_controller.flip_sprite_h(true)
		move_and_slide()

func _on_no_health():
	sprite_controller.play_animation("explode")

func _on_animation_finished():
	if sprite_controller.get_current_animation() == "explode":
		destroy_enemy()
		# NOTE: make so that when enemy dies, it emits a signal that tells
		# the spawner that it's dead and it should be erased from it's object list.

func _on_screen_exited() -> void:
	destroy_enemy()
