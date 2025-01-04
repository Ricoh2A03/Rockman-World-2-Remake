extends Scene

@export_category("Stage Selection Cursor")
@export var cursor: TextureRect

@export var portrait_container: Node2D

var portraitsXY = []

func _ready():
	print(get_tree().current_scene)
	AudioServer.set_bus_volume_db(0, -12)
	super._ready()

	var portraitsX = []
	var portraitsY = []
	if portrait_container:
		for child in portrait_container.get_children():
			portraitsX.append(child)
			#print(portraitsX)

	portraitsXY = [portraitsX, portraitsY]
	#print(portraitsXY[0][0])

func _process(delta):
	pass
