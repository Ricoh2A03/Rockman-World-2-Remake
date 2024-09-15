@tool
extends Area2D
class_name ScrollTrigger

signal start_scroll(target_view: Room, direction: int)

@export_category("Room Handling")
@export var to_room: Room

@export_category("Scroll Direction")
enum SCRLDIR {Left, Right, Up, Down}
@export var scroll_direction: SCRLDIR:
	set(value):
		match value:
			SCRLDIR.Left:
				$Label.text = "←"
				$Label.position.y = -12
				$Label.position.x = -10 - 16
				$Panel.position.y = -13
				$Panel.position.x = -13 - 15

			SCRLDIR.Right:
				$Label.text = "→"
				$Label.position.y = -12
				$Label.position.x = -10 + 14
				$Panel.position.y = -13
				$Panel.position.x = -13 + 15

			SCRLDIR.Up:
				$Label.text = "↑"
				$Label.position.x = -10
				$Label.position.y = -12 - 14
				$Panel.position.y = -13 - 15
				$Panel.position.x = -13

			SCRLDIR.Down:
				$Label.text = "↓"
				$Label.position.x = -10
				$Label.position.y = -12 + 16
				$Panel.position.y = -13 + 15
				$Panel.position.x = -13

		scroll_direction = value

@export_category("Associated Checkpoint")
@export var associated_checpoint: Checkpoint

func _enter_tree():
	set_process(false)
	if !Engine.is_editor_hint():
		#self.visible = false
		pass

func scroll_triggered():
	if !to_room: return
	start_scroll.emit(to_room, scroll_direction)

	#match scroll_direction:
		#SCRLDIR.Up:
			#if (body.state == body.STATES.CLIMB and body.velocity.y < 0):
				##set_collision_mask_value(3, false) # turn detection off
				#start_scroll.emit(to_room, scroll_direction)
		#SCRLDIR.Down:
			#if (body.state == body.STATES.CLIMB and body.velocity.y > 0) or (body.state == body.STATES.AIR and body.velocity.y > 0):
				##set_collision_mask_value(3, false) # turn detection off
				#start_scroll.emit(to_room, scroll_direction)
#
		#SCRLDIR.Left:
			#set_collision_mask_value(3, false) # turn detection off
			#start_scroll.emit(to_room, scroll_direction)
		#SCRLDIR.Right:
			#set_collision_mask_value(3, false) # turn detection off
			#start_scroll.emit(to_room, scroll_direction)

func destroy():
	queue_free()
