class_name HUD
extends CanvasLayer

@onready var vport: Viewport = get_viewport()
var tabs: TabContainer
var codeToggle: Button
var whole: Control

func _ready() -> void:
	# when the viewport changes size we need to move the editor around
	vport.size_changed.connect(_on_size_changed)
	
	tabs = get_node("./Tabs") as TabContainer
	whole = get_node("Spacer")
	
	# place the button and editor in the correct spot at initialisation
	_on_size_changed()

func _on_size_changed():
	var rect = vport.get_visible_rect()
	tabs.size = rect.size * Vector2(0.4, 0.8)
	tabs.position = rect.position + rect.size * Vector2(0.6, 0.0) + Vector2(0, 12)
	whole.size = rect.size
	whole.position = rect.position
