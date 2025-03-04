extends AnimatedSprite2D
class_name ExplosionParticle

var directionX
var directionY

func tween_move(x: int, y: int, speed: float):
	directionX = x
	directionY = y
	var tween = get_tree().create_tween()

	tween.EASE_IN
	tween.tween_property(self, "global_position", Vector2(directionX, directionY), speed)

func _on_screen_exited() -> void:
	queue_free()
