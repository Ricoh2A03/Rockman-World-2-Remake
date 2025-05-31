class_name BasicProjectile extends Node2D

## Tells VariableWeaponSystem to erase projectile from on screen list.
signal screen_exited()

@export_category("Projectile ID")
## ID which tells enemies which damage to apply using damage table.
@export var id: int = 0

@export_category("Velocities")
@export var xSpeed: int = 0
@export var ySpeed: int = 0

@export_group("Gravity")
## Turn on for arc-shaped travel paths.
@export var apply_gravity: bool = false
@export var gravity: int = 0

@export_group("Misc.")
@export var destroy_on_impact: bool = true

## Tells whether projectile collided with something.
var _collided: bool = false
var _direction: int = 1


## Sets projectile direction.
func set_direction(dir: int) -> void: _direction = dir


## Returns projectiles ID.
func get_id() -> int: return id


## Deflects projectile in a specified direction.
func deflect() -> void:
	pass
