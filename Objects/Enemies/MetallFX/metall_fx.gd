extends Enemy

func _ready() -> void:
	platform_component.set_direction(initial_direction)
	platform_component.set_velocity(hor_speed)

func _process(delta: float) -> void:
	move_and_slide()
