class_name Enemy extends CharacterBody2D

signal enemy_died

@export var sprite_controller: SpriteController
@export var health_component: HealthDamageComponent
@export var platform_component: PlatformerComponent

@export var hor_speed: int = 0

enum STATES{}
var _current_state: int

var _player_reference: Player

func look_at_player():
	if self.global_position.x > _player_reference.global_position.x: platform_component.set_direction(-1)
	else: platform_component.set_direction(1)
