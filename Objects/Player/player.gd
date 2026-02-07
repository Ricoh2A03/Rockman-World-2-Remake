class_name Player extends CharacterBody2D


#region Enumerators
## Player states enumerator.[br]
## 0 - Ground[br]
## 1 - Air[br]
## 2 - Climb[br]
## 3 - Slide[br]
## 4 - Dash[br]
## 5 - Hurt[br]
## 6 - Scroll[br]
## 7 - Teleport in[br]
## 8 - Teleport out[br]
## 9 - Dead[br]
enum STATES{
	GROUND,
	AIR,
	CLIMB,
	SLIDE,
	DASH,
	HURT,
	SCROLL,
	TELEPORT_IN,
	TELEPORT_OUT,
	DEAD
}
#endregion


#region Exported Properties
@export_category("Player Stats")
## [param Resource] that contains all of the values that are relevant to physics.
@export var stats: PlayerStats # player stat resource

@export_category("Dependent Nodes")
## Node which controls normal and shooting sprites.
@export var sprite_controller: SpriteController
## Timer which determines duration of the stepping.
@export var step_timer: Timer
## Same as with [param step_timer].
@export var slide_timer: Timer
## Collision box for all states except SLIDE.
@export var collision_normal: CollisionShape2D
## Self-explanatory.
@export var collision_slide: CollisionShape2D

## Contains and manages weapons and utilities.
@export var weapon_system: VariableWeaponSystem

@export var weapon_ui: WeaponUI

@export_group("Explosion")
@export var death_explosion_fx: PackedScene

@export_group("Sound Nodes")
@export var snd_jump: AudioStreamPlayer2D
@export var snd_land: AudioStreamPlayer2D
@export var snd_slide: AudioStreamPlayer2D
@export var snd_damage: AudioStreamPlayer2D
@export var snd_teleport_in: AudioStreamPlayer
@export var snd_teleport_out: AudioStreamPlayer
@export var snd_death: AudioStreamPlayer

@export_group("Physics Toggles")
## Whether or not the gravity should be applied. 
@export var apply_gravity: bool = true
## Set to true to ignore control from the player.
@export var can_move: bool = true
## Whether or not physics should be processed.
@export var call_move_and_slide: bool = true
#endregion


var weapon_inventory


var _can_change_direction: bool = true
var _can_step: bool = true
var _is_stepping: bool = false
var _is_under_ceiling: bool = false
var _was_under_ceiling: bool = false

var _can_shoot: bool = false
var _is_shooting: bool = false

var _on_ladder: bool = false
var _on_ladder_top: bool = false
var _current_ladder: Ladder

var _can_open_inventory: bool = false

var _direction: int = 1

## The last state that the player was in.
var _last_state = null
## Current player state.
var _current_state = null

## Left, top, right, bottom.
var _room_limits: Array[int] = [0, 0, 0, 0]


#region Initialization routine
func _ready() -> void:
	EventBus.stage_event_scroll_start.connect(_scroll_handler)
	EventBus.stage_event_scroll_finished.connect(_scrolling_finished)
	set_player_state(STATES.TELEPORT_IN)
	flip_sprite()
#endregion


#region Input handler
func _input(event):
#	if event.is_action_pressed("debug_damage_player"):
#		_current_state = STATES.HURT
#		snd_damage.play()
#		sprite_controller.play_animation("hurt")

	if _can_open_inventory and event.is_action_pressed("START"):
		weapon_ui.open_weapon_menu()
#endregion


#region Update routine
func _process(delta) -> void:

	if apply_gravity:
		if _current_state != STATES.SCROLL: velocity.y += stats.gravity * delta

	if call_move_and_slide: move_and_slide()

	if _can_shoot: _use_weapon()
	if _can_open_inventory: pass

	var move_vector

	### Ignore horizontal input if hurt or climbing ###
	if _current_state != STATES.CLIMB or STATES.HURT or STATES.SCROLL: move_vector = Input.get_axis("LEFT", "RIGHT")

	if can_move:

		### Horizontal Movement ###
		if move_vector:
			if _current_state == STATES.GROUND and _is_stepping: ### Step Velocity ###
				velocity.x = move_vector * stats.step_speed
			elif _current_state == STATES.GROUND or _current_state == STATES.AIR: ### Ground Velocity ###
				velocity.x = move_vector * stats.horizontal_speed

		else:
			### Apply velocity regardless of input if sliding ###
			if _current_state != STATES.SLIDE: velocity.x = move_toward(velocity.x, 0, stats.horizontal_speed)
			### Allow stepping if stopped ###
			if _current_state == STATES.GROUND: _can_step = true

	### Set _direction ###
	if _can_change_direction:
		if move_vector == 1: _direction = 1
		elif move_vector == -1: _direction = -1

		match _current_state:

