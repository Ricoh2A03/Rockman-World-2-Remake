class_name Player extends CharacterBody2D

@export_category("Player Stats")
## [param Resource] that contains all of the values that are relevant to physics.
@export var stats: PlayerStats # player stat resource

@export_category("Dependent Nodes")
## Node which controls normal and shooting sprites.
@export var sprite_controller: SpriteController
## Timer which determines duration of the stepping.
@export var step_timer: Timer
## Same as with step_timer.
@export var slide_timer: Timer
## Collision box for all states except SLIDE.
@export var collision_normal: CollisionShape2D # for anything else
## Self-explanatory.
@export var collision_slide: CollisionShape2D # for slide

## Contains and manages weapons and utilities.
@export var weapon_system: VariableWeaponSystem

# Create Inventory Resource, which would hold weapon and utilities class resources
# Weapons and utilities would inherit from the base Item Resource
# Item Resource would contain:
# - reference to animations, if Item requires a unique frames;
# - sounds (if needed);
# - reference to projectiles/utilities to spawn (and customizable amount);
# - inventory icon

var weapon_inventory

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
@export var allow_movement: bool = true
## Self-explanatory.
@export var can_double_jump: bool = false
## Whether or not physics should be processed.
@export var move_and_slide_on: bool = true

var can_step: bool = true
var is_step: bool = false
var ceiling: bool = false
var was_under_ceiling: bool = false

var can_shoot: bool = false
var is_shooting: bool = false

var on_ladder: bool = false
var on_ladder_top: bool = false
var current_ladder: Ladder

var double_jump: bool = true
var direction: int = 1

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

## The last state that the player was in.
var last_state = null
## Current player state.
var state = STATES.TELEPORT_IN

## Left, top, right, bottom.
var room_limits: Array[int] = [0, 0, 0, 0]

#region Initialization routine
func _ready() -> void:
	EventBus.stage_event_scroll_start.connect(_scroll_handler)
	EventBus.stage_event_scroll_finished.connect(_scrolling_finished)
	flip_sprite()
#endregion

#region Input handler
func _input(event):
	if event.is_action_pressed("debug_damage_player"):
		state = STATES.HURT
		snd_damage.play()
		sprite_controller.set_anim_frame(0)
		sprite_controller.play_animation("hurt")
#endregion

#region Update routine
func _process(_delta) -> void:

	if apply_gravity:
		if state != STATES.SCROLL:
			velocity.y += stats.gravity

	if move_and_slide_on:
		move_and_slide()

	var move_vector

	### Ignore horizontal input if hurt or climbing ###
	if state != STATES.CLIMB or STATES.HURT or STATES.SCROLL: move_vector = Input.get_axis("left", "right")

	if allow_movement:

		### Horizontal Movement ###
		if move_vector:
			if state == STATES.GROUND and is_step: ### Step Velocity ###
				velocity.x = move_vector * stats.step_speed
			elif state == STATES.GROUND or state == STATES.AIR: ### Ground Velocity ###
				velocity.x = move_vector * stats.horizontal_speed

			### Set direction ###
			if move_vector == 1 and state != STATES.SCROLL: direction = 1
			elif move_vector == -1 and state != STATES.SCROLL: direction = -1

		else:
			### Apply velocity regardless of input if sliding ###
			if state != STATES.SLIDE: velocity.x = move_toward(velocity.x, 0, stats.horizontal_speed)
			### Allow stepping if stopped ###
			if state == STATES.GROUND: can_step = true

		match state:

#region Ground State
			STATES.GROUND:
				set_collision_shapes("normal")

				if can_step and move_vector: # stepping
					is_step = true
					can_step = false
					step_timer.start()

				### Animations ###
				if velocity.x != 0:
					if is_step:
						sprite_controller.play_animation("step")
					else: 
						sprite_controller.play_animation("walk")
				else: # Idle animation ONLY if not sliding / landing / ending slide
					if sprite_controller.get_current_animation() != "land" and \
					   sprite_controller.get_current_animation() != "slide_end" and \
					   sprite_controller.get_current_animation() != "slide":
						sprite_controller.play_animation("idle")

				### Ground --> Climb ###
				if !on_ladder_top and (on_ladder and Input.is_action_pressed("up")):
					state = STATES.CLIMB
				if on_ladder_top and (on_ladder and Input.is_action_pressed("down")):
					sprite_controller.play_animation("climb")
					state = STATES.CLIMB
					global_position.y = (current_ladder.global_position.y - 8)

				### Jumping --> Air ###
				if Input.is_action_just_pressed("jump"):
					velocity.y = -stats.jump_force
					snd_jump.play()
					state = STATES.AIR
					sprite_controller.play_animation("jump")

				### Not floor --> Air ###
				if !is_on_floor(): state = STATES.AIR

				### Ground --> Slide ###
				if Input.is_action_just_pressed("slide"):
					can_shoot = false
					slide_timer.start()
					sprite_controller.play_animation("slide")
					snd_slide.play()
					state = STATES.SLIDE

				flip_sprite()
