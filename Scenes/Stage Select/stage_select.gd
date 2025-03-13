extends Scene

const X_TABLE = [56, 128, 200]
const Y_TABLE = [40, 112, 184]

const STAGES = 8

const GRID_WIDTH = 3
const CURSOR_SPEED = 0.5

var cur_Xpos: int = 1
var cur_Ypos: int = 1

var selection: int

func _ready() -> void:
	super._ready()

func _process(_delta: float) -> void:

	# 2D into 1D
	# index = j * WIDTH + i
	selection = cur_Ypos * 3 + cur_Xpos

	if !Globals.main.is_transiting:
		if Input.is_action_just_pressed("left"):
			if cur_Xpos != 0: cur_Xpos -= 1
			else: cur_Xpos = X_TABLE.size() - 1
			%CursorSFX.play()

		if Input.is_action_just_pressed("right"):
			if cur_Xpos != X_TABLE.size() - 1: cur_Xpos += 1
			else: cur_Xpos = 0
			%CursorSFX.play()

		if Input.is_action_just_pressed("up"):
			if cur_Ypos != 0: cur_Ypos -= 1
			else: cur_Ypos = Y_TABLE.size() - 1
			%CursorSFX.play()

		if Input.is_action_just_pressed("down"):
			if cur_Ypos != Y_TABLE.size() - 1: cur_Ypos += 1
			else: cur_Ypos = 0
			%CursorSFX.play()

		if Input.is_action_just_pressed("weapon_menu"):
			if scene_transitor.scenes[selection]:
				Globals.main.transit_to_scene(0.35, scene_transitor.scenes[selection])

	%Cursor.global_position.x = lerpf($"%Cursor".global_position.x, X_TABLE[cur_Xpos], CURSOR_SPEED)
	%Cursor.global_position.y = lerpf($"%Cursor".global_position.y, Y_TABLE[cur_Ypos], CURSOR_SPEED)
