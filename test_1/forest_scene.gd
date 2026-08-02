extends Node2D
@onready var tile_map_ground: TileMapLayer = $TileMap_Ground
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


var is_dragging := false
var drag_start_mouse_pos := Vector2i.ZERO
var drag_start_window_pos := Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_start_window_drag()
			else:
				is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		_update_window_drag()

func _start_window_drag():
	is_dragging = true
	drag_start_mouse_pos = DisplayServer.mouse_get_position()
	drag_start_window_pos = DisplayServer.window_get_position()

func _update_window_drag():
	var current_mouse_pos = DisplayServer.mouse_get_position()
	var delta: Vector2i = current_mouse_pos - drag_start_mouse_pos
	DisplayServer.window_set_position(drag_start_window_pos + delta)
