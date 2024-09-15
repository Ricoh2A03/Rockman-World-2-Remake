extends CharacterBody2D
class_name Player

signal player_scroll_finished()
signal player_dead()

@export_category("Player Stats")
@export var stats: PlayerStats # player stat resource

@export_category("Dependent Nodes")
@export var sprite: AnimatedSprite2D
@export var step_timer: Timer
@export var slide_timer: Timer
@export var collision_normal: CollisionShape2D # for anything else
@export var collision_slide: CollisionShape2D # for slide

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
@export var snd_land: AudioStreamPlayer
@export var snd_teleport_in: AudioStreamPlayer
@export var snd_teleport_out: AudioStreamPlayer
@export var snd_damage: AudioStreamPlayer
@export var snd_death: AudioStreamPlayer
@export var snd_weapon_menu_open: AudioStreamPlayer

@export_group("Physics Toggles")
@export var apply_gravity: bool = true
@export var allow_movement: bool = true
@export var can_double_jump: bool = false
@export var move_and_slide_on: bool = true

var can_step: bool = true
var is_step: bool = false
var ceiling: bool = false

var on_ladder: bool = false
var on_ladder_top: bool = false
var current_ladder: Ladder

var double_jump: bool = true
var direction: int = 1

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

var last_state = null

var state = STATES.TELEPORT_IN

var room_limits = [0, 0, 0, 0] # left, top, right, bottom

func _ready():
	pass

func _process(delta):

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

		### Sprite Flipping ###
		if direction > 0: sprite.flip_h = true
		elif direction < 0: sprite.flip_h = false

		match state:

##########################################

			STATES.GROUND:
				change_collision_shapes("normal")

				if can_step and move_vector: # stepping
					is_step = true
					can_step = false
					step_timer.start()

				### Animations ###
				if velocity.x != 0:
					if is_step: sprite.play("step")
					else: sprite.play("walk")
				else: sprite.play("idle")

				### Jumping --> Air ###
				if Input.is_action_just_pressed("jump"):
					velocity.y = -stats.jump_force
					sprite.play("jump")
					state = STATES.AIR

				### Not floor --> Air ###
				if !is_on_floor():
					state = STATES.AIR

				### Ground --> Slide ###
				if Input.is_action_just_pressed("slide"):
					slide_timer.start()
					sprite.play("slide")
					state = STATES.SLIDE

				### Ground --> Climb ###
				if !on_ladder_top and (on_ladder and Input.is_action_pressed("up")):
					state = STATES.CLIMB
				if on_ladder_top and (on_ladder and Input.is_action_pressed("down")):
					sprite.play("climb")
					state = STATES.CLIMB
					global_position.y = (current_ladder.global_position.y - 8)

##########################################

			STATES.AIR:
				change_collision_shapes("normal")

				### Variable Jump Height ###
				if velocity.y < 0 and !Input.is_action_pressed("jump"):
					#velocity.y += stats.gravity * 3.25 # Stronger Gravity
					velocity.y = 0

				if velocity.y > 0: sprite.play("air")

				### Handle Double Jump ###
				if can_double_jump:
					if double_jump and Input.is_action_just_pressed("jump"):
						double_jump = false
						velocity.y = -stats.jump_force #-(stats.jump_force * 0.85)

				### Air --> Ground ###
				if is_on_floor():
					state = STATES.GROUND
					snd_land.play()
					can_step = false
					if can_double_jump:
						double_jump = true

				### -- > Climb ###
				if current_ladder != null and on_ladder:
					if global_position.y >= ((current_ladder.global_position.y - 8) - (collision_normal.shape.size.y * 0.5)) and (on_ladder and (Input.is_action_pressed("up") or (Input.is_action_pressed("down")))):
						sprite.play("climb")
						state = STATES.CLIMB

				velocity.y += 1

				_terminal_Y_velocity()

##########################################

			STATES.SLIDE:
				change_collision_shapes("slide")
				if sprite.animation != "slide": sprite.play("slide")

				if !ceiling and ((velocity.x > 0 and Input.is_action_pressed("left")) or \
								(velocity.x < 0 and Input.is_action_pressed("right"))):
					state = STATES.GROUND

				velocity.x = direction * stats.slide_speed

				if !is_on_floor():
					sprite.play("air")
					state = STATES.AIR

				if slide_timer.time_left == 0 and !ceiling: # !!!
					state = STATES.GROUND

				### Jumping --> Air ###
				if !ceiling and Input.is_action_just_pressed("jump"):
					velocity.y = -stats.jump_force
					sprite.play("air")
					state = STATES.AIR