#endregion

#region Air State
			STATES.AIR:
				set_collision_shapes("normal")

				### Variable Jump Height ###
				if velocity.y < 0 and !Input.is_action_pressed("jump"):
					velocity.y += stats.gravity * 3.25 # Stronger Gravity
					velocity.y = 0

				if velocity.y > 0:
					sprite_controller.play_animation("fall")

				### Handle Double Jump ###
				if can_double_jump:
					if double_jump and Input.is_action_just_pressed("jump"):
						double_jump = false
						velocity.y = -stats.jump_force #-(stats.jump_force * 0.85)

				### Air --> Ground ###
				if is_on_floor():
					state = STATES.GROUND
					sprite_controller.play_animation("land")
					snd_land.play()
					can_step = false
					if can_double_jump:
						double_jump = true

				### -- > Climb ###
				if current_ladder != null and on_ladder:
					if global_position.y >= ((current_ladder.global_position.y - 8) - (collision_normal.shape.size.y * 0.5)) and (on_ladder and (Input.is_action_pressed("up"))):
						sprite_controller.play_animation("climb") ##
						state = STATES.CLIMB

				velocity.y += 1

				flip_sprite()

				_terminal_Y_velocity()
#endregion

#region Slide State
			STATES.SLIDE:
				set_collision_shapes("slide")

				if !ceiling and ((velocity.x > 0 and Input.is_action_pressed("left")) or \
								(velocity.x < 0 and Input.is_action_pressed("right"))):
					can_shoot = true
					slide_timer.stop()
					state = STATES.GROUND

				### Slide --> Air ###
				if !is_on_floor():
					can_shoot = true
					slide_timer.stop()
					sprite_controller.play_animation("fall") ##
					state = STATES.AIR

				### Slide --> Ground ###
				if slide_timer.time_left == 0 and !ceiling: # !!!
					# BUG !!!!!!!!
					# Fall animation in the air
					can_shoot = true

				### Jumping --> Air ###
				if !ceiling and Input.is_action_just_pressed("jump"):
					sprite_controller.play_animation("jump") ##
					can_shoot = true
					slide_timer.stop()
					velocity.y = -stats.jump_force
					snd_jump.play()
					state = STATES.AIR

				velocity.x = direction * stats.slide_speed

				flip_sprite()
#endregion

#region Hurt State
			STATES.HURT:
				can_shoot = false
				allow_movement = false
#endregion

#region Climb State
			STATES.CLIMB:
				apply_gravity = false
				if !on_ladder_top:
					sprite_controller.play_animation("climb") ##
					pass
				else:
					sprite_controller.play_animation("climb_end") ##
					pass

				var climb_vector = Input.get_axis("up", "down")

				global_position.x = current_ladder.global_position.x

				if climb_vector != 0 and !is_shooting:
					if climb_vector < 0:
						sprite_controller.set_speed_scale(1.0) ##
						velocity.y = -(stats.climb_speed)
					elif climb_vector > 0:
						sprite_controller.set_speed_scale(-1.0) ##
						velocity.y = stats.climb_speed
				else:
					sprite_controller.set_speed_scale(0.0) ##
					velocity.y = 0

				### Ground if at the top of a ladder ###
				if (global_position.y) + 6 <= (current_ladder.global_position.y - 8) and Input.is_action_pressed("up"):
					state = STATES.GROUND
					velocity.y = 0
					global_position.y = (current_ladder.global_position.y - 8) - (collision_normal.shape.size.y * 0.5)
					sprite_controller.set_speed_scale(1.0) ##
					apply_gravity = true

				### Ground if on floor ###
				if is_on_floor() and velocity.y > 0:
					velocity.y = 0
					state = STATES.GROUND
					sprite_controller.set_speed_scale(1.0) ##
					apply_gravity = true

				### Air if jump off ladder ###
				if Input.is_action_just_pressed("jump") and velocity.y == 0:
					velocity.y = 0
					state = STATES.AIR
					sprite_controller.set_speed_scale(1.0) ##
					apply_gravity = true

				if !on_ladder:
					state = STATES.AIR
					sprite_controller.set_speed_scale(1.0) ##
					apply_gravity = true
#endregion

#region Teleport State
			STATES.TELEPORT_IN:
				velocity.y = 0
				apply_gravity = false
				can_shoot = false
#endregion

#region Dead State
			STATES.DEAD:
				sprite_controller.enable_sprite(false) ##
				can_shoot = false
				apply_gravity = false
				allow_movement = false
				can_double_jump = false
#endregion

	_check_room_transition()
	_stop_at_room_limits()

	if Input.is_action_just_pressed("debug_kill_player"): death_proccessing(false)

#endregion

#region Setters and Getters
# STATE
func get_player_state() -> int: return state
func set_player_state(to_state: int) -> void: state = to_state

