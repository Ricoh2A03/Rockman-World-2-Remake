class_name VariableWeaponSystem extends Node2D

@export var player: Player

@export var current_item: InventoryItem

@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
@onready var animation_cooldown_timer: Timer = $AnimationCooldown

var _on_screen_count: Array = []

func _process(_delta: float) -> void:
	# Shoot only if player is not paused and can_shoot
	if (player.can_shoot and Input.is_action_just_pressed("shoot")):
		if player._current_state == player.STATES.CLIMB:
			player.flip_sprite()
		spawn_projectile()

func spawn_projectile() -> void:

	if _on_screen_count.size() == current_item.max_on_screen: return

	player.set_shoot_state(true)

	# Set animation cooldown to that of a current weapon.
	animation_cooldown_timer.wait_time = current_item.cooldown

	var instance = current_item.scene_to_spawn.instantiate() # instantiate projectile
	instance.connect("screen_exited", projectile_despawned) # connect signals

	_on_screen_count.append(instance) # add to the on screen list

	player.get_parent().call_deferred("add_child", instance) # add as a sibling of the Player
	instance.global_position.x = player.global_position.x + current_item.XSpawnOffset * player.direction # set position to the Player position
	instance.global_position.y = player.global_position.y + current_item.YSpawnOffset
	instance.set_direction(player.direction) # set direction to the Player direction

	for anim in current_item.animate_state:
		if player.sprite_controller.get_current_animation() == anim:
			player.sprite_controller.sprite_normal.frame = 0
			player.sprite_controller.sprite_shoot.frame = 0
			player.sprite_controller.sprite_shoot.play(anim + "_shoot")
	player.sprite_controller.enable_sprite(false, true)
	animation_cooldown_timer.start()

	sfx_player.stream = current_item.sound # load sound
	sfx_player.play() # play sound

func projectile_despawned():
	if _on_screen_count.size() > 0: _on_screen_count.erase(_on_screen_count.front())

func pause_cooldown_timer(pause: bool):
	animation_cooldown_timer.paused = pause

##########################################

func _on_animation_cooldown() -> void:
	player.set_shoot_state(false)
	if player.get_player_state() == player.STATES.CLIMB:
		player.sprite_controller.sprite_normal.frame = 0
	player.sprite_controller.enable_sprite(true)
