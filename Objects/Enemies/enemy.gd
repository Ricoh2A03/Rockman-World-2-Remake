class_name Enemy extends CharacterBody2D

signal enemy_died

@export var sprite_controller: SpriteController
@export var health_component: HealthDamageComponent
@export var platform_component: PlatformerComponent

@export var hor_speed: int = 0

var _current_state: int
var _player_reference: Player

## Compares own position with [param Player]'s and sets
## [member platform_components]' direction accordingly.
func look_at_player() -> void:
	if self.global_position.x > _player_reference.global_position.x: platform_component.set_direction(-1)
	else: platform_component.set_direction(1)

## 
func distance_between_player() -> Vector2:
	var vec2: Vector2

	if self.global_position.x < _player_reference.global_position.x:
		vec2.x = 1
	else:
		vec2.x = -1

	if self.global_position.y < _player_reference.global_position.y:
		vec2.y = 1
	else:
		vec2.y = -1

	return vec2

##
func destroy_enemy() -> void:
	enemy_died.emit(self)
	call_deferred("queue_free")
