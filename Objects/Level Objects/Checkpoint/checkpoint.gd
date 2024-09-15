@tool
extends Marker2D
class_name Checkpoint

@export var stage_reference: Stage
@export var associated_room: Room

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		$CheckpointLabel.text = self.name
	else:
		self.visible = false
	
