@tool
class_name Checkpoint extends Marker2D


@export var associated_room: Room


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		$CheckpointLabel.text = self.name
	else:
		self.visible = false