#region Ground State
			STATES.GROUND:

				if _can_step and move_vector: # stepping
					_is_stepping = true
					_can_step = false
					step_timer.start()

				### Animations ###
				if velocity.x != 0:
					if _is_stepping:
						sprite_controller.play_animation("step")
					else: 
						sprite_controller.play_animation("walk")
				else: # Idle animation ONLY if not sliding / landing / ending slide
					if sprite_controller.get_current_animation() != "land" and \
					   sprite_controller.get_current_animation() != "slide_end" and \
					   sprite_controller.get_current_animation() != "slide":
						sprite_controller.play_animation("idle")

				### Ground --> Climb ###
				if !_on_ladder_top and (_on_ladder and Input.is_action_pressed("UP")):
					set_player_state(STATES.CLIMB)
				if _on_ladder_top and (_on_ladder and Input.is_action_pressed("DOWN")):
					sprite_controller.play_animation("climb")
					set_player_state(STATES.CLIMB)
					global_position.y = (_current_ladder.global_position.y - 8)

				### Jumping --> Air ###
				if Input.is_action_just_pressed("B"):
					velocity.y = -stats.jump_force
					snd_jump.play()
					set_player_state(STATES.AIR)
					sprite_controller.play_animation("jump")

				### Not floor --> Air ###
				if !is_on_floor(): set_player_state(STATES.AIR)

				### Ground --> Slide ###
				if Input.is_action_just_pressed("A"):
					sprite_controller.play_animation("slide")
					snd_slide.play()
					set_player_state(STATES.SLIDE)

				flip_sprite()
#endregion

#region Air State
			STATES.AIR:
				set_collision_shapes("normal")

				### Variable Jump Height ###
				if velocity.y < 0 and !Input.is_action_pressed("B"):
					velocity.y += stats.gravity * 3.25 # Stronger Gravity
					velocity.y = 0

				if velocity.y > 0:
					sprite_controller.play_animation("fall")

				### --> Ground ###
				if is_on_floor():
					set_player_state(STATES.GROUND)
					sprite_controller.play_animation("land")
					snd_land.play()
					_can_step = false

				### -- > Climb ###
				if _current_ladder != null and _on_ladder:
					if global_position.y >= ((_current_ladder.global_position.y - 8) - \
					(collision_normal.shape.size.y * 0.5)) and (_on_ladder and (Input.is_action_pressed("UP"))):
						sprite_controller.play_animation("climb")
						set_player_state(STATES.CLIMB)

				velocity.y += 1

				flip_sprite()

				_terminal_Y_velocity()
#endregion

#region Slide State
			STATES.SLIDE:

				if !_is_under_ceiling and ((velocity.x > 0 and Input.is_action_pressed("LEFT")) or \
										   (velocity.x < 0 and Input.is_action_pressed("RIGHT"))):
					#slide_timer.stop() # TODO ???
					set_player_state(STATES.GROUND)

				### Slide --> Air ###
				if !is_on_floor():
					slide_timer.stop()
					sprite_controller.play_animation("fall")
					set_player_state(STATES.AIR)

				#### Slide --> Ground ###
				#if slide_timer.time_left == 0 and !_is_under_ceiling: # !!!
					## BUG !!!!!!!!
					## Fall animation in the air
					#_can_shoot = true

				### Jumping --> Air ###
				if !_is_under_ceiling and Input.is_action_just_pressed("B"):
					sprite_controller.play_animation("jump")
					slide_timer.stop()
					velocity.y = -stats.jump_force
					snd_jump.play()
					set_player_state(STATES.AIR)

				velocity.x = _direction * stats.slide_speed

				flip_sprite()
#endregion

#region Hurt State
			STATES.HURT: pass
#endregion

