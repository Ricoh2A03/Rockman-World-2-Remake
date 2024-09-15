extends Resource
class_name PlayerStats

## Gravity. Bigger values make character fall faster. Also affects jump height.
@export var gravity: int

## Speed at which character moves horizontally.
@export var horizontal_speed: int

## Speed at which character steps.
@export var step_speed: int

## Speed at which character jumps. Bigger values affect speed and height of the jump.
@export var jump_force: int

## Speed at which character slides.
@export var slide_speed: int

## Speed at which character climbs.
@export var climb_speed: int
