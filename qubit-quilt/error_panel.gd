class_name ErrorPanel
extends PanelContainer

@onready var grid = get_node("/root/Scene/QubitGrid")

func _ready() -> void:
	var list = get_node("VBox")
	for child in list.get_children():
		if child is ErrorControl:
			child.error_changed.connect(grid.handle_error_changed)
