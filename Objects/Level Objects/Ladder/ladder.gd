extends Area2D
class_name Ladder

@export var ladder_texture: TextureRect
@export var shape: CollisionShape2D

#@export var one_way: StaticBody2D

@export_range(1, 512) var ladder_size: int

var on_top := false

func _enter_tree() -> void:
	ladder_texture.size.y = ladder_size * 16
	shape.shape.size.y = ladder_size * 16
	shape.position.y = ($shape.shape.size.y / 2) - 8

###########################################

#func rotate_top(rot: bool) -> void:
	#if rot and on_top: one_way.rotation_degrees = 180
	#elif !rot: one_way.rotation_degrees = 0

#func change_ladder_texture(value):
	#rect.position.x = -8
	#rect.position.y = -8
	#rect.size.x = 16
	#rect.size.y = 16
	#rect.texture = ladder_texture

###########################################

func _on_ladder_top_entered(body):
	body.on_ladder_top = true
	on_top = true

func _on_ladder_top_exited(body):
	body.on_ladder_top = false
	on_top = false
	#rotate_top(false)
