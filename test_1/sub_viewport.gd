extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# 设置与游戏窗口相同的大小
	size = get_viewport().size
	render_target_update_mode = SubViewport.UPDATE_ALWAYS  # 持续更新
	transparent_bg = true  # 如果需要透明背景
