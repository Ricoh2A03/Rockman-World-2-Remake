class_name Stage extends Scene

@export_category("Room List")
## First room of the stage.
@export var _starting_room: Room

@export_category("Player and Camera")
## Path to Player node to instatiate.
@export var player_scene_path: String
## Path to Camera node to instatiate.
@export var camera_scene_path: String

## Reference to the [class Player] object.
var player_ref: Player = null
var camera_ref: StageCamera = null

## Tells if player is spawned.
var _is_player_spawned: bool = false

## Currently active checkpoint.
var _current_checkpoint: Checkpoint
## Currently active room.
var _current_room: Room
## Left - [0], top - [1], right - [2], bottom - [3]
var _current_room_limits: Array[int] = [0, 0, 0, 0]

@onready var stage_ui: CanvasLayer = $StageUI
@onready var ui_anim_player: AnimationPlayer = $StageUI/AnimationPlayer
@onready var fade_overlay: ColorRect = $StageUI/Fade
@onready var fade_timer: Timer = $FadeTimer

###########################################

#region Initialization routine
func _ready() -> void:

	# Play music
	super._ready()

	# Set current room and set limits
	_current_room = _starting_room
	self.set_room_limits()

	# Set current checkpoint
	if _current_room.get_checkpoint() == null:
		push_error("\n" + "First room doesn't have a checkpoint!" + "\n" + "Please, set one in the editor.")
	else: _current_checkpoint = _current_room.get_checkpoint()

	_current_room.activate_spawners()

	# Create camera and set its limits
	create_camera()
	camera_ref.set_limits(_current_room)

	# Set camera position to checkpoint
	camera_ref.global_position = _current_checkpoint.global_position

	# Connect signals
	EventBus.stage_event_player_died.connect(_player_died)
	EventBus.stage_event_player_at_border.connect(check_scrolling_criterias)
	EventBus.stage_event_scroll_finished.connect(_scrolling_finished)

	# Flash ready, turn health bar on and spawn player
	flash_ready_text()
#endregion

#region Update routine
func _process(_delta):
	#%DebugStageLabel.text = "Current room: " + var_to_str(_current_room.name) + "\n" + \
	#"Limits: \n" + "Left: " + var_to_str(_current_room_limits[0]) + "\n" + \
	#"Top: " + var_to_str(_current_room_limits[1]) + "\n" + \
	#"Right: " + var_to_str(_current_room_limits[2]) + "\n" + \
	#"Bottom: " + var_to_str(_current_room_limits[3])
	pass
#endregion

#region Player related routines
## Instantiates [param Player] object and saves a reference to it 
func create_player() -> void:
	if !player_scene_path or player_ref: return
	var p_instance = load(player_scene_path).instantiate()
	player_ref = p_instance
	call_deferred("add_child", p_instance)
	player_ref.global_position = Vector2(_current_checkpoint.global_position.x, (_current_room.global_position.y))
	player_ref.teleport_to(_current_checkpoint.global_position)


func respawn_player() -> void:
	if self._current_checkpoint:
		self.player_ref.global_position = Vector2(_current_checkpoint.global_position.x, (_current_room.global_position.y - 16))
		self.player_ref.teleport_to(_current_checkpoint.global_position)
		self.camera_ref._follow_target = true
#endregion

#region Camera related routines
func create_camera() -> void:
	if !camera_scene_path or camera_ref: return
	var cam_instance = load(camera_scene_path).instantiate()
	self.camera_ref = cam_instance
	call_deferred("add_child", cam_instance)
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
func _player_died() -> void: # EventBus event: stage_event_player_died()
	Globals.main.pause_music(true)
	self.camera_ref._follow_target = false
	fade_timer.start()


func check_scrolling_criterias(dir: int):
	match dir:
		0:
			if !self._current_room.exit_left: return
			EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_left)
			_current_room.despawn_objects()
			_current_room.deactivate_spawners()
			return
		1:
			if !self._current_room.exit_top: return
			EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_top)
			_current_room.despawn_objects()
			_current_room.deactivate_spawners()
			return
		2:
			if !self._current_room.exit_right: return
			EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_right)
			_current_room.despawn_objects()
			_current_room.deactivate_spawners()
			return
		3:
			if self._current_room.exit_bottom:
				EventBus.stage_event_scroll_start.emit(dir, _current_room.exit_bottom)
				_current_room.despawn_objects()
				_current_room.deactivate_spawners()
			else: player_ref.death_proccessing(true)
			return


func _scrolling_finished(room: Room) -> void:
	self._current_room = room
	self.set_room_limits()
	player_ref._room_limits = _current_room_limits # TODO: move this to the player script
	if room.get_checkpoint() is Checkpoint: self._current_checkpoint = room.get_checkpoint()
	room.activate_spawners()


func _respawn_handler() -> void:
	var tween = get_tree().create_tween()
	self._current_room = _current_checkpoint.associated_room
	self.set_room_limits()
	self.camera_ref.set_limits(_current_room)
	self.camera_ref.global_position = _current_checkpoint.global_position
	if self.play_music_at_start:
		Globals.main.play_music(music_to_play)

	self.ui_anim_player.play("ready_appear")
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1)
#endregion


func flash_ready_text() -> void: self.ui_anim_player.play("ready_appear")


###########################################

#region Signal handlers
func _on_animation_player_finished(anim_name) -> void:
	match anim_name:
		"ready_appear":
			ui_anim_player.play("ready_flash")
		"ready_flash":
			if !_is_player_spawned:
				self.create_player() # spawn player
				self.camera_ref.set_target(player_ref)
				if self.player_ref: self.player_ref._room_limits = self._current_room_limits
				self.camera_ref._follow_target = true # TODO: maybe? move to dedicated player_spawned handler
				self._is_player_spawned = true
			else:
				self.player_ref._room_limits = self._current_room_limits
				self.respawn_player()


func _on_fade_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1)
	await tween.finished
	self._respawn_handler()
#endregion

# ГОООООООООООЛ
