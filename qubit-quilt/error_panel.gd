class_name ErrorPanel
extends PanelContainer

@onready var grid = get_node("/root/Scene/QubitGrid")

var errors: Vector3
var enabled: bool = false

signal errors_changed(Vector3)

func _on_bit_flip_odds_error_changed(value: float) -> void:
	self.errors.x = value
	if self.enabled:
		emit_signal("errors_changed", self.errors)

func _on_phase_flip_odds_error_changed(value: float) -> void:
	self.errors.y = value
	if self.enabled:
		emit_signal("errors_changed", self.errors)

func _on_relax_odds_error_changed(value: float) -> void:
	self.errors.z = value
	if self.enabled:
		emit_signal("errors_changed", self.errors)

func _on_enable_errors_toggled(toggled_on: bool) -> void:
	self.enabled = toggled_on
	if self.enabled:
		emit_signal("errors_changed", self.errors)
	else:
		emit_signal("errors_changed", Vector3.ZERO)
