class_name PauseComponent extends Node


@export var _node_to_pause: Node
var _paused: bool = false
var _backup_process_mode: int


func _pause_node():
	if _node_to_pause and not _paused:
		_backup_process_mode = _node_to_pause.process_mode
		_node_to_pause.process_mode = Node.PROCESS_MODE_PAUSABLE


func _exception():
		if _node_to_pause and not _paused:
			_backup_process_mode = _node_to_pause.process_mode
			_node_to_pause.process_mode = Node.PROCESS_MODE_ALWAYS


func _unpause_node():
	if _paused:
		_node_to_pause.process_mode = _backup_process_mode
