class_name Spawner extends Node2D

## Variable name is descriptive enough.
@export var object_to_spawn: PackedScene
## How many objects can be spawned. 0 means it will spit objects indefinitely.
@export var object_limit: int = 0
## Delay between each spawn() call in seconds. 0 means it will spawn immediately.
@export var spawn_delay: float = 0.0

var _player: Player

@onready var visibility_notifier = $VisibilityNotifier
@onready var spawn_delay_timer = $SpawnDelayTimer

# Array to keep track of spawned objects
var _object_list: Array = []
# This flag determines if this spawner is active or not
var _is_active: bool = false

func set_active(active: bool) -> void:
	_is_active = active
	_player =  get_tree().get_first_node_in_group("Player")
	if !active: return
	if visibility_notifier.is_on_screen():
		spawn()
		if spawn_delay > 0.0:
			spawn_delay_timer.wait_time = spawn_delay
			spawn_delay_timer.start()

func spawn() -> void:
	if object_to_spawn and _is_active: # Check if spawner is active and there's an object to spawn
		# Instantiate object(s)
		var obj_instance = object_to_spawn.instantiate()
		# Pass reference to Player to the object
		obj_instance._player_reference = _player
		# Add obj_instance as child
		add_child(obj_instance)
		obj_instance.connect("enemy_died", remove_object_from_list)
		# Add object to _object_list array
		_object_list.append(obj_instance)
		# Assign it's position to spawners' position
		obj_instance.global_position = self.global_position

func despawn() -> void:
	if !_object_list.is_empty():
		for obj in _object_list:
			obj.call_deferred("queue_free")
			_object_list.erase(obj)

func remove_object_from_list(obj: Node2D) -> void:
	# Don't bother with looping through an array if there's only one object possible.
	if object_limit < 2: _object_list.erase(obj)
	elif object_limit > 1:
		var obj_id = obj.get_instance_id() # Get ID of current object.
		for object in _object_list:
			if object.get_instance_id() == obj_id: # Erase it if it's ID matches.
				_object_list.erase(object)
	print(obj)
	print(_object_list)

func _on_screen_entered():
	if _object_list.size() < object_limit:
		spawn()

func _on_spawn_delay_timeout():
	pass # Replace with function body.
