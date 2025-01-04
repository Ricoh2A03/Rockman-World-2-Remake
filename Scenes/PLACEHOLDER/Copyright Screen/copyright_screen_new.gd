extends Scene

func _ready():
	super._ready()
	$Label2.visible_ratio = 0
	var text_timer = get_tree().create_timer(2.14)
	await text_timer.timeout
	reveal_text()

func reveal_text():
	var tween = get_tree().create_tween()
	tween.tween_property($Label2, "visible_ratio", 1, 0.45)

func _on_logo_sound_finished():
	super.scene_transition(to_scene)
