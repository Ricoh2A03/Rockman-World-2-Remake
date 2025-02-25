extends Scene

const Y_TABLE = [144, 168]
const CURSOR_SPEED = 0.5

var cur_Ypos: int = 0

var _can_select: bool = true

func _input(event):
	if event.is_action_pressed("weapon_menu"):
		_can_select = false
		if scene_transitor:
			Globals.main.transit_to_scene(0.35, scene_transitor.scenes[cur_Ypos])

	if _can_select and event.is_action_pressed("up"):
		if cur_Ypos != 0: cur_Ypos -= 1
		else: cur_Ypos = Y_TABLE.size() - 1
		%CursorSFX.play()

	if _can_select and event.is_action_pressed("down"):
		if cur_Ypos != Y_TABLE.size() - 1: cur_Ypos += 1
		else: cur_Ypos = 0
		%CursorSFX.play()

func _process(delta: float) -> void:
	%Cursor.position.y = lerpf($"%Cursor".position.y, Y_TABLE[cur_Ypos], 0.5)
