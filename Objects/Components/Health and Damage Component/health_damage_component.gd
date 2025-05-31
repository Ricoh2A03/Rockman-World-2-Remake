class_name HealthDamageComponent extends Node2D

## Emits when there's no health left.
signal no_health

@export var parent_node: Node

@export_category("Health")
@export_range(0, 280) var max_health: int = 0
var _current_health: int
var _is_dead: bool = false
var _can_deflect: bool = false

@export_category("Damage Table")
@export var damage_table: DamageTable

@export_category("Sounds")
@export var damage_sound: AudioStreamWAV
@export var destroyed_sound: AudioStreamWAV

@onready var hitbox_shape: CollisionShape2D = $Hitbox/Shape
@onready var snd_damage: AudioStreamPlayer2D = $snd_damage
@onready var snd_destroyed: AudioStreamPlayer2D = $snd_destroyed


func _ready() -> void:
	_current_health = max_health
	snd_damage.stream = damage_sound
	snd_destroyed.stream = destroyed_sound


## Sets health to a passed value.
func set_health(value: int) -> void: _current_health = value


## Returns current health.
func get_health() -> int: return _current_health


## Returns if dead or not.
func is_dead() -> bool: return _is_dead


func _on_hitbox_entered(area: Area2D) -> void:
	if _is_dead: return
	var obj = area.get_parent()
	if obj is BasicProjectile:
		if _can_deflect == false:
			_get_damage(damage_table.table[obj.get_id()])
		else:
			pass


func _get_damage(value: int):
	_current_health -= value
	#print(_current_health)
	if _current_health <= 0:
		hitbox_shape.set_deferred("disabled", true)
		_is_dead = true
		no_health.emit()
		#print("dead")
	if value > _current_health: snd_destroyed.play()
	else: snd_damage.play()


func set_deflect_state(deflect: bool) -> void:
	_can_deflect = deflect


func get_deflect_state() -> bool:
	return _can_deflect
