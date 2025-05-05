class_name PlayerState extends Node

## Pointer to the [Player] node.
var ptr_player: Player

## Next state to switch to at the start of the next iteration of the loop.
var next_state: PlayerState

@export_category("State Flags")
## If set to [code]false[/code], player's input is not processed in this state.
@export var can_move: bool = false
## If set to [code]false[/code], player can't attack in this state.
@export var can_attack: bool = false
## If set to [code]false[/code], gravity is not applied in this state.
@export var apply_gravity: bool = false
## If set to [code]false[/code], [param move_and_slide()] isn't called in this state.
@export var call_move_and_slide: bool = false
## Determines if weapon menu can be opened.
@export var can_open_weapon_menu: bool = false

## State's update routine. Called by [PlayerStateMachine].
func _update_state(delta) -> void: pass

## Called when first entering this state.
func _on_enter() -> void: pass

## Called when exiting this state.
func _on_exit() -> void: pass
