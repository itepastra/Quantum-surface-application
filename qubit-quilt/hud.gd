class_name HUD
extends CanvasLayer

@onready var vport: Viewport = get_viewport()
var codeEditor: CodeEdit
var codeToggle: Button

func _ready() -> void:
	print_debug(vport)
	vport.size_changed.connect(_on_size_changed)
	
	codeEditor = get_node("./CodeEdit")
	codeToggle = get_node("./CodeEditor")

func _on_size_changed():
	var rect = vport.get_visible_rect()
	print_debug("size changed to", rect)
	codeEditor.size = rect.size * Vector2(0.4, 0.8) - Vector2(8, 8)
	codeEditor.position = rect.position + rect.size * Vector2(0.6, 0.0) + Vector2(0, 48)
	codeToggle.position = rect.position + rect.size * Vector2(1,0) + Vector2(-codeToggle.size.x - 8, 8)
