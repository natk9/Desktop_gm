extends Node

@onready var anim: AnimatedSprite2D = $Player/AnimatedSprite2D
@onready var click_area: Area2D = $Player/ClickArea


var is_dragging := false
var drag_start_mouse_pos := Vector2i.ZERO
var drag_start_window_pos := Vector2i.ZERO

enum FishingState {
	IDLE,           # 待机
	LIGHT_BITE,     # 轻微抖动
	HEAVY_BITE,     # 剧烈抖动（第一次点击）
	PULLING,        # 拉扯阶段（3 秒判定）
	CATCH,          # 上鱼
	ESCAPED,        # 脱杆
	CASTING         # 重新抛竿
}


var state: FishingState = FishingState.IDLE


# ====== 概率 & 时间配置 ======

## 上鱼动画列表
#@export var fish_catch_anims := [
	#"fish_caught_1",
	#"fish_caught_2",
#]


@export var idle_to_bite_time := Vector2(5.0, 15.0)
@export var light_to_heavy_chance := 0.4
@export var heavy_chance_timeout := 4.0
@export var pulling_timeout := 3.0
@export var catch_hold_time := 2.0

func _ready():
	click_area.input_event.connect(_on_click)
	_enter_idle()
#func _process(delta):
	#timer -= delta
#
	#match state:
		#FishingState.IDLE:
			#if timer <= 0:
				#_enter_light_bite()
#
		#FishingState.LIGHT_BITE:
			#if timer <= 0:
				#if randf() < light_to_heavy_chance:
					#_enter_heavy_bite()
				#else:
					#_enter_idle()
#
		#FishingState.HEAVY_BITE:
			#if timer <= 0:
				#_enter_escape()


func _enter_idle():
	state = FishingState.IDLE
	anim.play("idle")

	await get_tree().create_timer(
		randf_range(idle_to_bite_time.x, idle_to_bite_time.y)
	).timeout

	_enter_light_bite()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_start_window_drag()
			else:
				is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		_update_window_drag()

func _start_window_drag():
	is_dragging = true
	drag_start_mouse_pos = DisplayServer.mouse_get_position()
	drag_start_window_pos = DisplayServer.window_get_position()

func _update_window_drag():
	var current_mouse_pos = DisplayServer.mouse_get_position()
	var delta: Vector2i = current_mouse_pos - drag_start_mouse_pos
	DisplayServer.window_set_position(drag_start_window_pos + delta)

func _enter_light_bite():
	state = FishingState.LIGHT_BITE
	anim.play("rod_shake_light")

	await get_tree().create_timer(randf_range(1.5, 3.0)).timeout

	if randf() < light_to_heavy_chance:
		_enter_heavy_bite()
	else:
		_enter_idle()

func _enter_heavy_bite():
	state = FishingState.HEAVY_BITE
	anim.play("rod_shake_heavy")

	await get_tree().create_timer(heavy_chance_timeout).timeout

	if state == FishingState.HEAVY_BITE:
		_enter_escape()

func _enter_pulling():
	state = FishingState.PULLING
	anim.play("reel_success") # 拉扯动画

	await get_tree().create_timer(pulling_timeout).timeout

	if state == FishingState.PULLING:
		_enter_escape()


func _enter_catch():
	state = FishingState.CATCH
	anim.play("fish_anim")

	await anim.animation_finished

	# 停在最后一帧 2 秒
	anim.pause()
	await get_tree().create_timer(catch_hold_time).timeout
	anim.play()

	_enter_casting()

func _enter_escape():
	state = FishingState.ESCAPED
	anim.play("fish_escape")
	
	await anim.animation_finished
	_enter_idle()
	#await anim.animation_finished
	#_enter_casting()

func _enter_casting():
	state = FishingState.CASTING
	anim.play("paogan")

	await anim.animation_finished
	_enter_idle()

	##var fish_anim = fish_catch_anims.pick_random()
	#anim.play("fish_anim")
	#await anim.animation_finished
	#
	#state = FishingState.PAOGAN
	#anim.play("paogan")
#
	#_enter_idle()
func _on_click(_viewport, event, _shape_idx):
	if not (event is InputEventMouseButton and event.pressed):
		return

	match state:
		FishingState.HEAVY_BITE:
			_enter_pulling()

		FishingState.PULLING:
			_enter_catch()
