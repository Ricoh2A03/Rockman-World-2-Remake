class_name Scene extends Node2D

@export_category("Scene Music")
## Which music starts when scene loads.
@export var music_to_play: AudioStreamWAV
## Self-explanatory.
@export var play_music_at_start: bool = false

@export_category("Scenes")
## Reference for transitor node.
@export var scene_transitor: SceneTransitor

#var creator: Node # not necessary..?

func _ready():
	if play_music_at_start: play_music()

### Play music if file is present
func play_music():
	if !music_to_play: return
	Globals.main.play_music(music_to_play)

### Transition to new scene (note: add support for custom scene transitions in the form of resources)
