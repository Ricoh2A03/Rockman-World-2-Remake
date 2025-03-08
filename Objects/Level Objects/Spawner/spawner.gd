class_name Spawner extends Node2D

## Variable name is descriptive enough.
@export var object_to_spawn: PackedScene
## How many objects can be spawned. 0 means it will spit objects indefinitely.
@export var object_limit: int = 0
## Delay between each spawn() call in seconds. 0 means it will spawn immediately.
@export var spawn_delay: float = 0.0

@onready var visibility_notifier = $VisibilityNotifier
@onready var spawn_delay_timer = $SpawnDelayTimer

# Array to keep track of spawned objects
var _object_list: Array = []
# This flag determines if this spawner is active or not
var _is_active: bool = false

func set_active(active: bool):
	_is_active = active
	if !active: return
	if visibility_notifier.is_on_screen():
		spawn()
		if spawn_delay > 0.0:
			spawn_delay_timer.wait_time = spawn_delay
			spawn_delay_timer.start()

func spawn():
	if object_to_spawn and _is_active: # Check if spawner is active and there's an object to spawn
		# Instantiate object(s)
		var obj_instance = object_to_spawn.instantiate()
		# Add obj_instance as child
		add_child(obj_instance)
		# Assign it's position to spawners' position
		obj_instance.global_position = self.global_position
		# Add object to _object_list array
		_object_list.append(obj_instance)

func despawn():
	if !_object_list.is_empty():
		for obj in _object_list:
			obj.call_deferred("queue_free")
			_object_list.erase(obj)

func _on_screen_entered():
	if _object_list.size() < object_limit:
		spawn()

func _on_spawn_delay_timeout():
	pass # Replace with function body.
