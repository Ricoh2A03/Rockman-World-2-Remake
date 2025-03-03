class_name Main extends Node

@onready var fade_color: ColorRect = $SceneTransition/FadeColor
@onready var music_player: AudioStreamPlayer = $MusicPlayer

##########################################

## First Scene that loads at the start of the game.
@export var first_scene: PackedScene
@export var load_fade_speed: float = 0.0

var current_scene: Scene
var is_transiting: bool = false

##########################################

var _fullscreen: bool = true
var _debug_mute: bool = false

func toggle_fullscreen() -> void:
	_fullscreen = !_fullscreen
	if _fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

##########################################

var _is_paused: bool = false

func is_paused() -> bool: return _is_paused

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

##########################################

func _ready() -> void:
	Globals.main = self
	# Mute everything so I can listen to music while debugging :D
	#AudioServer.set_bus_volume_db(0, -80)
	AudioServer.set_bus_volume_db(0, -15)
	# Set windowed mode
	toggle_fullscreen()
	# Check if there's starting scene and instantiate it
	if first_scene:
		transit_to_scene(load_fade_speed, first_scene, true)
	#if first_scene:
		#var scene_instance = first_scene.instantiate()
		#current_scene = scene_instance
		#call_deferred("add_child", scene_instance)

##########################################

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()

##########################################

func transit_to_scene(duration: float, to_scene: PackedScene = null, fade_in: bool = false) -> void:
	# Get out if transitioning already.
	if is_transiting: return

	if !fade_in:
		is_transiting = true
		# Create tween.
		var tween_in = get_tree().create_tween()
		tween_in.set_parallel()

		tween_in.tween_property(fade_color, "self_modulate", Color(1, 1, 1, 1), duration) # transparent to color
		tween_in.tween_property(music_player, "volume_db", -80, duration)

		await tween_in.finished
		stop_music()
		tween_in.stop()

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
	is_transiting = false

##########################################

func play_music(music: AudioStreamWAV) -> void:
	music_player.stream = music
	music_player.play()

func pause_music(paused: bool) -> void: music_player.stream_paused = paused

func stop_music() -> void: music_player.stop()
