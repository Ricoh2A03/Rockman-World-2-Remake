extends Camera2D

signal finished_scrolling(room: Room)

var player_instance: Player
var follow_player: bool = true

func _ready() -> void:
	pass

# камере нужна новая комната и направление, чтобы знать, какие границы сделать в конце скроллинга и куда скроллить(про н.к. и направ. знает триггер)
# уровню нужна новая комната и направление, чтобы знать, где её спавнить (про н.к. и направ. знает триггер)

func camera_start_scroll(new_room: Room, scroll_direction) -> void:
	follow(false)

	var room = new_room

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	var tarX: int
	var tarY: int

	match scroll_direction:

		0: # left
			self.limit_left = limit_left - 256
			global_position.x = (room.global_position.x + room.size.x) + 128
			global_position.y = room.global_position.y + 128
			tarX = (room.global_position.x + room.size.x) - 128
			tarY = self.global_position.y

		2: # right
			self.limit_right = limit_right + 256
			global_position.x = room.global_position.x - 128
			global_position.y = room.global_position.y + 128
			tarX = room.global_position.x + 128
			tarY = self.global_position.y

		1: # up
			self.limit_top = limit_top - 256
			global_position.x = room.global_position.x + 128
			global_position.y = (room.global_position.y + room.size.y) + (room.size.y / 2)

		3: # down
			self.limit_bottom = limit_bottom + 256
			global_position.x = room.global_position.x + 128
			global_position.y = (room.global_position.y - 114)
			tarX = self.global_position.x
			tarY = (room.global_position.y + 114)

	tween.tween_property(self, "global_position:x", tarX, 1.25)
	tween.tween_property(self, "global_position:y", tarY, 1.25)

	await tween.finished
	finished_scrolling.emit(new_room)

	update_camera_limits(new_room)
	follow(true)
	global_position = get_parent().global_position

##########################################

func update_camera_limits(room: Room) -> void:
	if !room: return
	limit_left = room.global_position.x
	limit_top = room.global_position.y
	limit_right = limit_left + room.size.x
	limit_bottom = limit_top + room.size.y

##########################################

func follow(to_follow: bool) -> void:
	if to_follow == true:
		top_level = false
	else:
		top_level = true
