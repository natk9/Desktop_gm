extends Control

signal sow_pressed
signal water_pressed

@onready var sow_btn: Button = $SowButton
@onready var water_btn: Button = $WaterButton



func _ready():
	sow_btn.pressed.connect(_on_sow)
	water_btn.pressed.connect(_on_water)

func _on_sow():
	sow_pressed.emit()

func _on_water():
	water_pressed.emit()
