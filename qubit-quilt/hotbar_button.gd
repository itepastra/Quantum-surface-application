extends Button

@onready var macros: ButtonGroup = preload("res://macros.tres")

func _pressed() -> void:
	if macros.get_pressed_button():
		macros.get_pressed_button().button_pressed = false
