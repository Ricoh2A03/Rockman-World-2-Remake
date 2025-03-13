extends Area2D

func _on_body_entered(_body):
	if get_parent() is Player:
		get_parent().ceiling = true
		get_parent().slide_timer.paused = true

func _on_body_exited(_body):
	if get_parent() is Player:
		get_parent().ceiling = false
		get_parent().slide_timer.paused = false
