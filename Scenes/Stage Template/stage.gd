class_name Stage extends Scene

# Signals
signal boss_defeated()

## Reference to the [class Player] object.
var player_ref: Player = null
var camera_ref: StageCamera = null

## Tells if player was spawned before.
var first_spawn: bool = false
#var is_scrolling: bool = false

@export_category("Room List")
## First room of the stage.
@export var _start_room: Room
## Currently active room.
var _current_room: Room
## Left - [0], top - [1], right - [2], bottom - [3]
var _current_room_limits: Array[int] = [0, 0, 0, 0]

## Currently active checkpoint.
var current_checkpoint: Checkpoint

@export_category("Player and Camera")
## Path to Player node to instatiate.
@export var player_path: PackedScene
## Path to Camera node to instatiate.
@export var camera_path: PackedScene

@onready var stage_ui: CanvasLayer = $StageUI
@onready var ui_anim_player: AnimationPlayer = $StageUI/AnimationPlayer
@onready var fade_overlay: ColorRect = $StageUI/Fade
@onready var fade_timer: Timer = $FadeTimer

###########################################

# add support for views and checkpoints (+ -)

###########################################

#region Initialization routine
func _ready() -> void:

	super._ready() # play music

	_current_room = _start_room
	self.set_room_limits()

	if _current_room.get_checkpoint() == null: push_error("\n" + "First room doesn't have a checkpoint!" + "\n" + "Please, set one in the editor.")
	else: current_checkpoint = _current_room.get_checkpoint()

	create_camera()
	camera_ref.set_limits(_current_room)

	#if camera_ref and current_checkpoint: camera_ref.global_position = current_checkpoint.global_position # set camera position to checkpoint

	# Connect signals
	EventBus.stage_event_player_died.connect(_player_died)
	EventBus.stage_event_player_at_border.connect(check_scrolling_criterias)
	EventBus.stage_event_scroll_finished.connect(_scrolling_finished)

	flash_ready_text() # flash ready and turn health bar on
#endregion

#region Update routine
func _process(_delta):
	%DebugStageLabel.text = "Current room: " + var_to_str(_current_room.name) + "\n" + \
	"Limits: \n" + "Left: " + var_to_str(_current_room_limits[0]) + "\n" + \
	"Top: " + var_to_str(_current_room_limits[1]) + "\n" + \
	"Right: " + var_to_str(_current_room_limits[2]) + "\n" + \
	"Bottom: " + var_to_str(_current_room_limits[3])
#endregion

#region Scrolling related routines
func check_scrolling_criterias(dir: int):
	match dir:
		0:
			if self._current_room.exit_left: EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_left)
			return
		1:
			if self._current_room.exit_top: EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_top)
			return
		2:
			if self._current_room.exit_right: EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_right)
			return
		3:
			if self._current_room.exit_bottom:
				EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_bottom)
			else: player_ref.death_proccessing(true)
			return
#endregion

#region Player related routines
func create_player() -> void:
	if !player_path or player_ref: return
	var p_instance = player_path.instantiate()
	call_deferred("add_child", p_instance)
	player_ref = p_instance
	player_ref.global_position = Vector2(current_checkpoint.global_position.x, (_current_room.global_position.y - 16))
	player_ref.teleport_to(current_checkpoint.global_position)

func respawn_player() -> void:
	#if current_checkpoint:
		#player_ref.global_position = Vector2(current_checkpoint.global_position.x, (_current_room.global_position.y - 16))
		#player_ref.teleport_to(current_checkpoint.global_position)
	pass
#endregion

#region Camera related routines
func create_camera() -> void:
	if !camera_path or camera_ref: return
	var cam_instance = camera_path.instantiate()
	call_deferred("add_child", cam_instance)
	camera_ref = cam_instance
	pass

func connect_camera_to_player() -> void:
	#if camera_ref and player_ref:
		#camera_ref.reparent(player_ref, false)
		#camera_ref.player_instance = player_ref
		#camera_ref.global_position = player_ref.global_position
	pass

#endregion

#region Room related routines
func set_room_limits() -> void:
	if !_current_room: return
	_current_room_limits = [_current_room.global_position.x, 
	_current_room.global_position.y,
	(_current_room.global_position.x + _current_room.size.x),
	(_current_room.global_position.y + _current_room.size.y)]
#endregion

#region Event handlers
func _player_died() -> void:
	Globals.main.pause_music(true)
	fade_timer.start()

func _scrolling_finished(room: Room) -> void:
	_current_room = room
	#is_scrolling = false
	self.set_room_limits()
	player_ref.room_limits = _current_room_limits # TODO: move this to the player script
	if room.get_checkpoint() is Checkpoint: self.current_checkpoint = room.get_checkpoint()
	room.activate_spawners()

func _respawn_handler() -> void:
	#var tween = get_tree().create_tween()
	#_current_room = current_checkpoint.associated_room
	#set_stage_room_limits()
	#set_stage_camera_limits(_current_room)
	#camera_ref.global_position = current_checkpoint.global_position
	#Globals.main.play_music(music_to_play)
#
	#ui_anim_player.play("ready_appear")
	#tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1)
	pass
#endregion

func flash_ready_text() -> void: ui_anim_player.play("ready_appear")

###########################################

#region Signal handlers
func _on_animation_player_finished(anim_name) -> void:
	match anim_name:
		"ready_appear":
			ui_anim_player.play("ready_flash")
		"ready_flash":
			if !first_spawn:
				create_player() # spawn player
				camera_ref.set_target(player_ref)
				if player_ref: player_ref.room_limits = _current_room_limits
				camera_ref._follow_target = true
				first_spawn = true
			else:
				player_ref.room_limits = _current_room_limits
				#connect_camera_to_player()
				respawn_player()

func _on_fade_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1)
	await tween.finished
	#_respawn_handler()
#endregion

# ГОООООООООООЛ
