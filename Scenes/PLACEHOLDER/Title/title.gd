extends Scene

const cur_pos1 = 144
const cur_pos2 = 168 

var _can_select: bool = true
var _selection: int = 0

func _input(event):
	if event.is_action_pressed("weapon_menu"):
		if _selection == 0:
			_can_select = false
			if scene_transitor:
				Globals.main.transit_to_scene(0.35, scene_transitor.scenes[0])
		elif _selection == 1:
			_can_select = false
			if scene_transitor:
				Globals.main.transit_to_scene(0.35, scene_transitor.scenes[1])

	if _can_select and event.is_action_pressed("up"):
		%CursorSFX.play()
		_selection -= 1
		if _selection < 0: _selection = 1

	if _can_select and event.is_action_pressed("down"):
		%CursorSFX.play()
		_selection += 1
		if _selection > 1: _selection = 0

func _process(delta: float) -> void:
	if _selection == 0:
		%Cursor.position.y = cur_pos1
	else:
		%Cursor.position.y = cur_pos2
