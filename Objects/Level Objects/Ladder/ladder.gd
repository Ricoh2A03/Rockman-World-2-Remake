@tool
extends Area2D
class_name Ladder

@export var ladder_texture: TextureRect
@export var shape: CollisionShape2D


@export_range(1, 512) var ladder_size: int = 1:
	set(value):
		ladder_size = value
		_set_ladder_length()


var on_top: bool = false


func _enter_tree() -> void:
	ladder_texture.size.y = ladder_size * 16
	shape.shape.size.y = ladder_size * 16
	shape.position.y = ($shape.shape.size.y / 2) - 8


func _set_ladder_length() -> void:
	if Engine.is_editor_hint():
		ladder_texture.size.y = ladder_size * 16
		shape.shape.size.y = ladder_size * 16
		shape.position.y = ($shape.shape.size.y / 2) - 8


func _on_ladder_top_entered(body):
	body._on_ladder_top = true
	on_top = true


func _on_ladder_top_exited(body):
	body._on_ladder_top = false
	on_top = false
