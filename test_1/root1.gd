extends Control

# === 🌿 节点引用 ===
@onready var soil_sprite: AnimatedSprite2D = $SoilSprite
@onready var plant_sprite: AnimatedSprite2D = $PlantSprite
@onready var water_fx: AnimatedSprite2D = $WaterFX
@onready var action_bar: Control = $ActionBar
@onready var info_panel: PanelContainer = $InfoPanel
@onready var info_label: Label = $InfoPanel/InfoLabel

# === ⚙️ 状态与配置 ===
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
var plant_name = "神秘种子"

# === ⏱️ 时间系统配置 ===
var stage_duration: int = 60 # 每一级需要 60 秒
var target_timestamp: float = 0.0 # 下一次成长的“目标时刻”
var save_path = "user://savegame.save" # 存档路径

func _ready():
	# 初始化窗口设置（保持你原有的设置）
	var win := get_window()
	win.content_scale_factor = 1.0
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_min_size(Vector2i(300, 300))
	DisplayServer.window_set_max_size(Vector2i(300, 300))
	var screen_size = DisplayServer.screen_get_size()
	DisplayServer.window_set_position(screen_size - Vector2i(320, 360))
	get_viewport().transparent_bg = true

	# 绑定按钮信号
	action_bar.sow_pressed.connect(_on_sow_pressed)
	action_bar.water_pressed.connect(_on_water_pressed)
	
	# 🔥 启动核心：读取存档 -> 刷新画面
	load_game()
	update_plant_info()

# === 🔄 每帧检测 (心跳) ===
func _process(delta):
	# 如果没种或者熟了，就不跑计时逻辑
	if soil_state == SoilState.EMPTY or soil_state == SoilState.READY:
		return
	
	var current_time = Time.get_unix_time_from_system()
	
	# ⏰ 时间到了！
	if current_time >= target_timestamp:
		_grow_logic() # 数值 +1
		_refresh_visuals() # 换图片
		
		# 如果还没熟，设定下一级的时间
		if soil_state != SoilState.READY:
			target_timestamp = current_time + stage_duration
			
		save_game() # 自动存个档
	
	# 更新倒计时文字
	update_plant_info()

# === 🌱 核心互动逻辑 ===

func sow():
	if soil_state != SoilState.EMPTY:
		return

	soil_state = SoilState.PLANTED
	plant_stage = 0
	
	# 设定第一次成长目标：现在 + 60秒
	target_timestamp = Time.get_unix_time_from_system() + stage_duration
	
	# 播放动画
	plant_sprite.visible = true
	plant_sprite.play("plant")
	await plant_sprite.animation_finished
	
	_refresh_visuals()
	save_game()

func water():
	# 只有种了且没熟的时候才能浇水
	if soil_state == SoilState.READY or soil_state == SoilState.EMPTY:
		return

	# 播放特效
	water_fx.visible = true
	water_fx.play("water")
	await water_fx.animation_finished
	water_fx.visible = false

	# 🔥 浇水效果：时间减少 20 秒 (加速)
	var reduce_time = 20.0
	target_timestamp -= reduce_time
	
	# 强制更新一下UI，让玩家立刻看到时间变少了
	update_plant_info()
	save_game()

# 纯数值增长（用于后台计算）
func _grow_logic():
	if plant_stage < max_stage:
		plant_stage += 1
		if plant_stage == max_stage:
			soil_state = SoilState.READY
			target_timestamp = 0.0 # 熟了就不计时了

# 刷新画面
func _refresh_visuals():
	if soil_state == SoilState.EMPTY:
		soil_sprite.visible = false
		plant_sprite.visible = false
	else:
		soil_sprite.visible = true
		plant_sprite.visible = false
		soil_sprite.frame = plant_stage
	
	update_plant_info()

# === 📝 UI 更新 ===
func update_plant_info():
	var status_text = ""
	var time_text = ""

	match soil_state:
		SoilState.EMPTY:
			status_text = "状态：空土地"
			time_text = "请播种"
		SoilState.PLANTED, SoilState.WATERED:
			status_text = "作物：%s (阶段 %d/%d)" % [plant_name, plant_stage, max_stage]
			
			# 计算剩余秒数
			var time_left = target_timestamp - Time.get_unix_time_from_system()
			if time_left < 0: time_left = 0
			
			# 格式化显示 00:00
			var minutes = int(time_left / 60)
			var seconds = int(time_left) % 60
			time_text = "成长倒计时：%02d:%02d" % [minutes, seconds]
			
		SoilState.READY:
			status_text = "状态：已成熟！"
			time_text = "✅ 可收割"

	info_label.text = status_text + "\n" + time_text

# === 💾 存读档系统 ===
func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var data = {
		"soil_state": soil_state,
		"plant_stage": plant_stage,
		"target_timestamp": target_timestamp
	}
	file.store_string(JSON.stringify(data))

func load_game():
	if not FileAccess.file_exists(save_path):
		return # 没存档，跳过

	var file = FileAccess.open(save_path, FileAccess.READ)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	
	if data:
		soil_state = int(data["soil_state"])
		plant_stage = int(data["plant_stage"])
		target_timestamp = float(data["target_timestamp"])
		
		# 🔥 离线结算：计算关机期间长了多少
		if soil_state == SoilState.PLANTED or soil_state == SoilState.WATERED:
			var current_time = Time.get_unix_time_from_system()
			
			# 如果现在的时间已经超过了目标时间，说明离线期间长大了
			while target_timestamp > 0 and current_time >= target_timestamp:
				if soil_state == SoilState.READY:
					break 
				
				_grow_logic() # 只算数值
				# 离线模拟：算完这级，加上间隔，看下级是不是也过了
				target_timestamp += stage_duration 

	# 算完了一次性刷新画面
	_refresh_visuals()

# 按钮回调
func _on_sow_pressed():
	sow()
	_close_action_bar()

func _on_water_pressed():
	water()
	_close_action_bar()

func _close_action_bar():
	action_bar.visible = false
