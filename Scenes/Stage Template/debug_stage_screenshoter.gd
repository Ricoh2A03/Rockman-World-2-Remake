extends Node

# CONSTANTS
const ROOM_WIDTH = 384
const ROOM_HALF_WIDTH = 192
const ROOM_HALF_HEIGHT = 112


# @EXPORT VARS
@export var room_container: Node


# VARIABLES
var _rooms: Array[Room]


# @ONREADY VARS
@onready var screenshot_button: Button = $ScreenshotButton
@onready var camera: Camera2D = $Camera


# FUNCTIONS
func _take_screenshot() -> void:
	if room_container:

		for room in room_container.get_children():
			_rooms.append(room)

		var screenshots_folder = room_container.get_parent().name + "Screenshots"
		var dir = DirAccess.open("user://")
		dir.make_dir(screenshots_folder)

		var cur_cam = get_viewport().get_camera_2d()
		cur_cam.enabled = false
		camera.enabled = true
		screenshot_button.hide()

		for room in _rooms:
			if room.room_width_x == 1:
				camera.global_position = room.global_position + Vector2(ROOM_HALF_WIDTH, ROOM_HALF_HEIGHT)
				await RenderingServer.frame_post_draw
				var img = get_viewport().get_texture().get_image()
				img.save_png("user://" + screenshots_folder + "/" + room.name + ".png")
			else:
				for width in room.room_width_x:
					if width < 1:
						camera.global_position = room.global_position + Vector2(ROOM_HALF_WIDTH, ROOM_HALF_HEIGHT)
					else:
						camera.global_position.x = camera.global_position.x + ROOM_WIDTH
					await RenderingServer.frame_post_draw
					var img = get_viewport().get_texture().get_image()
					img.save_png("user://" + screenshots_folder + "/" + room.name + "-" + var_to_str(width + 1) + ".png")

		camera.enabled = false
		cur_cam.enabled = true
		screenshot_button.show()


# SIGNAL HANDLERS
func _on_screenshot_button_down() -> void:
	_take_screenshot()
