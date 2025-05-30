extends Enemy

# SIGNALS

# ENUMS
enum STATES{
	HIDING,
	REVEALING,
	CHASING,
	RETREATING
}

# CONSTANTS

# STATIC VARS

# EXPORT VARS

# ONREADY VARS
@onready var vision_area: Area2D = $VisionArea

# PUBLIC VARS

# PRIVATE VARS

# BUILT-IN METHODS
func _enter_tree() -> void:
	set_state(STATES.HIDING)


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	match _current_state:

		STATES.HIDING:
			pass

		STATES.CHASING:
			var move_dir = distance_between_player()

			velocity = lerp(velocity, move_dir.normalized() * 50, 0.75)

	move_and_slide()


# METHODS
func set_state(to_state: int) -> void:
	if to_state == _current_state: return
	match to_state:
		0: # Hiding
			health_component.set_deflect_state(true)
			vision_area.set_deferred("monitoring", true)
		1: # Revealing
			pass
		2: # Chasing
			sprite_controller.play_animation("fly")
			%AnimationPlayer.play("bobbing")
		3: # Retreating
			pass

	_current_state = to_state


# SIGNAL METHODS
func _on_vision_area_entered(body: Node2D) -> void:
	if body is Player: self._player_reference = body
	vision_area.set_deferred("monitoring", false)
	sprite_controller.play_animation("reveal")


func _on_sprite_animation_finished() -> void:
	match $SpriteController/Anchor/Sprite.animation:
		"reveal":
			set_state(STATES.CHASING)


func _on_screen_exited() -> void:
	destroy_enemy()


func _on_health():
	destroy_enemy()
