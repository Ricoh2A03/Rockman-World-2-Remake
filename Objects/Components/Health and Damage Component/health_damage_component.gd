class_name HealthDamageComponent extends Node2D

@export var parent_node: Node

@export_category("Health")
@export_range(0, 280) var max_health: int = 0
var _current_health: int
var _is_dead: bool = false

@export_category("Damage Table")
@export var damage_table: DamageTable

func _ready() -> void: _current_health = max_health

func set_health(value: int) -> void: _current_health = value

func get_health() -> int: return _current_health

func _on_hitbox_entered(area: Area2D) -> void:
	if _is_dead: return
	var obj = area.get_parent()
	if obj is BasicProjectile:
		_get_damage(damage_table.table[obj.get_id()])

func _get_damage(value: int):
	_current_health -= value
	print(_current_health)
	if _current_health <= 0:
		_is_dead = true
		print("dead")
