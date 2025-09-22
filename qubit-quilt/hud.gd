class_name HUD
extends CanvasLayer

@onready var vport: Viewport = get_viewport()
var codeEditor: CodeEdit
var codeToggle: Button

func _ready() -> void:
	# when the viewport changes size we need to move the editor around
	vport.size_changed.connect(_on_size_changed)
	
	codeEditor = get_node("./CodeEdit")
	codeToggle = get_node("./CodeEditor")
	
	# place the button and editor in the correct spot at initialisation
	_on_size_changed()

func _on_size_changed():
	var rect = vport.get_visible_rect()
	codeEditor.size = rect.size * Vector2(0.4, 0.8) - Vector2(8, 8)
	codeEditor.position = rect.position + rect.size * Vector2(0.6, 0.0) + Vector2(0, 48)
	codeToggle.position = rect.position + rect.size * Vector2(1,0) + Vector2(-codeToggle.size.x - 8, 8)
