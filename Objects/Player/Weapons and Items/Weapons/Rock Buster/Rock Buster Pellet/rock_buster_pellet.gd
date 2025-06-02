extends BasicProjectile


enum STATES{
	FLYING,
	COLLIDED,
	DEFLECTED
}


var _current_state: int = STATES.FLYING
var _deflect_vector: Vector2


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer: Timer = $Timer
@onready var vis_notif: VisibleOnScreenNotifier2D = $Visibility
@onready var snd_deflect: AudioStreamPlayer2D = $snd_deflect
@onready var collision_box: Area2D = $CollisionBox


func _process(delta: float) -> void:
	match _current_state:

		STATES.FLYING:
			global_position.x += (xSpeed * _direction) * delta

		STATES.DEFLECTED:
			global_position += (_deflect_vector * xSpeed) * delta


func _on_timeout() -> void:
	# If timer is stopped and not on screen, destroy projectile
	if !vis_notif.is_on_screen(): _on_screen_exited()


func _on_screen_exited() -> void:
	screen_exited.emit()
	queue_free()


func _on_collision_box_entered(area: Area2D) -> void:
	var obj = area.get_parent()

	if obj is HealthDamageComponent:
		if obj.get_deflect_state() == false:
			_current_state = STATES.COLLIDED
			screen_exited.emit()
			sprite.play("diffuse")
		else:
			collision_box.call_deferred("set_monitoring", false)
			collision_box.call_deferred("set_monitorable", false)
			if obj.global_position.x < self.global_position.x:
				_deflect_vector = Vector2(1, -1)
			else:
				_deflect_vector = Vector2(-1, -1)
			snd_deflect.play()
			_current_state = STATES.DEFLECTED


func _on_animation_finished() -> void:
	if destroy_on_impact: queue_free()
