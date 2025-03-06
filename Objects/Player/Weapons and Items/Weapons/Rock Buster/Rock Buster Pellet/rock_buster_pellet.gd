extends BasicProjectile

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer: Timer = $Timer
@onready var vis_notif: VisibleOnScreenNotifier2D = $Visibility

func _process(delta: float) -> void:
	# move projectile if not collided yet
	if !_collided: global_position.x += (xSpeed * _direction) * delta

func _on_timeout() -> void:
	# if timer is stopped and not on screen, destroy projectile
	if !vis_notif.is_on_screen(): _on_screen_exited()

func _on_screen_exited() -> void:
	screen_exited.emit()
	queue_free()

func _on_collision_box_entered(_area: Area2D) -> void:
	_collided = true
	screen_exited.emit()
	sprite.play("diffuse")

func _on_animation_finished() -> void:
	if destroy_on_impact: queue_free()