##########################################

			STATES.CLIMB:
				apply_gravity = false
				if !on_ladder_top:
					sprite.play("climb")
				else:
					sprite.play("climb_end")

				var climb_vector = Input.get_axis("up", "down")

				global_position.x = current_ladder.global_position.x

				if climb_vector != 0:
					if climb_vector < 0:
						sprite.speed_scale = 1
						velocity.y = -(stats.climb_speed)
					elif climb_vector > 0:
						sprite.speed_scale = -1
						velocity.y = stats.climb_speed
				else:
					sprite.speed_scale = 0
					velocity.y = 0

				### Ground if at the top of a ladder ###
				if (global_position.y) + 6 <= (current_ladder.global_position.y - 8) and Input.is_action_pressed("up"):
					state = STATES.GROUND
					velocity.y = 0
					global_position.y = (current_ladder.global_position.y - 8) - (collision_normal.shape.size.y * 0.5)
					sprite.speed_scale = 1
					apply_gravity = true

				### Ground if on floor ###
				if is_on_floor() and velocity.y > 0:
					velocity.y = 0
					state = STATES.GROUND
					sprite.speed_scale = 1
					apply_gravity = true

				### Air if jump off ladder ###
				if Input.is_action_just_pressed("jump") and velocity.y == 0:
					velocity.y = 0
					state = STATES.AIR
					sprite.speed_scale = 1
					apply_gravity = true

				if !on_ladder:
					state = STATES.AIR
					sprite.speed_scale = 1
					apply_gravity = true

##########################################

			STATES.TELEPORT_IN:
				apply_gravity = false

				if get_slide_collision_count() == 0:
					sprite.speed_scale = 0
					sprite.play("teleport")
					velocity.y += 562
					if velocity.y > 562: velocity.y = 562
				else:
					velocity.y = 0
					sprite.speed_scale = 1

				if sprite.animation == "teleport" and sprite.frame == 6:
					apply_gravity = true
					state = STATES.GROUND
					snd_teleport_in.play()

			STATES.DEAD:
				sprite.visible = false
				apply_gravity = false
				allow_movement = false
				can_double_jump = false

	if Input.is_action_just_pressed("debug_kill_player"): death_proccessing(false)

	_stop_at_room_limits()

##########################################

func change_collision_shapes(shape: String) -> void:
	if shape == "slide":
		collision_normal.disabled = true
		collision_slide.disabled = false
	elif shape == "normal":
		collision_slide.disabled = true
		collision_normal.disabled = false

##########################################

func get_player_state() -> int: return state

##########################################

func _terminal_Y_velocity() -> void: if velocity.y > 448: velocity.y = 448

##########################################

func death_proccessing(pit_death: bool = false):
	if state != STATES.DEAD:
		apply_gravity = false
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
		player_dead.emit()

##########################################

func scroll_player(scroll_direction) -> void:
	slide_timer.paused = true
	var last_x_velocity = velocity.x
	var last_y_velocity = velocity.y
	velocity.x = 0
	velocity.y = 0
	apply_gravity = false
	last_state = state
	state = STATES.SCROLL

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	var tarX: int
	var tarY: int

	match scroll_direction:
		0: # left
			tarX = global_position.x - 48
		2: # right
			tarX = global_position.x + 48
		1: # up
			tarY = global_position.y - 20
		3: # down
			tarY = global_position.y + 20

	if tarX:
		tween.tween_property(self, "global_position:x", tarX, 1.25)
	if tarY:
		tween.tween_property(self, "global_position:y", tarY, 1.25)

	await tween.finished
	player_scroll_finished.emit()
	slide_timer.paused = false
	apply_gravity = true
	state = last_state
	if last_state == STATES.AIR:
		velocity.y = last_y_velocity
		velocity.x = 0
	else:
		velocity.x = last_x_velocity
		velocity.y = 0

##########################################

func _stop_at_room_limits() -> void:
	if room_limits == [0, 0, 0, 0]: return
	if state != STATES.SCROLL and state != STATES.TELEPORT_IN:
		if global_position.x - (collision_normal.shape.size.x / 2) < room_limits[0]:
			global_position.x = room_limits[0] + (collision_normal.shape.size.x / 2)
		elif global_position.x + (collision_normal.shape.size.x / 2) > room_limits[2]:
			global_position.x = room_limits[2] - (collision_normal.shape.size.x / 2)

		if global_position.y - (collision_normal.shape.size.y * 0.2) < room_limits[1]:
			global_position.y = room_limits[1] + (collision_normal.shape.size.y * 0.2)

##########################################

func menu_opened(opened: bool) -> void:
	if opened:
		velocity.x = 0
		velocity.y = 0
		#self.visible = false
		sprite.pause()
		if slide_timer.time_left > 0:
			slide_timer.paused = true
		snd_weapon_menu_open.play()
		apply_gravity = false
		allow_movement = false
	elif !opened:
		#self.visible = true
		sprite.play()
		slide_timer.paused = false
		apply_gravity = true
		allow_movement = true
