#extends Node2D
#
#@onready var scene_root: Node = $SceneRoot
#@onready var map_panel: Control = $UI/MapPanel
#@onready var map_image: TextureRect = $UI/MapPanel/MapImage
#
#var current_scene_id: SceneID = SceneID.SCENE_B
#var current_scene_node: Node = null
#
#
#enum SceneID {
	#SCENE_A,
	#SCENE_B
#}
#
#const SCENE_DATA := {
	#SceneID.SCENE_A: {
		#"scene": preload("res://scenes/Root.tscn"),
		#"map_texture": preload("res://png/map2.png"),
	#},
	#SceneID.SCENE_B: {
		#"scene": preload("res://scenes/fishing_desktop.tscn"),
		#"map_texture": preload("res://png/map1.png"),
	#},
#}
#
#func _ready():
	#map_panel.visible = false
	#_load_scene(current_scene_id)
#
#func _load_scene(scene_id: SceneID):
	#if current_scene_node:
		#current_scene_node.queue_free()
#
	#var data = SCENE_DATA[scene_id]
	#current_scene_node = data.scene.instantiate()
	#scene_root.add_child(current_scene_node)
#
	#current_scene_id = scene_id
	#_update_map_highlight()
#
#func toggle_map():
	#map_panel.visible = !map_panel.visible
	#if map_panel.visible:
		#_update_map_highlight()
		#
#func _update_map_highlight():
	#var data = SCENE_DATA[current_scene_id]
	#map_image.texture = data.map_texture
#
#
#func _on_point_a_pressed() -> void:
	#if current_scene_id != SceneID.SCENE_A:
		#_load_scene(SceneID.SCENE_A)
	#map_panel.visible = false
#
#
#func _on_point_b_pressed() -> void:
	#if current_scene_id != SceneID.SCENE_B:
		#_load_scene(SceneID.SCENE_B)
	#map_panel.visible = false
#
#func _on_close_button_pressed() -> void:
	#map_panel.visible = false


extends Node2D

@onready var scene_root: Node = $SceneRoot
@onready var map_panel: Control = $UI/MapPanel
@onready var map_image: TextureRect = $UI/MapPanel/MapImage
@onready var alchemy_window: Control = $UI/AlchemyWindow


var window_initialized := false

enum SceneID {
	SCENE_A,
	SCENE_B,
	SCENE_C
}

const SCENE_DATA := {
	SceneID.SCENE_A: {
		"scene": preload("res://scenes/Root.tscn"),
		"map_texture": preload("res://png/map2.png"),
	},
	SceneID.SCENE_B: {
		"scene": preload("res://scenes/fishing_desktop.tscn"),
		"map_texture": preload("res://png/map1.png"),
	},
	SceneID.SCENE_C: {
		"scene": preload("res://alchemy.tscn"),
		"map_texture": preload("res://png/map3.png"),
	},
}

var current_scene_id: SceneID = SceneID.SCENE_B
var current_scene_node: Node = null

func _ready():
	alchemy_window.request_close.connect(_on_alchemy_window_closed)
	if window_initialized:
		return

	window_initialized = true
	_init_window()
	
	map_panel.visible = false
	alchemy_window.visible = false

	_load_scene(current_scene_id)



func _init_window():
	var win := get_window()
	win.content_scale_factor = 1.0

	DisplayServer.window_set_flag(
		DisplayServer.WINDOW_FLAG_BORDERLESS,
		true
	)

	DisplayServer.window_set_min_size(Vector2i(300, 300))
	DisplayServer.window_set_max_size(Vector2i(300, 300))

	var screen_size := DisplayServer.screen_get_size()
	DisplayServer.window_set_position(
		screen_size - Vector2i(320, 360)
	)

	get_viewport().transparent_bg = true

# ==============================
# 场景加载（核心）
# ==============================
func _load_scene(scene_id: SceneID) -> void:
	if current_scene_id == scene_id and current_scene_node:
		return

	# 1️⃣ 立刻清空 SceneRoot（最稳）
	for child in scene_root.get_children():
		child.queue_free()

	# 2️⃣ 更新状态
	current_scene_id = scene_id

	# 3️⃣ 实例化新场景
	var data = SCENE_DATA[scene_id]
	current_scene_node = data.scene.instantiate()
	scene_root.add_child(current_scene_node)

	_update_map_highlight()

# ==============================
# 地图 UI
# ==============================
func toggle_map() -> void:
	if alchemy_window.visible:
		alchemy_window.visible = false

	map_panel.visible = !map_panel.visible
	if map_panel.visible:
		_update_map_highlight()

func toggle_alchemy() -> void:
	if alchemy_window.visible:
		alchemy_window.visible = false
	else:
		map_panel.visible = false
		alchemy_window.visible = true


func _update_map_highlight() -> void:
	var data = SCENE_DATA[current_scene_id]
	map_image.texture = data.map_texture

# ==============================
# 地图传送点
# ==============================
func _on_point_a_pressed() -> void:
	_load_scene(SceneID.SCENE_A)
	map_panel.visible = false

func _on_point_b_pressed() -> void:
	_load_scene(SceneID.SCENE_B)
	map_panel.visible = false

func _on_point_c_pressed() -> void:
	_load_scene(SceneID.SCENE_C)
	map_panel.visible = false

func _on_close_button_pressed() -> void:
	map_panel.visible = false

func _on_alchemy_window_closed():
	alchemy_window.visible = false
