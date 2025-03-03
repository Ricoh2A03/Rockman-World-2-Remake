extends Scene

func _ready() -> void:
	super._ready()
	var tween = get_tree().create_tween()
	tween.tween_property(%FadeIn, "self_modulate", Color(1, 1, 1, 0), 1.4)

func _on_fade_timeout() -> void:
	%LogoSprite.play("default")
	var timer = get_tree().create_timer(2)
	await timer.timeout
	Globals.main.transit_to_scene(0.35, scene_transitor.scenes[0])
