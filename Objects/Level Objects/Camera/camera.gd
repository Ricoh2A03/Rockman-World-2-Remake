class_name StageCamera extends Camera2D

#signal finished_scrolling(room: Room)

const SCREEN_WIDTH: int = 384
const SCREEN_HEIGHT: int = 224

var player_instance: Player
var follow_player: bool = true

func _ready() -> void:
	EventBus.stage_event_scroll_start.connect(camera_start_scroll)

func camera_start_scroll(scroll_direction: int, room: Room) -> void:
	# If no reference to the player exists, find it and set.
	if !player_instance: player_instance = get_tree().get_first_node_in_group("Player")

	# Stop following the player.
	follow(false)
	position_smoothing_enabled = false

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	var tarX: int
	var tarY: int

	match scroll_direction:

		0: # left
			self.limit_left = limit_left - SCREEN_WIDTH
			global_position.x = (room.global_position.x + room.size.x) + (SCREEN_WIDTH / 2)
			global_position.y = room.global_position.y + (SCREEN_WIDTH / 2)
			tarX = (room.global_position.x + room.size.x) - (SCREEN_WIDTH / 2)
			tarY = self.global_position.y

		1: # up
			global_position.x = player_instance.global_position.x #room.global_position.x + 128
			global_position.y = limit_top + room.size.y / 2
			tarX = player_instance.global_position.x #self.global_position.x
			tarY = self.global_position.y - room.size.y
			limit_top = self.limit_top - SCREEN_HEIGHT

		2: # right
			self.limit_right = limit_right + SCREEN_WIDTH
			global_position.x = room.global_position.x - (SCREEN_WIDTH / 2)
			global_position.y = room.global_position.y + (SCREEN_WIDTH / 2)
			tarX = room.global_position.x + (SCREEN_WIDTH / 2)
			tarY = self.global_position.y

		3: # down
			self.limit_bottom = limit_bottom + 256
			global_position.x = player_instance.global_position.x #room.global_position.x + 128
			global_position.y = (room.global_position.y - 114)
			tarX = self.global_position.x
			tarY = (room.global_position.y + 114)

	tween.tween_property(self, "global_position:x", tarX, 0.68)
	tween.tween_property(self, "global_position:y", tarY, 0.68)

	await tween.finished
	EventBus.stage_event_scroll_finished.emit(room)

	# Set camera limits to match dimensions of the new room.
	update_camera_limits(room)
	#position_smoothing_enabled = true
	# Follow player again.
	follow(true)
	# Allign with the player.
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
