@tool
class_name Room extends ReferenceRect

@export_category("Room Size")
## Horizontal size of room in screens.
@export_range(1, 25) var room_width_x: int = 1:
	set(value):
		room_width_x = value
		set_room_size()

## Vertical size of room in screens.
@export_range(1, 25) var room_width_y: int = 1:
	set(value):
		room_width_y = value
		set_room_size()

@export_category("Exits")
# References to other rooms.
# If room doesn't have exits from left and right,
# player won't be able to go past screen edges.
#
# If room doesn't have exit from the top,
# it won't trigger scroll even when climbing up ladders.
#
# If room doesn't have exit from the bottom, it will trigger a pit death.
@export var exit_left: Room
@export var exit_top: Room
@export var exit_right: Room
@export var exit_bottom: Room

@export_category("Spawners")
## List of all room spawners.
@export var spawners: Array[Spawner]

func activate_spawners() -> void:
	# Loop through all spawners and activate them
	for spawner in spawners:
		spawner.set_active(true)
		# DEBUG: display activated spawner name and related room name
		print(spawner.name + " in " + self.name + " activated")

func deactivate_spawners() -> void:
	# Loop through all spawners and deactivate them
	for spawner in spawners:
		spawner.set_active(false)
		# DEBUG: display deactivated spawner name and related room name
		print(spawner.name + " in " + self.name + " deactivated")

# Loop through all spawners and despawn all spawned objects
func despawn_objects() -> void: for spawner in spawners: spawner.despawn()

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		$Label.text = self.name
	else:
		self.visible = false

func set_room_size() -> void:
	if Engine.is_editor_hint():
		size.x = 256 * room_width_x
		size.y = 224 * room_width_y
