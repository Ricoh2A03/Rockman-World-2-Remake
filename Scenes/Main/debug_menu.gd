class_name DebugMenu extends Node

# SIGNALS

# ENUMS

# CONSTANTS

# STATIC VARS

# @EXPORT VARS

# VARIABLES


# @ONREADY VARS
@onready var fps_toggle: CheckBox = $Buttons/FPSToggle

# STATIC METHODS

# BUILT-IN METHODS
	#1. _init()
	#2. _enter_tree()
	#3. _ready()
	#4. _process()
	#5. _physics_process()
	#6. remaining virtual methods

# FUNCTIONS


# SIGNAL HANDLERS
func _on_fps_button_down() -> void:
	if !fps_toggle.button_pressed:
		Engine.max_fps = 30
	else:
		Engine.max_fps = 60
