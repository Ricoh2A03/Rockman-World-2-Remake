class_name BasicProjectile extends Node2D

signal screen_exited()

@export var xSpeed: int = 0
@export var ySpeed: int = 0

@export var gravity: int = 0
@export var apply_gravity: bool = false

var _direction: int = 1

func set_direction(dir: int) -> void: _direction = dir

func _process(delta: float) -> void:
	pass
