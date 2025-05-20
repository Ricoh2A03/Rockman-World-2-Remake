extends Area2D

func _on_body_entered(_body):
	if get_parent() is Player:
		get_parent()._is_under_ceiling = true
		get_parent().slide_timer.paused = true

func _on_body_exited(_body):
	if get_parent() is Player:
		get_parent()._is_under_ceiling = false
		get_parent().slide_timer.paused = false
