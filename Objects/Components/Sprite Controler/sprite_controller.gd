class_name SpriteController extends Node2D

@export var player: Player

@export_category("Sprite Nodes")
@export var sprite_normal: AnimatedSprite2D
@export var sprite_shoot: AnimatedSprite2D

var _current_animation: String

func enable_sprite(enable_normal: bool, enable_shoot: bool = false) -> void:
	sprite_normal.visible = enable_normal
	sprite_shoot.visible = enable_shoot

func flip_sprite_h(flip: bool) -> void:
	sprite_normal.flip_h = flip
	sprite_shoot.flip_h = flip

func flip_sprite_v(flip: bool) -> void:
	sprite_normal.flip_v = flip
	sprite_shoot.flip_v = flip

func play_animation(animation: String) -> void:
	if animation != _current_animation:
		_current_animation = animation
		sprite_normal.play(animation)
		sprite_shoot.play(animation)

func get_current_animation(normal: bool = true) -> String: return _current_animation

func set_speed_scale(scale: float) -> void:
	sprite_normal.speed_scale = scale
	sprite_shoot.speed_scale = scale

func pause_playback(pause: bool) -> void:
	if pause:
		sprite_normal.pause()
		sprite_shoot.pause()
	else:
		sprite_normal.play()
		sprite_shoot.play()
