extends Node2D
class_name Scene

@export_category("Next Scene to Load")
@export var to_scene: PackedScene

@export_category("Scene Music")
@export var music_to_play: AudioStreamWAV
@export var stream_player: AudioStreamPlayer
@export var play_music_at_start: bool = false

var creator: Node # not necessary..?

### Ready function
func _ready():
	if play_music_at_start:
		play_music()

### Play music if file is present
func play_music():
	if !music_to_play or !stream_player:
		return
	stream_player.stream = music_to_play
	stream_player.play(0)

### Pause music
func music_pause(paused: bool):
	if stream_player: stream_player.stream_paused = paused

### Transition to new scene (note: add support for custom scene transitions in the form of resources)
func scene_transition(scene: PackedScene):
	if to_scene == null:
		return
	var scene_instance = scene.instantiate()
	get_tree().root.get_child(0).call_deferred("add_child", scene_instance)
	self.queue_free()
