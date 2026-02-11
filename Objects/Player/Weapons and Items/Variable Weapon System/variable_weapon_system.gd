class_name VariableWeaponSystem extends Node2D

@export var player: Player
@export var current_item: InventoryItem

@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
@onready var animation_cooldown_timer: Timer = $AnimationCooldown


var _can_shoot: bool = false
var _is_shooting: bool = false

var _on_screen_count: Array = []
var _loaded_projectile: PackedScene


func _ready() -> void:
	set_current_item(current_item)


# TODO: separate more from player
func spawn_projectile() -> void:
	# skip if Player is invalid or if max projectiles
	if !player: return
	if _on_screen_count.size() == current_item.max_on_screen: return

	_is_shooting = true

	# Set animation cooldown to that of a current weapon.
	animation_cooldown_timer.wait_time = current_item.cooldown

	var instance = _loaded_projectile.instantiate()
	# connect signals
	instance.connect("screen_exited", projectile_despawned)

	# add to the on screen list
	_on_screen_count.append(instance)

	# add as a sibling of the Player
	player.get_parent().call_deferred("add_child", instance)
	# set position to the Player position
	instance.global_position.x = player.global_position.x + current_item.XSpawnOffset * player._direction
	instance.global_position.y = player.global_position.y + current_item.YSpawnOffset
	# set direction to the Player direction
	instance.set_direction(player._direction)

	for anim in current_item.animate_state:
		if player.sprite_controller.get_current_animation() == anim:
			player.sprite_controller.sprite_normal.frame = 0
			player.sprite_controller.sprite_shoot.frame = 0
			player.sprite_controller.sprite_shoot.play(anim + "_shoot")
	player.sprite_controller.enable_sprite(false, true)
	animation_cooldown_timer.start()

	sfx_player.stream = current_item.sound # load sound
	sfx_player.play() # play sound


## Loads passed [param InventoryItem] and caches it in a variable.
func set_current_item(item: InventoryItem) -> void:
	_loaded_projectile = load(item.scene_to_spawn)


## Returns current shooting state.
func get_shooting_state() -> bool:
	return _is_shooting


## Returns [param true] if can shoot.
func get_can_shoot() -> bool:
	return _can_shoot


## Self explanatory.
func set_can_shoot(can_shoot: bool) -> void:
	_can_shoot = can_shoot


func projectile_despawned():
	if _on_screen_count.size() > 0:
		_on_screen_count.erase(_on_screen_count.front())


func pause_cooldown_timer(pause: bool):
	animation_cooldown_timer.paused = pause


# TODO: separate more from player
func _on_animation_cooldown() -> void:
	_is_shooting = false
	if player.get_player_state() == player.STATES.CLIMB:
		player.sprite_controller.sprite_normal.frame = 0
	player.sprite_controller.enable_sprite(true)
