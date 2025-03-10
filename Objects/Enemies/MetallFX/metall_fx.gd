extends Enemy

func _ready() -> void:
	if self.global_position.x > _player_reference.global_position.x: platform_component.set_direction(-1)
	else: platform_component.set_direction(1)

func _process(delta: float) -> void:
	if _direction < 0: sprite_controller.flip_sprite_h(false)
	else: sprite_controller.flip_sprite_h(true)
	move_and_slide()
