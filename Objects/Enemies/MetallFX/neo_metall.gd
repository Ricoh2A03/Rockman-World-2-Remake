extends Enemy

func _ready() -> void:
	if self.global_position.x > _player_reference.global_position.x: platform_component.set_direction(-1)
	else: platform_component.set_direction(1)

func _process(delta: float) -> void:
	if !health_component.is_dead():
		if platform_component._direction < 0: sprite_controller.flip_sprite_h(false)
		else: sprite_controller.flip_sprite_h(true)
		move_and_slide()

func _on_no_health():
	sprite_controller.play_animation("explode")

func _on_animation_finished():
	if sprite_controller.get_current_animation() == "explode":
		call_deferred("queue_free")
		# NOTE: make so that when enemy dies, it emits a signal that tells
		# the spawner that it's dead and it should be erased from it's object list.
