class_name InventoryItem extends Resource

## Icon for the inventory.
@export var icon: Texture2D

## Slot in which this item will appear.
@export var target_slot: int

## Item limit on screen.
@export_range(1, 16) var max_on_screen: int

@export var XSpawnOffset: int
@export var YSpawnOffset: int

@export_group("Scene")
## What will be created when using this item.
@export var scene_to_spawn: PackedScene

@export_group("Sound")
## Sound that will be used.
@export var sound: AudioStreamWAV
