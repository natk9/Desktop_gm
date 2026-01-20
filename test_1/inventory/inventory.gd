# inventory.gd
extends Node
class_name Inventory

# 信号：背包内容变化时发出
signal inventory_changed(item_id: String, new_count: int, old_count: int)
signal item_added(item_id: String, count: int)
signal item_removed(item_id: String, count: int)

# 物品数据：{item_id: count}
var items: Dictionary = {}
var save_path: String = "user://inventory.save"

func _ready():
	load_inventory()

# 添加物品
func add_item(item_data: ItemData, amount: int = 1) -> void:
	if not item_data:
		print("错误：尝试添加空物品")
		return
	
	var item_id = item_data.id
	var old_count = items.get(item_id, 0)
	var new_count = old_count + amount
	
	# 应用堆叠限制
	var stack_limit = item_data.stack_limit
	if stack_limit > 0 and new_count > stack_limit:
		print("超出堆叠限制：", item_data.name, " 最多 ", stack_limit, " 个")
		new_count = stack_limit
		amount = stack_limit - old_count
	
	if amount <= 0:
		return
	items[item_id] = new_count
	print("添加物品：%s x%d (总计：%d)" % [item_data.name, amount, new_count])
	print("添加物品：", item_data.name, " x", amount, " (总计：", new_count, ")")
	
	inventory_changed.emit(item_id, new_count, old_count)
	item_added.emit(item_id, amount)
	save_inventory()


func get_item_ids() -> Array[String]:
	var result: Array[String] = []
	for key in items.keys():
		result.append(String(key))
	return result

func get_count_by_id(item_id: String) -> int:
	return items.get(item_id, 0)

# 移除物品
func remove_item(item_data: ItemData, amount: int = 1) -> bool:
	if not item_data:
		return false
	
	var item_id = item_data.id
	if not items.has(item_id):
		return false
	
	var old_count = items[item_id]
	var new_count = max(0, old_count - amount)
	
	if new_count <= 0:
		items.erase(item_id)
	else:
		items[item_id] = new_count
	
	var actual_removed = old_count - new_count
	
	print("移除物品：%s x%d" % [item_data.name, actual_removed])
	print("移除物品：", item_data.name, " x", amount)
	
	inventory_changed.emit(item_id, new_count, old_count)
	item_removed.emit(item_id, actual_removed)
	
	save_inventory()
	return actual_removed > 0
	#return true

# 检查是否有足够物品
func has_item(item_data: ItemData, amount: int = 1) -> bool:
	if not item_data:
		return false
	return items.get(item_data.id, 0) >= amount

# 获取物品数量
func get_item_count(item_data: ItemData) -> int:
	if not item_data:
		return 0
	return items.get(item_data.id, 0)

# 获取所有物品信息
func get_all_items() -> Array:
	var result = []
	for item_id in items:
		result.append({
			"id": item_id,
			"count": items[item_id]
		})
	return result



# 保存背包数据
func save_inventory():
	var save_data = {
		"version": 1,
		"items": items,
		"save_time": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("背包数据已保存")
	else:
		print("错误：无法保存背包数据")

# 加载背包数据
func load_inventory():
	if not FileAccess.file_exists(save_path):
		print("无背包存档，使用新背包")
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		
		if data and data.has("items"):
			items = data["items"]
			print("背包数据已加载：", items)
	else:
		print("错误：无法加载背包数据")

# 清空背包（调试用）
#func clear():
	#items.clear()
	#inventory_changed.emit("", 0, 0)
	#save_inventory()
	#print("背包已清空")

# 清空背包
func clear() -> void:
	print("🗑️ 清空背包")
	var old_items = items.duplicate()
	items.clear()
	
	# 通知所有物品被移除
	for item_id in old_items:
		inventory_changed.emit(item_id, 0, old_items[item_id])
	
	save_inventory()
