extends Control
class_name ItemSlot

@onready var icon: TextureRect = $Icon
@onready var count_label: Label = $CountLabel

var item_data: ItemData = null
var count: int = 0

func set_item(data: ItemData, amount: int) -> void:
	item_data = data
	count = amount

	if item_data and item_data.icon:
		icon.texture = item_data.icon
		icon.visible = true
	else:
		icon.visible = false

	if count > 1:
		count_label.text = str(count)
		count_label.visible = true
	else:
		count_label.visible = false

func clear() -> void:
	item_data = null
	count = 0
	icon.visible = false
	count_label.visible = false
