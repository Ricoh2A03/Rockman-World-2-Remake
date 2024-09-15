extends Area2D

@export var room_to_update: Room
@export var to_room: Room

enum SCRLDIR {Left, Right, Up, Down}
@export var room_exit_to_load: SCRLDIR

## If true, scrolling will be skipped and the player will die from pit
@export var death_zone: bool = false

func _on_body_entered(body: Node2D) -> void:
	if death_zone:
		room_to_update.exit_bottom = null

	if room_to_update and to_room:
		match room_exit_to_load:
			SCRLDIR.Left:
				room_to_update.exit_left = to_room
			SCRLDIR.Right:
				room_to_update.exit_right = to_room
			SCRLDIR.Up:
				room_to_update.exit_top = to_room
			SCRLDIR.Down:
				room_to_update.exit_bottom = to_room
