extends MarginContainer


@onready var label: Label = $CountLabel

@onready var texture_rect: TextureRect = $TextureRect


func update_display(item: ItemData, count: int) -> void:
	texture_rect.texture = item.icon

	if item.max_stack <= 1:
		label.hide()
	else:
		label.show()
		label.text = str(count)
