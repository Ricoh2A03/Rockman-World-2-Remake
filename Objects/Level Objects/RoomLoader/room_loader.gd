extends Area2D

## What room needs to be updated.
@export var room_to_update: Room
## What room will be loaded.
@export var to_room: Room

enum SCRLDIR {Left, Right, Up, Down}
@export var room_exit_to_load: SCRLDIR

## If true, scrolling will be skipped and the player will die from pit
@export var death_zone: bool = false

func _on_body_entered(body: Node2D) -> void:
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

	if death_zone:
		room_to_update.exit_bottom = null
