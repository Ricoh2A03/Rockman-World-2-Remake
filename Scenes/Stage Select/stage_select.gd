extends Scene

#region Constants
const X_TABLE = [56, 128, 200]
const Y_TABLE = [40, 112, 184]

const BOSS_SPRITES_TABLE = [
	null,
	preload("res://Assets/Robot Masters/Air Man/air_master_idle0.png"),
	null,
	null,
	null,
	null,
	null,
	null,
	null
]

const BOSS_NAMES_TABLE = [
	"HARD MAN",
	"AIR MAN",
	"NEEDLE MAN",
	"TOP MAN",
	"",
	"WOOD MAN",
	"METAL MAN",
	"MAGNET MAN",
	"CRASH MAN"
]

const STAGES = 8

const GRID_WIDTH = 3
const CURSOR_SPEED = 0.5
#endregion

var cur_Xpos: int = 1
var cur_Ypos: int = 1

var can_select: int = true
var selection: int

var animate_streaks: bool = false

@export var mus_stage_start: AudioStream

#region Initialization routine
func _ready() -> void:
	super._ready()
#endregion

#region Update routine
func _process(_delta: float) -> void:

	# 2D into 1D
	# index = j * WIDTH + i
	selection = cur_Ypos * 3 + cur_Xpos

	if can_select:
		if Input.is_action_just_pressed("left"):
			if cur_Xpos != 0: cur_Xpos -= 1
			else: cur_Xpos = X_TABLE.size() - 1
			%CursorSFX.play()

		if Input.is_action_just_pressed("right"):
			if cur_Xpos != X_TABLE.size() - 1: cur_Xpos += 1
			else: cur_Xpos = 0
			%CursorSFX.play()

		if Input.is_action_just_pressed("up"):
			if cur_Ypos != 0: cur_Ypos -= 1
			else: cur_Ypos = Y_TABLE.size() - 1
			%CursorSFX.play()

		if Input.is_action_just_pressed("down"):
			if cur_Ypos != Y_TABLE.size() - 1: cur_Ypos += 1
			else: cur_Ypos = 0
			%CursorSFX.play()

		if Input.is_action_just_pressed("weapon_menu") and !Globals.main.get_scene_transition():
			if scene_transitor.scenes[selection]:
				can_select = false
				%Cursor.visible = false
				Globals.main.fade_music(false, 0.50)
				%StageSelectedSFX.play()

		%BossIntro.global_position = Vector2(-64, 0)
	else:
		pass

	if animate_streaks:
		$BGContainer/BGStreaks1.position.x -= 8
		if $BGContainer/BGStreaks1.position.x == -256: $BGContainer/BGStreaks1.position.x = 0
		$BGContainer/BGStreaks2.position.x -= 4
		if $BGContainer/BGStreaks2.position.x == -256: $BGContainer/BGStreaks2.position.x = 0
		$BGContainer/BGStreaks3.position.x -= 1
		if $BGContainer/BGStreaks3.position.x == -256: $BGContainer/BGStreaks3.position.x = 0

	%Cursor.global_position.x = lerpf($"%Cursor".global_position.x, X_TABLE[cur_Xpos], CURSOR_SPEED)
	%Cursor.global_position.y = lerpf($"%Cursor".global_position.y, Y_TABLE[cur_Ypos], CURSOR_SPEED)
#endregion

#region Signals
func _on_selected_sfx_finished() -> void:
	Globals.main.play_music(mus_stage_start)
	%AnimationPlayer.play("transition_start")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transition_start":
		$%ScreenFlash.visible = true
		%BossIntro.texture = BOSS_SPRITES_TABLE[selection]
		%BossNameLabel.text = BOSS_NAMES_TABLE[selection]
		%BossIntro.global_position.x = 184 #X_TABLE[cur_Xpos]
		%BossIntro.global_position.y = 112 #Y_TABLE[cur_Ypos]
		animate_streaks = true
		var timer = get_tree().create_timer(0.15)
		await timer.timeout
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(%ScreenFlash, "self_modulate", Color(255, 255, 255, 0), 1)
		%SceneTransitionDelay.start()

func _on_scene_transition_delay_timeout() -> void:
	Globals.main.goto_scene(0.35, scene_transitor.scenes[selection])
#endregion
