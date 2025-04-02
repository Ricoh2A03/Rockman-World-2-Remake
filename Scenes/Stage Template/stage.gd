class_name Stage extends Scene

# Signals
signal player_died()
signal boss_defeated()

var player_ref: Player = null
var camera_ref: Camera2D = null

var is_scrolling: bool = false

@export_category("Room List")
## First room of the stage.
@export var start_room: Room
## Current active room
var _current_room: Room
var _current_room_limits: Array[int] = [0, 0, 0, 0] # left - [0], top - [1], right - [2], bottom - [3]

@export_category("Checkpoint List")
## List of all stage checkpoints. First one in this array is the start of the stage.
@export var checkpoints: Array[Checkpoint] = []
var current_checkpoint: Checkpoint

@export_category("Player and Camera")
## Path to Player node to instatiate.
@export var player_path: PackedScene
## Path to Camera node to instatiate.
@export var camera_path: PackedScene

@onready var stage_ui = $StageUI
@onready var ui_anim_player = $StageUI/AnimationPlayer

###########################################

# add support for views and checkpoints (+ -)

###########################################

func _ready() -> void:

	super._ready() # play music
	create_camera()

	_current_room = start_room
	set_stage_camera_limits(_current_room)
	set_stage_room_limits()

	if checkpoints.size() != 0: current_checkpoint = checkpoints[0] # set current checkpoint to the first in the array
	if camera_ref and current_checkpoint: camera_ref.global_position = current_checkpoint.global_position # set camera position to checkpoint

	flash_ready_text() # flash ready and turn health bar on

func _process(_delta):
	check_scrolling_criterias()

###########################################

func set_stage_room_limits() -> void:
	if !_current_room: return
	_current_room_limits = [_current_room.global_position.x, 
	_current_room.global_position.y,
	(_current_room.global_position.x + _current_room.size.x),
	(_current_room.global_position.y + _current_room.size.y)]

func check_scrolling_criterias():
	# Skip if there's no _current_room
	if !_current_room: return
	# Check only if there's Player and Camera
	if player_ref and camera_ref:

		# Check only if not currently scrolling
		if !is_scrolling:
			# Check bottom edge
			if (player_ref.global_position.y >= (_current_room_limits[3]) and player_ref.get_player_state() == 1 and player_ref.velocity.y > 0) or \
				(player_ref.global_position.y >= (_current_room_limits[3]) and player_ref.get_player_state() == 2 and player_ref.velocity.y > 0):
				if _current_room.exit_bottom:
					is_scrolling = true
					_current_room.despawn_objects()
					_current_room.deactivate_spawners()
					player_ref.scroll_player(3)
					# Start scrolling. Everything is exactly the same from this point, so I won't repeat
					camera_ref.camera_start_scroll(_current_room.exit_bottom, 3)
				else:
					# Pit death if there's no bottom exit from _current_room
					player_ref.death_proccessing(true)
					player_died.emit()

			# Check top edge
			if (player_ref.global_position.y <= _current_room_limits[1] and player_ref.get_player_state() == 2 and player_ref.velocity.y < 0):
				if _current_room.exit_top:
					is_scrolling = true
					_current_room.despawn_objects()
					_current_room.deactivate_spawners()
					player_ref.scroll_player(1)
					camera_ref.camera_start_scroll(_current_room.exit_top, 1)

			# Check left edge
			if (player_ref.global_position.x <= (_current_room_limits[0] + 16)):
				if _current_room.exit_left:
					is_scrolling = true
					_current_room.despawn_objects()
					_current_room.deactivate_spawners()
					player_ref.scroll_player(0)
					camera_ref.camera_start_scroll(_current_room.exit_left, 0)

			# Check right edge
			if (player_ref.global_position.x >= (_current_room_limits[2] - 16)):
				if _current_room.exit_right:
					is_scrolling = true
					_current_room.despawn_objects()
					_current_room.deactivate_spawners()
					player_ref.scroll_player(2)
					camera_ref.camera_start_scroll(_current_room.exit_right, 2)

###########################################

# Loop through spawners in currently active room and destroy each object

func stage_finished_scrolling(room: Room) -> void:
	room.activate_spawners()
	_current_room = room
	set_stage_room_limits()
	is_scrolling = false
	player_ref.room_limits = _current_room_limits

###########################################

func load_checkpoint(checkpoint: Checkpoint) -> void:
	pass

func spawn_player() -> void:
	if !player_path or player_ref: return
	var p_instance = player_path.instantiate()
	call_deferred("add_child", p_instance)
	player_ref = p_instance
	player_ref.connect("player_dead", _player_died)
	spawn_player_at_checkpoint()

func spawn_player_at_checkpoint() -> void:
	if current_checkpoint:
		player_ref.global_position = Vector2(current_checkpoint.global_position.x, (_current_room.global_position.y - 16))
		player_ref.teleport_to(current_checkpoint.global_position)

############### C A M E R A ###############

func create_camera() -> void:
	if !camera_path or camera_ref: return
	var cam_instance = camera_path.instantiate()
	call_deferred("add_child", cam_instance)
	# Connect Camera's "finished_scrolling" signal to Stage's "stage_finished_scrolling" function
	cam_instance.connect("finished_scrolling", stage_finished_scrolling)
	camera_ref = cam_instance

func set_stage_camera_limits(_room: Room) -> void: if camera_ref: camera_ref.update_camera_limits(_current_room)

func connect_camera_to_player() -> void:
	if camera_ref and player_ref:
		camera_ref.reparent(player_ref, false)
		camera_ref.player_instance = player_ref
		camera_ref.global_position = player_ref.global_position

###########################################

func _player_died() -> void:
	Globals.main.pause_music(true)

func flash_ready_text() -> void: ui_anim_player.play("ready_appear")

###########################################

func _on_animation_player_finished(anim_name) -> void:
	match anim_name:
		"ready_appear":
			ui_anim_player.play("ready_flash")
		"ready_flash":
			spawn_player() # spawn player
			if player_ref: player_ref.room_limits = _current_room_limits
			connect_camera_to_player()

# ГОООООООООООЛ
