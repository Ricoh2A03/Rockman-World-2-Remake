extends Area2D

func _on_body_entered(body):
	if get_parent() is Player:
		get_parent().ceiling = true

func _on_body_exited(body):
	if get_parent() is Player:
		get_parent().ceiling = false
