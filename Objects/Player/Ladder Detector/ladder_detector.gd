extends Area2D

func _on_area_entered(area):
	if get_parent() is Player:
		get_parent()._on_ladder = true
		get_parent()._current_ladder = area

func _on_area_exited(_area):
	if get_parent() is Player:
		get_parent()._on_ladder = false
