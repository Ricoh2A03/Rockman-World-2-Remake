class_name StageCamera extends Camera2D

const SCREEN_WIDTH: int = 384
const SCREEN_HEIGHT: int = 224

var player_instance: Player

var _follow_target: bool = false
var _current_target: Node2D


func _ready() -> void:
	EventBus.stage_event_scroll_start.connect(camera_start_scroll)

func _process(delta):
	if _follow_target: _look_at_target()


func camera_start_scroll(scroll_direction: int, room: Room) -> void:
	# If no reference to the player exists, find it and set.
	if !player_instance: player_instance = get_tree().get_first_node_in_group("Player")

	# Stop following the player.
	_follow_target = false

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
	set_limits(room)
	# Follow player again.
	_follow_target = true


## Sets camera position to the [member _current_target]'s position.
func _look_at_target() -> void:
	self.global_position = _current_target.global_position


## Sets limits.
func set_limits(room: Room) -> void:
	if !room: return
	limit_left = room.global_position.x
	limit_top = room.global_position.y
	limit_right = limit_left + room.size.x
	limit_bottom = limit_top + room.size.y


## Sets target which camera would follow.
func set_target(target: Node2D) -> void: _current_target = target
