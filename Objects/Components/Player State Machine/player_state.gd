class_name PlayerState extends Node

## Pointer to the [param Player] node.
var ptr_player: Player

## Next state to switch to at the start of the next iteration of the loop.
var next_state: PlayerState

@export_category("Physics Flags")
## Determines if player's input should be processed in this state.
@export var can_move: bool = true
@export var apply_gravity: bool = true
@export var call_move_and_slide: bool = true

## State's update routine. Called by [PlayerStateMachine].
func _update_state(_delta) -> void:
	pass

## Called when first entering this state.
func _on_enter() -> void:
	pass

## Called when exiting this state.
func _on_exit() -> void:
	pass
