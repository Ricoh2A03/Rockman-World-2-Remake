extends Scene

var _tar_cursorX: int = 256/2
var _cursorX: int = 256/2

var _tar_cursorY: int = 224/2
var _cursorY: int = 224/2

func _ready() -> void:
	pass

func _process(delta: float) -> void:

	if _cursorX < _tar_cursorX: _cursorX += 16
	elif _cursorX > _tar_cursorX: _cursorX -= 16

	if _cursorY < _tar_cursorY: _cursorY += 16
	elif _cursorY > _tar_cursorY: _cursorY -= 16

	%Cursor.global_position.x = _cursorX
	%Cursor.global_position.y = _cursorY
