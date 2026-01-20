# ItemData.gd
extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export var icon: Texture2D
@export var stack_limit: int = 99
@export var item_type: ItemType

enum ItemType {
	SEED,
	CROP,
	CONSUMABLE,
	MATERIAL
}