#region Climb State
			STATES.CLIMB:
				if _on_ladder_top: sprite_controller.play_animation("climb_end")
				else: sprite_controller.play_animation("climb")

				var climb_vector = Input.get_axis("UP", "DOWN")

				if !_on_ladder:
					set_player_state(STATES.AIR)
					sprite_controller.set_speed_scale(1.0)

				global_position.x = _current_ladder.global_position.x

				if climb_vector != 0 and !_is_shooting:
					if climb_vector < 0:
						sprite_controller.set_speed_scale(1.0)
						velocity.y = -(stats.climb_speed)
					elif climb_vector > 0:
						sprite_controller.set_speed_scale(-1.0)
						velocity.y = stats.climb_speed
				else:
					sprite_controller.set_speed_scale(0.0)
					velocity.y = 0

				### Ground if at the top of a ladder ###
				if (global_position.y) + 6 <= (_current_ladder.global_position.y - 8) and Input.is_action_pressed("UP"):
					set_player_state(STATES.GROUND)
					velocity.y = 0
					global_position.y = (_current_ladder.global_position.y - 8) - (collision_normal.shape.size.y * 0.5)
					sprite_controller.set_speed_scale(1.0)

				### Ground if on floor ###
				if is_on_floor() and velocity.y > 0:
					velocity.y = 0
					set_player_state(STATES.GROUND)
					sprite_controller.set_speed_scale(1.0)

				### Air if jump off ladder ###
				if Input.is_action_just_pressed("B") and velocity.y == 0:
					velocity.y = 0
					set_player_state(STATES.AIR)
					sprite_controller.set_speed_scale(1.0)

				if _is_shooting: flip_sprite()

#endregion

#region Teleport State
			STATES.TELEPORT_IN: pass
#endregion

#region Dead State
			STATES.DEAD: pass
#endregion

	_check_room_transition()
	_stop_at_room_limits()

	if Input.is_action_just_pressed("DEBUG_KILL_PLAYER"): death_proccessing(false)
#endregion


#region Setters and Getters
# STATE
func get_player_state() -> int: return _current_state
func set_player_state(to_state: int) -> void:
	# STATES # remove this later
	if to_state == _current_state: return
	match to_state:
		0: # Ground
			set_collision_shapes("normal")
			_can_open_inventory = true
			_can_shoot = true
			apply_gravity = true
			can_move = true
			_can_change_direction = true
			call_move_and_slide = true
		1: # Air
			set_collision_shapes("normal")
			_can_open_inventory = true
			_can_shoot = true
			apply_gravity = true
			can_move = true
			_can_change_direction = true
			call_move_and_slide = true
		2: # Climb
			set_collision_shapes("normal")
			_can_open_inventory = true
			_can_shoot = true
			apply_gravity = false
			can_move = false
			_can_change_direction = true
			call_move_and_slide = true
		3: # Slide
			set_collision_shapes("slide")
			_can_open_inventory = true
			_can_shoot = false
			apply_gravity = false
			can_move = true
			_can_change_direction = true
			call_move_and_slide = true
			slide_timer.start()
		5: # Hurt
			velocity.x = 0
			_can_open_inventory = false
			_can_shoot = false
			can_move = false
			_can_change_direction = false
		7: # Teleport in
			set_collision_shapes("normal")
			velocity.y = 0
			_can_open_inventory = false
			_can_shoot = false
			apply_gravity = false
			can_move = false
			_can_change_direction = false
		9: # Dead
			sprite_controller.enable_sprite(false)
			_can_open_inventory = false
			_can_shoot = false
			apply_gravity = false
			can_move = false
			_can_change_direction = false

	_current_state = to_state

# SHOOT
func get_shoot_state() -> bool: return _is_shooting
func set_shoot_state(is_shoot: bool) -> void: _is_shooting = is_shoot

# DIRECTION
func set_direction(dir: int) -> void: _direction = dir

## Enables one collision shape while disabling the other one.[br]
## Pass [param "slide"] to enable sliding collision shape; 
## pass [param "normal"] to enable regular collision shape.
func set_collision_shapes(shape: String) -> void:
	if shape == "slide":
		collision_normal.disabled = true
		collision_slide.disabled = false
	elif shape == "normal":
		collision_slide.disabled = true
		collision_normal.disabled = false

## Sets collision layer and mask based on [param can_collide].
func set_colliders(can_collide: bool) -> void:
	self.set_collision_layer_value(3, can_collide)
	self.set_collision_mask_value(1, can_collide)
#endregion


#region Functions


func _open_inventory() -> void:
	pass


func _use_weapon() -> void:
	if weapon_system:
		if Input.is_action_just_pressed("Y"): weapon_system.spawn_projectile()


func teleport_to(destination: Vector2) -> void:
	sprite_controller.enable_sprite(true) ##
	self.visible = true
	can_move = true

	# snd_teleport_in.play() # TODO: MOVE TO INITIALIZATION
	set_player_state(STATES.TELEPORT_IN)
	set_colliders(false)
	sprite_controller.play_animation("teleport")
	sprite_controller.set_speed_scale(0.0)

	self.global_position = \
	Vector2(destination.x, _room_limits[1] - (collision_normal.shape.size.y / 2))

	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position:y", destination.y, 0.32)
	await tween.finished

	set_colliders(true)
	sprite_controller.set_speed_scale(1.0)
	sprite_controller.play_animation("teleport")


