class_name Enemy extends CharacterBody2D

@export var sprite_controller: SpriteController
@export var platform_component: PlatformerComponent

@export var initial_direction: int = 1
@export var hor_speed: int = 10

var _direction: int = 1

var _player_reference: Player
