class_name ColorLabel extends Label

const DEFAULT_COLOR = 0xBDBDC6
const DEFAULT_SHADOW = 0x5A5A63

@onready var shadow = $Shadow

func _ready():
	shadow.text = text
	shadow.horizontal_alignment = horizontal_alignment

## Both label texts will be set to a [param txt].
func set_label(txt: String) -> void:
	text = txt
	shadow.text = txt

## Sets main and shadow color.
func set_colors(main_color: Color, shadow_color: Color) -> void:
	theme.font_color = main_color
	shadow.theme.font_color = shadow_color

## Sets main and shadow colors to their default values.
func set_default_colors() -> void:
	theme.font_color = DEFAULT_COLOR
	shadow.theme.font_color = DEFAULT_SHADOW
