extends Control

var dragging := false
var drag_offset := Vector2i.ZERO

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = DisplayServer.mouse_get_position() - DisplayServer.window_get_position()
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		var new_pos = DisplayServer.mouse_get_position() - drag_offset
		DisplayServer.window_set_position(new_pos)
