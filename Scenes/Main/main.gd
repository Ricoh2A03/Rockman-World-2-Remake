class_name Main extends Node

@onready var fade_color: ColorRect = $SceneTransition/FadeColor

##########################################

## First Scene that loads at the start of the game.
@export var first_scene: PackedScene

var current_scene
var is_transiting: bool = false

##########################################

var _fullscreen: bool = true

##########################################

var _is_paused: bool = false
var _exception_objects: Array[Node]

var _backup_process_modes: Array[int]

func is_paused() -> bool: return _is_paused

func pauseGame(exceptions: Array[Node]) -> void:
	# If game IS paused, skip
	if _is_paused: return

	# Pause everything, EXCEPT for EXCEPTIONS
	for node in exceptions:
		_exception_objects.append(node)
		_backup_process_modes.append(node.process_mode)
		node.process_mode = PROCESS_MODE_ALWAYS

	get_tree().paused = true
	_is_paused = true

func unpauseGame() -> void:
	# If game is NOT paused, skip
	if !_is_paused: return

	for i in range(len(_exception_objects)):
		_exception_objects[i].process_mode = _backup_process_modes[i]

	get_tree().paused = false
	_is_paused = false

##########################################

func _ready() -> void:
	Globals.main = self
	# Mute everything so I can listen to music while debugging :D
	AudioServer.set_bus_mute(0, true)
	# Set windowed mode
	toggle_fullscreen()
	# Check if there's starting scene and instantiate it
	if first_scene:
		var scene_instance = first_scene.instantiate()
		current_scene = scene_instance
		call_deferred("add_child", scene_instance)

##########################################

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()

##########################################

func transit_to_scene(duration: float, to_scene: PackedScene = null) -> void:
	# Get out if transitioning already.
	if is_transiting: return
	is_transiting = true
	# Create tween.
	var tween = get_tree().create_tween()
	tween.tween_property(fade_color, "self_modulate", Color(1, 1, 1, 1), duration) # transparent to color
	await tween.finished

	tween.stop()
	if to_scene:
		current_scene.queue_free()
		var scene_instance = to_scene.instantiate()
		current_scene = scene_instance
		call_deferred("add_child", scene_instance)

	tween.tween_property(fade_color, "self_modulate", Color(1, 1, 1, 0), duration) # color to transparent
	tween.play()
	await tween.finished
	is_transiting = false

##########################################

func toggle_fullscreen() -> void:
	_fullscreen = !_fullscreen
	if _fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

##########################################
