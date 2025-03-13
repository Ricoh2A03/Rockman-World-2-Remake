class_name SpriteController extends Node2D

## Reference for parent node.
#@export var parent: Node2D

@export_category("Sprite Nodes")
## Reference to normal sprite.
@export var sprite_normal: AnimatedSprite2D
## Reference to shooting sprite.
@export var sprite_shoot: AnimatedSprite2D

var _current_animation: String

## Toggle normal
func enable_sprite(enable_normal: bool, enable_shoot: bool = false) -> void:
	sprite_normal.visible = enable_normal
	if !sprite_shoot: return
	sprite_shoot.visible = enable_shoot

func flip_sprite_h(flip: bool) -> void:
	sprite_normal.flip_h = flip
	if !sprite_shoot: return
	sprite_shoot.flip_h = flip

func flip_sprite_v(flip: bool) -> void:
	sprite_normal.flip_v = flip
	if !sprite_shoot: return
	sprite_shoot.flip_v = flip

func play_animation(animation: String) -> void:
	if animation != _current_animation:
		_current_animation = animation
		sprite_normal.frame = 0
		sprite_normal.play(animation)
		if !sprite_shoot: return
		sprite_shoot.frame = 0
		sprite_shoot.play(animation)

func get_current_animation(_normal: bool = true) -> String: return _current_animation

## Sets playback speed of the animation.
func set_speed_scale(speed: float) -> void:
	sprite_normal.speed_scale = speed
	if !sprite_shoot: return
	sprite_shoot.speed_scale = speed

func pause_playback(pause: bool) -> void:
	if pause:
		sprite_normal.pause()
		if !sprite_shoot: return
		sprite_shoot.pause()
	else:
		sprite_normal.play()
		if !sprite_shoot: return
		sprite_shoot.play()
