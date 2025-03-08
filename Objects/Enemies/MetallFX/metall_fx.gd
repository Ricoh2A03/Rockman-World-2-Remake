extends CharacterBody2D

@export var initial_direction: int = 1
@export var hor_speed: int = 10

@export var platform_component: PlatformerComponent

func _ready() -> void:
	platform_component.set_direction(initial_direction)
	platform_component.set_velocity(hor_speed)

func _process(delta: float) -> void:
	move_and_slide()
