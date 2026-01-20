# slot.gd
extends Control

class_name InventorySlot

@onready var icon: TextureRect = $MarginContainer/Icon
@onready var count_label: Label = $CountLabel
@onready var highlight: Panel = $Highlight

var item_data: ItemData = null
var item_count: int = 0


# 设置格子显示
func set_item(data: ItemData, count: int):
	item_data = data
	item_count = count
	
	if data and data.icon:
		icon.texture = data.icon
		icon.visible = true
	else:
		icon.texture = null
		icon.visible = false
	
	# 显示数量（大于0时显示）
	if count > 0:
		count_label.text = str(count)
		count_label.visible = true
	else:
		count_label.text = ""
		count_label.visible = false
	
	# 设置提示文本
	if data:
		tooltip_text = "%s\n数量：%d" % [data.name, count]
	else:
		tooltip_text = "空"

# 清空格子
func clear():
	item_data = null
	item_count = 0
	icon.texture = null
	icon.visible = false
	count_label.text = ""
	count_label.visible = false
	highlight.visible = false
	tooltip_text = "空"

# 获取物品ID
func get_item_id() -> String:
	if item_data:
		return item_data.id
	return ""

# 更新数量
func update_count(new_count: int):
	item_count = new_count
	if new_count > 0:
		count_label.text = str(new_count)
		count_label.visible = true
		
		if item_data:
			tooltip_text = "%s\n数量: %d" % [item_data.name, new_count]
	else:
		clear()

# 高亮显示
func set_highlight(enable: bool):
	highlight.visible = enable
