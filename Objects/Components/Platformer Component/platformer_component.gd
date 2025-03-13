class_name PlatformerComponent extends Node2D

@export var parent: CharacterBody2D

@export_category("Physics Values")
@export var gravity: int = 0
@export var terminal_velocity: int = 0

var _current_hor_velocity: int = 0
var _current_gravity: int = 0
var _direction: int = 1

func _process(_delta: float) -> void:
	if !parent: return
	parent.velocity.x = _current_hor_velocity * _direction
	parent.velocity.y += _current_gravity

func jump(force: int) -> void:
	parent.velocity.y = -force

func set_direction(value) -> void: _direction = value
func get_direction() -> int: return _direction

func set_velocity(value) -> void: _current_hor_velocity = value
func get_velocity() -> int: return _current_hor_velocity
