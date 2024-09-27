class_name SpriteController extends Node2D

@export var player: Player

@export_category("Sprite Nodes")
@export var sprite_normal: AnimatedSprite2D
@export var sprite_shoot: AnimatedSprite2D

@export_category("Start Animation")
@export var _start_animation: String
var _current_animation: String
var _state_to_transit: int = -1

func _ready() -> void:
	if sprite_normal and sprite_shoot:
		sprite_normal.animation_finished.connect(_animation_finished)
		sprite_shoot.animation_finished.connect(_animation_finished)
		_current_animation = _start_animation

func enable_sprite(enable_normal: bool, enable_shoot: bool = false) -> void:
	sprite_normal.visible = enable_normal
	sprite_shoot.visible = enable_shoot

func flip_sprite_h(flip: bool) -> void:
	sprite_normal.flip_h = flip
	sprite_shoot.flip_h = flip

func flip_sprite_v(flip: bool) -> void:
	sprite_normal.flip_v = flip
	sprite_shoot.flip_v = flip

func play_animation(animation: String, one_time: bool = false, transit_to_anim: String = "", transit_to_state: int = -1) -> void:
	if one_time:
		if animation != _current_animation:
			_current_animation = animation
			sprite_normal.play(animation)
			if transit_to_state != -1:
				_state_to_transit = 0
	if transit_to_anim != "":
		sprite_normal.play(_current_animation)
	else:
		sprite_normal.play(animation)

func _animation_finished() -> void:
	if _state_to_transit != -1:
		player.set_player_state(_state_to_transit)
		_state_to_transit = -1
