extends Control

@onready var soil_sprite: AnimatedSprite2D = $SoilSprite
@onready var plant_sprite: AnimatedSprite2D = $PlantSprite
@onready var water_fx: AnimatedSprite2D = $WaterFX
@onready var action_bar: Control = $ActionBar
@onready var info_panel: PanelContainer = $InfoPanel
@onready var info_label: Label = $InfoPanel/InfoLabel

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

func update_plant_info():
	var status_text = ""
	var time_text = ""

	match soil_state:
		SoilState.EMPTY:
			status_text = "状态：空土地"
			time_text = "请先播种"
		SoilState.PLANTED, SoilState.WATERED:
			status_text = "作物：神秘种子 (阶段 %d/%d)" % [plant_stage, max_stage]
			var stages_left = max_stage - plant_stage
			if stages_left > 0:
				time_text = "距离成熟还需：%d 次成长" % stages_left
			else:
				time_text = "即将成熟..."
		SoilState.READY:
			status_text = "状态：已成熟！"
			time_text = "可以收割了"

	info_label.text = status_text + "\n" + time_text
	
func sow():
	if soil_state != SoilState.EMPTY:
		return

	soil_state = SoilState.PLANTED

	# 播放播种动画
	$PlantSprite.visible = true
	$PlantSprite.play("plant")

	

	plant_stage = 0
	$SoilSprite.visible = true
	$SoilSprite.frame = plant_stage
	update_plant_info()

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
	# 1. 切换显示：隐藏播种动画，显示静止的植物
	$PlantSprite.visible = false
	$SoilSprite.visible = true
	
	# 2. 判断是否已经长满了
	if plant_stage >= max_stage:
		soil_state = SoilState.READY
	else:
		# 3. 没长满：让它长一级
		plant_stage += 1
		$SoilSprite.frame = plant_stage # 切换图片
		
		# 4. 刚长完这一级，检查一下是不是刚好熟了
		if plant_stage == max_stage:
			soil_state = SoilState.READY
	
	# 5. 最后统一更新面板文字
	update_plant_info()

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
	update_plant_info()

func _on_sow_pressed():
	sow()
	_close_action_bar()

func _on_water_pressed():
	water()
	_close_action_bar()

func _close_action_bar():
	action_bar.visible = false
