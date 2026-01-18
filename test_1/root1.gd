extends Control

@onready var soil_sprite: AnimatedSprite2D = $SoilSprite
@onready var plant_sprite: AnimatedSprite2D = $PlantSprite
@onready var water_fx: AnimatedSprite2D = $WaterFX
@onready var action_bar: Control = $ActionBar


enum SoilState {
	EMPTY,
	PLANTED,
	WATERED,
	GROWN,
	READY
}

var soil_state := SoilState.EMPTY
var plant_stage := 0
var max_stage := 5


func sow():
	if soil_state != SoilState.EMPTY:
		return

	soil_state = SoilState.PLANTED

	# 播放播种动画
	$PlantSprite.visible = true
	$PlantSprite.play("plant")

	# 播完后显示植物
	await $SoilSprite.animation_finished

	plant_stage = 0
	$SoilSprite.visible = true
	$SoilSprite.frame = plant_stage

func water():
	if soil_state != SoilState.PLANTED:
		return

	# 播放浇水动画（不影响土地状态）
	$WaterFX.visible = true
	$WaterFX.play("water")

	await $WaterFX.animation_finished
	$WaterFX.visible = false

	#if last_water_time + grow_interval < Time.get_unix_time_from_system():
		#_grow()

	_grow()

func _grow():
	$PlantSprite.visible = false
	$SoilSprite.visible = true
	if plant_stage >= max_stage:
		soil_state = SoilState.READY
		return

	plant_stage += 1
	$SoilSprite.frame = plant_stage

	if plant_stage == max_stage:
		soil_state = SoilState.READY

func _ready():
		# ===== 初始化显示状态（🔥关键）=====
	soil_sprite.visible = false
	plant_sprite.visible = false
	water_fx.visible = false
	action_bar.visible = false

	# 防止残留帧
	soil_sprite.stop()
	plant_sprite.stop()
	water_fx.stop()

	action_bar.sow_pressed.connect(_on_sow_pressed)
	action_bar.water_pressed.connect(_on_water_pressed)
	var win := get_window()
	win.content_scale_factor = 1.0
	# 无边框
	DisplayServer.window_set_flag(
		DisplayServer.WINDOW_FLAG_BORDERLESS, true
	)

	# 固定窗口大小（防止被拉伸）
	DisplayServer.window_set_min_size(Vector2i(300, 300))
	DisplayServer.window_set_max_size(Vector2i(300, 300))

	# 设置初始位置（右下角）
	var screen_size = DisplayServer.screen_get_size()
	DisplayServer.window_set_position(
		screen_size - Vector2i(320, 360)
	)

	# 透明背景
	get_viewport().transparent_bg = true

func _on_sow_pressed():
	sow()
	_close_action_bar()

func _on_water_pressed():
	water()
	_close_action_bar()

func _close_action_bar():
	action_bar.visible = false
