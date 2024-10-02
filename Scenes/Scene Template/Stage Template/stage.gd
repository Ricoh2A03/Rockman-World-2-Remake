extends Scene
class_name Stage

# Signals
signal player_died()
signal boss_defeated()

var player_ref = null
var camera_ref = null

var is_scrolling: bool = false

@export_category("Room List")
##First room of the stage.
@export var start_room: Room
## Current active room
var _current_room: Room
var _current_room_limits: Array[int] = [0, 0, 0, 0] # left - [0], top - [1], right - [2], bottom - [3]

@export_category("Checkpoint List")
##List of all stage checkpoints. First one in this array is the start of the stage.
@export var checkpoints: Array[Checkpoint] = []
var current_checkpoint: Checkpoint

@export_category("Player and Camera")
##Path to Player node to instatiate.
@export var player_path: PackedScene
##Path to Camera node to instatiate.
@export var camera_path: PackedScene

@onready var stage_ui = $StageUI

###########################################

# add support for views and checkpoints (+ -)

# add level camera and connect it to player
# add screen limits to player
# add scrolling

###########################################

func _ready() -> void:
	AudioServer.set_bus_volume_db(0, -2)

	super._ready() # play music
	create_camera()

	_current_room = start_room
	set_stage_camera_limits(_current_room)
	set_stage_room_limits()

	if checkpoints.size() != 0: current_checkpoint = checkpoints[0] # set current checkpoint to the first in the array
	if camera_ref and current_checkpoint: camera_ref.global_position = current_checkpoint.global_position # set camera position to checkpoint

	flash_ready_text() # flash ready and turn health bar on

func _process(delta):
	check_scrolling_criterias()

###########################################

func set_stage_room_limits() -> void:
	if !_current_room: return
	_current_room_limits = [_current_room.global_position.x, 
	_current_room.global_position.y,
	(_current_room.global_position.x + _current_room.size.x),
	(_current_room.global_position.y + _current_room.size.y)]

func check_scrolling_criterias():
	if !_current_room: return
	if player_ref and camera_ref:

		if !is_scrolling:
			if (player_ref.global_position.y >= (_current_room_limits[3]) and player_ref.get_player_state() == 1 and player_ref.velocity.y > 0) or \
				(player_ref.global_position.y >= (_current_room_limits[3]) and player_ref.get_player_state() == 2 and player_ref.velocity.y > 0):  # check bottom edge
				if _current_room.exit_bottom:
					is_scrolling = true
					player_ref.scroll_player(3)
					camera_ref.camera_start_scroll(_current_room.exit_bottom, 3)
				else:
					player_ref.death_proccessing(true)
					player_died.emit()

			if (player_ref.global_position.y <= _current_room_limits[1] and player_ref.get_player_state() == 2 and player_ref.velocity.y < 0): # check top edge
				if _current_room.exit_top:
					is_scrolling = true
					player_ref.scroll_player(1)
					camera_ref.camera_start_scroll(_current_room.exit_top, 1)

			if (player_ref.global_position.x <= (_current_room_limits[0] + 16)):
				if _current_room.exit_left:
					is_scrolling = true
					player_ref.scroll_player(0)
					camera_ref.camera_start_scroll(_current_room.exit_left, 0)

			if (player_ref.global_position.x >= (_current_room_limits[2] - 16)):
				if _current_room.exit_right:
					is_scrolling = true
					player_ref.scroll_player(2)
					camera_ref.camera_start_scroll(_current_room.exit_right, 2)

############ S C R O L L I N G ############

func start_scrolling(target_room: Room, direction: int) -> void:
	if target_room == _current_room: return
	camera_ref.camera_start_scroll(target_room, direction)
	player_ref.room_limits = _current_room_limits

func stage_finished_scrolling(room: Room) -> void:
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

	if current_checkpoint:
		p_instance.global_position = Vector2(current_checkpoint.global_position.x, (_current_room.global_position.y - 16))
	else:
		if start_room:
			if !current_checkpoint:
				p_instance.global_position = Vector2(128, start_room.global_position.y - 16)
			else:
				p_instance.global_position = Vector2(current_checkpoint.global_position.x, _current_room.global_position.y - 16)

############### C A M E R A ###############

func create_camera() -> void:
	if !camera_path or camera_ref: return
	var cam_instance = camera_path.instantiate()
	call_deferred("add_child", cam_instance)
	cam_instance.connect("finished_scrolling", stage_finished_scrolling)
	camera_ref = cam_instance

func set_stage_camera_limits(room: Room) -> void: if camera_ref: camera_ref.update_camera_limits(_current_room)

func connect_camera_to_player() -> void:
	if camera_ref and player_ref:
		camera_ref.reparent(player_ref, false)
		camera_ref.global_position = player_ref.global_position

###########################################

func _player_died() -> void:
	super.music_pause(true)

func flash_ready_text() -> void: stage_ui.get_node("ReadyLabel/AnimationPlayer").play("flash")

###########################################

func _on_animation_player_finished(anim_name) -> void:
	match anim_name:
		"flash":
			spawn_player() # spawn player
			if player_ref: player_ref.room_limits = _current_room_limits
			connect_camera_to_player()

# ГОООООООООООЛ
