extends BasicProjectile

@onready var timer: Timer = $Timer
@onready var vis_notif: VisibleOnScreenNotifier2D = $Visibility

func _process(delta: float) -> void:
	global_position.x += (xSpeed * _direction) * delta

func _on_screen_exited() -> void:
	screen_exited.emit()
	queue_free()

func _on_timeout() -> void:
	if !vis_notif.is_on_screen():
		_on_screen_exited()

func _on_collision_box_entered(_area: Area2D) -> void:
	screen_exited.emit()
	if destroy_on_impact: queue_free()
