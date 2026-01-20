# inventory_ui_simple.gd
extends Control
class_name InventoryUI1

@onready var title_label: Label = $Panel/TitleBar/Title
@onready var grid: GridContainer = $Panel/MarginContainer/GridContainer

@export var seed_item: ItemData
@export var crop_item: ItemData

var slots: Array = []
var slot_count: int = 9
var columns: int = 3

func _ready():
	print("=== 🎒 超简单背包UI启动 ===")
	
	# 确保 grid 存在
	if not grid:
		print("❌ grid 不存在！检查节点路径")
		return
	
	print("1. grid 找到: ", grid.name)
	print("2. 创建 %d 个格子" % slot_count)
	
	# 创建格子
	_create_simple_slots()
	
	# 连接信号
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		print("3. 连接 inventory 信号")
	
	# 初始隐藏
	visible = false
	print("✅ 初始化完成")

func _create_simple_slots():
	# 清空现有
	for child in grid.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	slots.clear()
	grid.columns = columns
	
	# 创建9个简单格子
	for i in range(slot_count):
		# 创建格子容器
		var slot = Control.new()
		slot.name = "Slot_%d" % (i + 1)
		slot.custom_minimum_size = Vector2(80, 80)
		
		# 背景（明显颜色）
		var bg = ColorRect.new()
		bg.color = Color(0.3, 0.3, 0.3, 0.9)
		bg.size = Vector2(80, 80)
		slot.add_child(bg)
		
		# 物品名称标签
		var name_label = Label.new()
		name_label.name = "ItemName"
		name_label.text = "空"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.size = Vector2(80, 50)
		name_label.position = Vector2(0, 10)
		slot.add_child(name_label)
		
		# 数量标签
		var count_label = Label.new()
		count_label.name = "ItemCount"
		count_label.text = ""
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count_label.size = Vector2(80, 20)
		count_label.position = Vector2(0, 55)
		slot.add_child(count_label)
		
		# 格子编号（调试用）
		var index_label = Label.new()
		index_label.text = str(i + 1)
		index_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		index_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		index_label.size = Vector2(20, 20)
		index_label.add_theme_color_override("font_color", Color.YELLOW)
		slot.add_child(index_label)
		
		# 存储引用
		slot.name_label = name_label
		slot.count_label = count_label
		
		# 添加方法
		slot.set_item = func(data: ItemData, count: int):
			if data:
				name_label.text = data.name
				count_label.text = "x" + str(count) if count > 1 else ""
			else:
				name_label.text = "空"
				count_label.text = ""
			print("格子 %d: %s x%d" % [i + 1, data.name if data else "空", count])
		
		slot.clear = func():
			name_label.text = "空"
			count_label.text = ""
		
		slot.has_method = func(method_name: String) -> bool:
			return method_name in ["set_item", "clear"]
		
		# 添加到网格
		grid.add_child(slot)
		slots.append(slot)
	
	print("✅ 创建 %d 个简单格子" % slots.size())

func refresh():
	print("=== 刷新背包 ===")
	print("背包数据: ", inventory.items if inventory else "null")
	
	if not inventory or slots.is_empty():
		print("无法刷新")
		return
	
	# 清空所有格子
	for slot in slots:
		if slot.has_method("clear"):
			slot.clear()
	
	# 显示物品
	var slot_index = 0
	
	for item_id in inventory.items:
		var count = inventory.items[item_id]
		
		if count <= 0:
			continue
		
		# 获取物品
		var item_data = null
		if item_id == "seed_mystery":
			item_data = seed_item
		elif item_id == "crop_mystery":
			item_data = crop_item
		
		if not item_data:
			print("未找到物品: ", item_id)
			continue
		
		# 显示到格子
		if slot_index < slots.size():
			slots[slot_index].set_item(item_data, count)
			slot_index += 1
		else:
			print("背包已满")
			break
	
	print("显示 %d 种物品" % slot_index)
	
	# 更新标题
	if inventory:
		var used = 0
		for count in inventory.items.values():
			if count > 0:
				used += 1
		title_label.text = "背包 (%d/%d)" % [used, slot_count]

func _on_inventory_changed(item_id: String, new_count: int, old_count: int):
	print("背包变化: %s %d->%d" % [item_id, old_count, new_count])
	refresh()
