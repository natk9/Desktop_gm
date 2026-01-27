extends Control


signal request_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_close_button_2_pressed() -> void:
	emit_signal("request_close")
