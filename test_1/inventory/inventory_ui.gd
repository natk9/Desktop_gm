extends Control
class_name InventoryUI

@onready var inventory_ui: InventoryUI = $"."

@onready var title_label: Label = $Panel/TitleBar/Title
@onready var grid: GridContainer = $Panel/MarginContainer/GridContainer
@export var slot_scene: PackedScene
# 由 root.gd 注入
var seed_item: ItemData
var crop_item: ItemData

#@onready var slots: Array[ItemSlot] = []
var slot_count := 9

var inventory: inventory   # ✅ 关键就在这一行
var slots: Array = []

func _ready():
	slots.clear()
	for child in grid.get_children():
		if child is ItemSlot:
			slots.append(child)



func refresh():
	#if not inventory:
		#return
#
	## 先清空
	#for slot in slots:
		#slot.clear()
#
	#var index := 0
#
	#for item_id in inventory.items:
		#var count: int = inventory.items[item_id]
		#if count <= 0:
			#continue
#
		#var item_data := _get_item_data(item_id)
		#if item_data == null:
			#push_warning("未知物品 ID: " + item_id)
			#continue
#
		#if index < slots.size():
			#slots[index].set_item(item_data, count)
			#index += 1
	if not inventory:
		return

	# 清空所有格子
	for slot in slots:
		slot.clear()

	var index := 0

	for item_id in inventory.get_item_ids():
		var count: int = inventory.get_count_by_id(item_id)
		if count <= 0:
			continue

		var item_data: ItemData = _get_item_data(item_id)
		if not item_data:
			continue

		if index < slots.size():
			slots[index].set_item(item_data, count)
			index += 1

func _get_item_data(item_id: String) -> ItemData:
	if seed_item and item_id == seed_item.id:
		return seed_item
	if crop_item and item_id == crop_item.id:
		return crop_item
	return null


func update_title():
	if not inventory:
		return

	var used := 0
	for item_id in inventory.items:
		if inventory.items[item_id] > 0:
			used += 1

	title_label.text = "背包 (%d/%d)" % [used, slot_count]


# 显示/隐藏背包
func toggle_visibility():
	visible = not visible
	if visible:
		refresh()


# 添加测试物品（调试用）
func _add_test_items():
	inventory.add_item(seed_item, 5)
	inventory.add_item(crop_item, 3)

func _on_inventory_changed(item_id: String, new_count: int, old_count: int):
	refresh()


# 清空背包（调试用）
func _clear_inventory():
	inventory.clear()
