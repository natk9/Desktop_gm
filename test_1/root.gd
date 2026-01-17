extends Node2D



	
func _ready():

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
