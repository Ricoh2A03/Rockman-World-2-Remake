## Class for creating states for [Player].
class_name PlayerStateMachine extends Node

## An [Array] which holds all [PlayerState]'s.[br]
## Filled up when first entering a tree.
var states: Array[PlayerState]
## Currently active [PlayerState].
@export var current_state: PlayerState

func _ready() -> void:
	for child in get_children():
		if child is PlayerState:
			states.append(child)
			child.ptr_player = get_parent()
		else: push_warning(child.name + "is not a PlayerState")

func _process(delta: float) -> void:
	if current_state.next_state != null:
		_change_to_state(current_state.next_state)
	current_state._update_state(delta)

## Tells if can move in [member current_state].
func _check_if_can_move() -> bool: return current_state.can_move

## Changes [member current_state] to the passed state.
func _change_to_state(new_state: PlayerState) -> void:
	if current_state != null:
		current_state._on_exit()
		current_state.next_state = null
	current_state = new_state
	current_state._on_enter()
