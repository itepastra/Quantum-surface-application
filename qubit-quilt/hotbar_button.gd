extends Button

@onready var macros: ButtonGroup = preload("res://macros.tres")

func _pressed() -> void:
	if macros.get_pressed_button():
		macros.get_pressed_button().button_pressed = false
	
	var qg = get_node("/root/Scene/QubitGrid") as QubitGrid
	if self.name not in ["CX", "CZ"] and qg.selected_qubit != -1:
		qg.selected_qubit = -1
		qg.drag_gate.queue_free()