func flip_sprite() -> void:
	if _direction > 0: sprite_controller.flip_sprite_h(true)
	elif _direction < 0: sprite_controller.flip_sprite_h(false)


func _terminal_Y_velocity() -> void: if velocity.y > 448: velocity.y = 448


func death_proccessing(pit_death: bool = false) -> void:
	if _current_state != STATES.DEAD:
		_can_open_inventory = false
		apply_gravity = false
		_can_shoot = false
		can_move = false
		velocity.x = 0
		velocity.y = 0
		self.visible = false
		snd_death.play()
		if !pit_death:
			var exp_inst = death_explosion_fx.instantiate()
			get_parent().add_sibling(exp_inst)
			exp_inst.global_position = global_position
			exp_inst.trigger_explosion.emit()
		set_player_state(STATES.DEAD)
		EventBus.stage_event_player_died.emit()


func _check_room_transition() -> void:
	if _room_limits == [0, 0, 0, 0]: return
	# TODO make this a flag
	if _current_state != STATES.SCROLL and _current_state != STATES.TELEPORT_IN:
		if global_position.x - 16 < _room_limits[0]:
			EventBus.stage_event_player_at_border.emit(0) # at the left border

		elif global_position.x + 16 > _room_limits[2]:
			EventBus.stage_event_player_at_border.emit(2) # at the right border

		elif (global_position.y >= (_room_limits[3]) and _current_state == 1 and velocity.y > 0) or \
				(global_position.y >= (_room_limits[3]) and _current_state == 2 and velocity.y > 0): # at the bottom border
			EventBus.stage_event_player_at_border.emit(3)

		elif (global_position.y <= _room_limits[1] and _current_state == 2 and velocity.y < 0): # at the top border
			EventBus.stage_event_player_at_border.emit(1)


func _stop_at_room_limits() -> void:
	if _room_limits == [0, 0, 0, 0]: return
	# TODO flag maybe??
	if _current_state != STATES.SCROLL and _current_state != STATES.TELEPORT_IN:
		# TODO: change magic numbers into constants
		if global_position.x - 16 < _room_limits[0]:
			global_position.x = _room_limits[0] + 16
		elif global_position.x + 16 > _room_limits[2]:
			global_position.x = _room_limits[2] - 16

		if global_position.y + (collision_normal.shape.size.y / 2) < _room_limits[1]:
			global_position.y = _room_limits[1] - (collision_normal.shape.size.y / 2 )
			#sprite_controller.enable_sprite(false)
		#else:
			#sprite_controller.enable_sprite(true)
#endregion


#region Event Handlers
func _scroll_handler(scroll_direction: int, room: Room) -> void:
	_can_open_inventory = false
	can_move = false
	slide_timer.paused = true
	weapon_system.pause_cooldown_timer(true)
	var last_x_velocity = velocity.x
	var last_y_velocity = velocity.y
	velocity.x = 0
	velocity.y = 0
	apply_gravity = false
	_last_state = _current_state
	#var last_anim = sprite.animation ##
	var could_shoot = _can_shoot
	_can_shoot = false
	set_player_state(STATES.SCROLL)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	var tarX: float
	var tarY: float

	match scroll_direction:
		0: # left
			tarX = global_position.x - 64.0
		1: # up
			tarY = global_position.y - 20.0
		2: # right
			tarX = global_position.x + 64.0
		3: # down
			tarY = global_position.y + 20.0

	if _last_state == STATES.AIR and (scroll_direction != 1):
		sprite_controller.pause_playback(true)

	if tarX: tween.tween_property(self, "global_position:x", tarX, 0.68)
	if tarY: tween.tween_property(self, "global_position:y", tarY, 0.68)

	await tween.finished

	# Ignore unpausing slide_timer if sliding and under the _is_under_ceiling
	if _current_state != STATES.SLIDE and !_is_under_ceiling: 
		slide_timer.paused = false
	if _last_state == STATES.AIR and scroll_direction == 3:
		velocity.y = last_y_velocity
		velocity.x = 0
	else:
		velocity.x = last_x_velocity
		velocity.y = 0
	set_player_state(_last_state)

	_can_open_inventory = true

	weapon_system.pause_cooldown_timer(false)


func _scrolling_finished(room: Room) -> void: pass
#endregion
