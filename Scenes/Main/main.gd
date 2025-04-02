class_name Main extends Node

@onready var fade_color: ColorRect = $SceneTransition/FadeColor
@onready var music_player: AudioStreamPlayer = $MusicPlayer

##########################################

## Scene that loads at the start of the game.
@export var first_scene: PackedScene
## Speed at which [member first_scene] is faded in.
@export var load_fade_speed: float = 0.0

var current_scene: Scene

##########################################

var _fullscreen: bool = false
var _debug_mute: bool = false

#region Initialization routine
func _ready() -> void:
	Globals.main = self
	# Mute everything so I can listen to music while debugging :D
	AudioServer.set_bus_volume_db(0, -15)
	#AudioServer.set_bus_volume_db(0, -80)
	# Set windowed mode
	toggle_fullscreen()
	# Check if there's starting scene and instantiate it
	if first_scene:
		goto_scene(load_fade_speed, first_scene, true)
#endregion

## Toggles fullscreen mode.
func toggle_fullscreen() -> void:
	_fullscreen = !_fullscreen
	if _fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#region Pause related code
var _is_paused: bool = false

func is_paused() -> bool: return _is_paused

## Pauses the game.
func pauseGame(pause_groups: Array[StringName], exceptions: Array[StringName] = []) -> void:
	# If game IS paused, skip
	if _is_paused: return
	for group in exceptions:
		get_tree().call_group(group, "_exception")
	for group in pause_groups:
		get_tree().call_group(group, "_pause_node")

	get_tree().paused = true
	_is_paused = true

func unpauseGame(groups: Array[StringName]) -> void:
	# If game is NOT paused, skip
	if !_is_paused: return
	for group in groups:
		get_tree().call_group(group, "_unpause_node")

	get_tree().paused = false
	_is_paused = false
#endregion

#region Input handler
func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()
#endregion

#region Scene Transition routine

var is_scene_transition: bool = false

## Returns [member is_scene_transition].
func get_scene_transition() -> bool: return is_scene_transition

## Initiaizes a scene transition to a specified file.[br]
## Parameter [param duration] determines the speed of the transition.[br]
## If [param fade_in] is [code]true[/code], if transition should start with the fade in effect.
func goto_scene(duration: float, to_scene: PackedScene = null, fade_in: bool = false) -> void:
	# Get out if transitioning already.
	if is_scene_transition: return

	if !fade_in:
		is_scene_transition = true
		# Create tween.
		var tween_in = get_tree().create_tween()
		tween_in.set_parallel()

		tween_in.tween_property(fade_color, "self_modulate", Color(1, 1, 1, 1), duration) # transparent to color
		tween_in.tween_property(music_player, "volume_db", -80, duration)

		await tween_in.finished
		stop_music()
		tween_in.stop()

	if !fade_in:
		var delay = get_tree().create_timer(1)
		await delay.timeout

	if to_scene:
		if current_scene: current_scene.queue_free()
		var scene_instance = to_scene.instantiate()
		current_scene = scene_instance
		call_deferred("add_child", scene_instance)

	music_player.volume_db = 0

	var tween_out = get_tree().create_tween()

	tween_out.tween_property(fade_color, "self_modulate", Color(1, 1, 1, 0), duration) # color to transparent
	tween_out.play()
	await tween_out.finished
	is_scene_transition = false
#endregion

#region Background Music related functions
## Plays music. First stops previous track, then resets volume to 0 (in case the fade out was applied before),
## and then starts to play passed audio reference.
func play_music(music: AudioStream) -> void:
	music_player.stop()
	music_player.volume_db = 0
	music_player.stream = music
	music_player.play()

## If  [code]true[/code], pauses currently played track.
func pause_music(paused: bool) -> void: music_player.stream_paused = paused

## Stops music playback.
func stop_music() -> void: music_player.stop()

## Fades currently played music in or out, depending on a passed boolean value.
func fade_music(fade_in: bool, fade_speed: float) -> void:
	var tween = get_tree().create_tween()
	if fade_in: tween.tween_property(music_player, "volume_db", 0, fade_speed)
	else: tween.tween_property(music_player, "volume_db", -80, fade_speed)
#endregion













#
