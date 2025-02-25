extends Scene

const X_TABLE = [56, 128, 200]
const Y_TABLE = [40, 112, 184]
const TABLE_SIZE = 2
const CURSOR_SPEED = 0.5

var cur_Xpos: int = 1
var cur_Ypos: int = 1

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("left"):
		if cur_Xpos != 0: cur_Xpos -= 1
		else: cur_Xpos = TABLE_SIZE
		%CursorSFX.play()

	if Input.is_action_just_pressed("right"):
		if cur_Xpos != TABLE_SIZE: cur_Xpos += 1
		else: cur_Xpos = 0
		%CursorSFX.play()

	if Input.is_action_just_pressed("up"):
		if cur_Ypos != 0: cur_Ypos -= 1
		else: cur_Ypos = TABLE_SIZE
		%CursorSFX.play()

	if Input.is_action_just_pressed("down"):
		if cur_Ypos != TABLE_SIZE: cur_Ypos += 1
		else: cur_Ypos = 0
		%CursorSFX.play()

	%Cursor.global_position.x = lerpf($"%Cursor".global_position.x, X_TABLE[cur_Xpos], CURSOR_SPEED)
	%Cursor.global_position.y = lerpf($"%Cursor".global_position.y, Y_TABLE[cur_Ypos], CURSOR_SPEED)
