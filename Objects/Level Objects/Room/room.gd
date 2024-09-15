@tool
extends ReferenceRect
class_name Room

@export_category("Room Size")
@export_range(1, 25) var room_width_x: int = 1:
	set(value):
		room_width_x = value
		set_room_size()

@export_range(1, 25) var room_width_y: int = 1:
	set(value):
		room_width_y = value
		set_room_size()

@export_category("Exits")
@export var exit_left: Room
@export var exit_top: Room
@export var exit_right: Room
@export var exit_bottom: Room

func _enter_tree():
	if Engine.is_editor_hint():
		$Label.text = self.name
	else:
		self.visible = false

func set_room_size():
	if Engine.is_editor_hint():
		size.x = 256 * room_width_x
		size.y = 224 * room_width_y
