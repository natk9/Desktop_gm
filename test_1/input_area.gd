extends Control

@onready var highlight: Sprite2D = $"../Highlight"
@onready var action_bar: Control = $"../ActionBar"
@onready var close_timer: Timer = $Timer

var dragging := false
var drag_offset := Vector2i.ZERO
var hovering := false


func _ready():
	highlight.visible = false
	action_bar.visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	close_timer.timeout.connect(_on_close_timer_timeout)



func _gui_input(event):
	# ===== Hover 进入 =====
	if event is InputEventMouseMotion:
		if not hovering:
			hovering = true
			highlight.visible = true

		# 拖拽窗口
		if dragging:
			var new_pos = DisplayServer.mouse_get_position() - drag_offset
			DisplayServer.window_set_position(new_pos)
				# 鼠标回来了 → 不关功能栏
		if close_timer.is_stopped() == false:
			close_timer.stop()
		
		return

	# ===== 左键拖拽 =====
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
						# 如果功能栏开着 → 直接关闭
			if action_bar.visible:
				_close_action_bar()
				return
			dragging = true
			drag_offset = DisplayServer.mouse_get_position() - DisplayServer.window_get_position()

		else:
			dragging = false

	# ===== 右键功能栏 =====
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		action_bar.visible = !action_bar.visible
		highlight.visible = true
		close_timer.stop() # 防止旧的关闭计时


func _on_close_timer_timeout():
	_close_action_bar()

func _close_action_bar():
	action_bar.visible = false

	# 关闭后根据鼠标状态决定高亮
	if not hovering:
		highlight.visible = false

# 🔥 关键：鼠标真正离开 Control
func _notification(what):
	if what == NOTIFICATION_MOUSE_EXIT:
		hovering = false

		# 功能栏打开时 → 开始 2 秒倒计时
		if action_bar.visible:
			close_timer.start()
		else:
			highlight.visible = false
			
func _unhandled_input(event):
	if not action_bar.visible:
		return

	if event is InputEventMouseButton and event.pressed:
		_close_action_bar()
