extends Enemy


func _ready() -> void:
	platform_component.set_direction(-1)
	platform_component.set_velocity(self.hor_speed)


func _process(delta: float) -> void:
	move_and_slide()


func _on_no_health() -> void:
	sprite_controller.play_animation("explode")


func _on_animation_finished() -> void:
	if sprite_controller.get_current_animation() == "explode":
		enemy_died.emit(self)
		call_deferred("queue_free")
