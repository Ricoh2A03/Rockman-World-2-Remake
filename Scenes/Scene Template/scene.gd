extends Node2D
class_name Scene

@export_category("Scene Music")
@export var music_to_play: AudioStreamWAV
@export var stream_player: AudioStreamPlayer
@export var play_music_at_start: bool = false

@export_category("Scenes")
@export var scene_transitor: SceneTransitor

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
