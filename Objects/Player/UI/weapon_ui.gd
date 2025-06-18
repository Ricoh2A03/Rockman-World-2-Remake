class_name WeaponUI extends CanvasLayer


@export var _is_animating: bool = false
@export var _is_opened: bool = false
@export var _is_paging: bool = false
@export var _active: bool = false

@export var _current_page: int = 0


@onready var menu_player := $AnimationPlayer
@onready var energy_bars := $EnergyBars
@onready var bg_player_1: AnimationPlayer = $WeaponMenu/BGSmallGrid/BGPlayer1
@onready var bg_player_2: AnimationPlayer = $WeaponMenu/BGBigGrid/BGPlayer2


func _input(event: InputEvent) -> void:
	if _is_opened and event.is_action_pressed("START"):
		open_weapon_menu()


func _ready() -> void:
	menu_player.play("health_fill")


func open_weapon_menu() -> void:
	if !_is_animating:
		if !_is_opened:
			Globals.main.pauseGame(["Player", "PlayerProjectile", "Enemy"], ["WeaponMenu"])
			bg_player_1.play("scroll")
			bg_player_2.play("scroll")
			menu_player.play("open_menu")
		else:
			menu_player.play("close_menu")


func add_item(item: InventoryItem):
	pass


func toggle_energy_bars(on: bool) -> void:
	if on: energy_bars.visible = true
	else: energy_bars.visible = false


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "close_menu":
		bg_player_1.stop()
		bg_player_2.stop()
		Globals.main.unpauseGame(["Player", "Enemy"])


#func _process(_delta: float) -> void:
	#if _active:
		#if _current_page == 0 and !_is_paging and Input.is_action_just_pressed("SHOULDER_R"):
			#menu_player.play("page_right")
		#elif _current_page == 1 and !_is_paging and Input.is_action_just_pressed("SHOULDER_L"):
			#menu_player.play("page_left")
