extends Control

signal sow_pressed
signal water_pressed
signal harvest_pressed

@onready var sow_btn: Button = $SowButton
@onready var water_btn: Button = $WaterButton

@onready var harvest_btn: Button = $HarvestButton


func _on_harvest():
	harvest_pressed.emit()

func _ready():
	sow_btn.pressed.connect(_on_sow)
	water_btn.pressed.connect(_on_water)
	harvest_btn.pressed.connect(_on_harvest)

func _on_sow():
	sow_pressed.emit()

func _on_water():
	water_pressed.emit()
