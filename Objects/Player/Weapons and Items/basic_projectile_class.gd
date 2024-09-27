class_name BasicProjectile extends Node2D

signal screen_exited()

@export var xSpeed: int = 0
@export var ySpeed: int = 0

var direction: int = 1

var is_paused: bool = false

func set_direction(dir: int) -> void:
	direction = dir

func _process(delta: float) -> void:
	pass

func menu_pause(paused: bool):
	self.is_paused = paused
