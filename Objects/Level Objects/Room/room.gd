@tool
class_name Room extends ReferenceRect

var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

@export_category("Room Size")
## Horizontal size of room in screens.
@export_range(1, 25) var room_width_x: int = 1:
	set(value):
		room_width_x = value
		_set_room_size()

## Vertical size of room in screens.
@export_range(1, 25) var room_width_y: int = 1:
	set(value):
		room_width_y = value
		_set_room_size()

## References to other rooms.
## If room doesn't have exits from left and right,
## player won't be able to go past screen edges.
##
## If room doesn't have exit from the top,
## it won't trigger scroll even when climbing up ladders.
##
## If room doesn't have exit from the bottom, it will trigger a pit death.
@export_category("Exits")
@export var exit_left: Room
@export var exit_top: Room
@export var exit_right: Room
@export var exit_bottom: Room

@export_category("Spawners")
## List of all room spawners.
@export var spawners: Array[Spawner]

@export_category("Checkpoint")
## Reference to the checkpoint that will be activated after finishing scrolling.
@export var room_checkpoint: Checkpoint


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		$Label.text = self.name
	else:
		self.visible = false


## Returns checkpoint that's attached to this room.
func get_checkpoint() -> Checkpoint: return room_checkpoint


func _set_room_size() -> void:
	if Engine.is_editor_hint():
		size.x = screen_width * room_width_x
		size.y = screen_height * room_width_y


## Activate all spawners.
func activate_spawners() -> void:
	for spawner in spawners:
		spawner.set_active(true)
		# DEBUG: display activated spawner name and related room name
		print(spawner.name + " in " + self.name + " activated")


## Deactivate all spawners.
func deactivate_spawners() -> void:
	for spawner in spawners:
		spawner.set_active(false)
		# DEBUG: display deactivated spawner name and related room name
		print(spawner.name + " in " + self.name + " deactivated")


## Despawn all spawned objects in the room.
func despawn_objects() -> void: for spawner in spawners: spawner.despawn()
