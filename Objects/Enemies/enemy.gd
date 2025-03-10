class_name Enemy extends CharacterBody2D

@export var sprite_controller: SpriteController
@export var health_component: HealthDamageComponent
@export var platform_component: PlatformerComponent

@export var hor_speed: int = 10

var _player_reference: Player