# SHOOT
func get_shoot_state() -> bool: return is_shooting
func set_shoot_state(is_shoot: bool) -> void: is_shooting = is_shoot

# DIRECTION
func set_direction(dir: int) -> void: direction = dir

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

func teleport_to(destination: Vector2) -> void:
	sprite_controller.enable_sprite(true) ##
	self.visible = true
	allow_movement = true
	#can_double_jump = false

	# snd_teleport_in.play() # TODO: MOVE TO INITIALIZATION
	set_player_state(STATES.TELEPORT_IN)
	set_colliders(false)
	sprite_controller.play_animation("teleport")
	sprite_controller.set_speed_scale(0.0)
	self.global_position = Vector2(destination.x, room_limits[1])
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position:y", destination.y, 0.32)
	await tween.finished
	set_colliders(true)
	sprite_controller.set_speed_scale(1.0)
	sprite_controller.play_animation("teleport")

func flip_sprite() -> void:
	if direction > 0: sprite_controller.flip_sprite_h(true)
	elif direction < 0: sprite_controller.flip_sprite_h(false)

func _terminal_Y_velocity() -> void: if velocity.y > 448: velocity.y = 448

func death_proccessing(pit_death: bool = false) -> void:
	if state != STATES.DEAD:
		apply_gravity = false
		can_shoot = false
		allow_movement = false
		can_double_jump = false
		velocity.x = 0
		velocity.y = 0
		self.visible = false
		snd_death.play()
		if !pit_death:
			var exp_inst = death_explosion_fx.instantiate()
			get_parent().add_sibling(exp_inst)
			exp_inst.global_position = global_position
			exp_inst.trigger_explosion.emit()
		state = STATES.DEAD
		EventBus.stage_event_player_died.emit()

func _check_room_transition() -> void:
	if room_limits == [0, 0, 0, 0]: return
	if state != STATES.SCROLL and state != STATES.TELEPORT_IN:
		if global_position.x - 16 < room_limits[0]:
			EventBus.stage_event_player_at_border.emit(0) # at the left border

		elif global_position.x + 16 > room_limits[2]:
			EventBus.stage_event_player_at_border.emit(2) # at the right border

		elif (global_position.y >= (room_limits[3]) and state == 1 and velocity.y > 0) or \
				(global_position.y >= (room_limits[3]) and state == 2 and velocity.y > 0): # at the bottom border
			EventBus.stage_event_player_at_border.emit(3)

		elif (global_position.y <= room_limits[1] and state == 2 and velocity.y < 0): # at the top border
			EventBus.stage_event_player_at_border.emit(1)

func _stop_at_room_limits() -> void:
	if room_limits == [0, 0, 0, 0]: return
	if state != STATES.SCROLL and state != STATES.TELEPORT_IN:
		if global_position.x - 16 < room_limits[0]:
			global_position.x = room_limits[0] + 16
		elif global_position.x + 16 > room_limits[2]:
			global_position.x = room_limits[2] - 16

		if global_position.y + (collision_normal.shape.size.y / 2 ) < room_limits[1]:
			global_position.y = room_limits[1] - (collision_normal.shape.size.y / 2 )
			#sprite_controller.enable_sprite(false)
		#else:
			#sprite_controller.enable_sprite(true)

#region Event Handlers
func _scroll_handler(scroll_direction: int, room: Room) -> void:
	slide_timer.paused = true
	weapon_system.pause_cooldown_timer(true)
	var last_x_velocity = velocity.x
	var last_y_velocity = velocity.y
	velocity.x = 0
	velocity.y = 0
	apply_gravity = false
	last_state = state
	#var last_anim = sprite.animation ##
	var could_shoot = can_shoot
	can_shoot = false
	state = STATES.SCROLL

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	var tarX: int
	var tarY: int

	match scroll_direction:
		0: # left
			tarX = global_position.x - 64
		1: # up
			tarY = global_position.y - 20
		2: # right
			tarX = global_position.x + 64
		3: # down
			tarY = global_position.y + 20

	if last_state == STATES.AIR and (scroll_direction != 1): sprite_controller.pause_playback(true)

	if tarX: tween.tween_property(self, "global_position:x", tarX, 0.68)
	if tarY: tween.tween_property(self, "global_position:y", tarY, 0.68)

	await tween.finished

	if state != STATES.SLIDE and !ceiling: # Ignore unpausing slide_timer if sliding and under the ceiling
		slide_timer.paused = false
	apply_gravity = true
	state = last_state
	can_shoot = could_shoot
	if last_state == STATES.AIR and scroll_direction == 3:
		velocity.y = last_y_velocity
		velocity.x = 0
	else:
		velocity.x = last_x_velocity
		velocity.y = 0

	weapon_system.pause_cooldown_timer(false)

func _scrolling_finished(room: Room) -> void:
	pass
#endregion














#
