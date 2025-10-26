class_name ErrorPanel
extends PanelContainer

@onready var grid = get_node("/root/Scene/QubitGrid")

func _ready() -> void:
	var disable_all = get_node("VBox/DisableAll") as CheckButton
	var list = get_node("VBox")
	for child in list.get_children():
		if child is ErrorControl:
			disable_all.toggled.connect(child.disable_toggle)
			child.error_changed.connect(grid.handle_error_changed)
