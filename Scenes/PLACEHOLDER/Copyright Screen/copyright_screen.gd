extends Control
#class_name Scene

@export var to_scene: PackedScene

func _ready():
	$Label2.visible_ratio = 0
	var text_timer = get_tree().create_timer(2.14)
	await text_timer.timeout
	reveal_text()

func reveal_text():
	var tween = get_tree().create_tween()
	#tween.EASE_IN_OUT
	tween.tween_property($Label2, "visible_ratio", 1, 0.45)

func _on_logo_sound_finished():
	await get_tree().create_timer(1)
	Globals.main.transit_to_scene(0.45, to_scene)
