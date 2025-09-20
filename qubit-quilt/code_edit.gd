extends CodeEdit



func _on_code_editor_toggled(toggled_on: bool) -> void:
	self.visible = toggled_on


func _on_ready() -> void:
	self.visible = false
