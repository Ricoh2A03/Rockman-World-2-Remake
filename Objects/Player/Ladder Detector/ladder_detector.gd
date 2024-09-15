extends Area2D

func _on_area_entered(area):
	print(area)
	if get_parent() is Player:
		get_parent().on_ladder = true
		get_parent().current_ladder = area
		print(area.name)

func _on_area_exited(area):
	if get_parent() is Player:
		get_parent().on_ladder = false
		print(area.name)
