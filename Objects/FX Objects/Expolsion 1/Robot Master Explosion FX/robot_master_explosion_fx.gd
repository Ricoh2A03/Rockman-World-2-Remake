extends Node2D
class_name RobotMasterExplosion

signal trigger_explosion()

@export var particle: PackedScene
var particle_count: int = 8
var secondary_particles: bool = false

var part_speed: float = 3.2
var part_speed_diag: float = 4.8

func explode() -> void:
	for i in particle_count:
		var particle_instance = particle.instantiate()
		add_child(particle_instance)
		particle_instance.top_level = true
		particle_instance.global_position.x = global_position.x
		particle_instance.global_position.y = global_position.y

		match i:
			0: # top center
				particle_instance.tween_move(particle_instance.global_position.x, particle_instance.global_position.y -256, part_speed)
			1: # diagonal top right
				particle_instance.tween_move(particle_instance.global_position.x + 256, particle_instance.global_position.y -256, part_speed_diag)
			2: # right
				particle_instance.tween_move(particle_instance.global_position.x + 256, particle_instance.global_position.y, part_speed)
			3: # diagonal bottom right
				particle_instance.tween_move(particle_instance.global_position.x + 256, particle_instance.global_position.y + 256, part_speed_diag)
			4: # bottom
				particle_instance.tween_move(particle_instance.global_position.x, particle_instance.global_position.y + 256, part_speed)
			5: # diagonal bottom left
				particle_instance.tween_move(particle_instance.global_position.x - 256, particle_instance.global_position.y + 256, part_speed_diag)
			6: # left
				particle_instance.tween_move(particle_instance.global_position.x - 256, particle_instance.global_position.y, part_speed)
			7: # diagonal top left
				particle_instance.tween_move(particle_instance.global_position.x - 256, particle_instance.global_position.y -256, part_speed_diag)
