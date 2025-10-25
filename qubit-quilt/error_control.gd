class_name ErrorControl
extends GridContainer

enum ErrType {
	# These apply to (one of) the qubit(s) the gate is applied on
	BITFLIP_GATE,
	PHASEFLIP_GATE,
	RELAXATION_GATE,
	# These apply to a random qubit in the grid, not just the selected one
	BITFLIP_ANY,
	PHASEFLIP_ANY,
	RELAXATION_ANY,
	# These apply to a whole region *NOT YET IMPLEMENTED*
	COHERENT_SPACE,
}

@onready var text: Label = get_node("Prob") as Label

@export var error_type: ErrType
var enabled: bool

signal error_changed(value: float, type: ErrType)

func _ready() -> void:
	var slider: HSlider = get_node("ProbSlider") as HSlider
	slider.min_value = 1e-6
	slider.step = 1e-6
	slider.max_value = 1.0
	slider.tick_count = 7
	slider.value = 0.001
	slider.value_changed.connect(slider_val_changed)

	var enable: CheckButton = get_node("Enable") as CheckButton
	enable.toggled.connect(enable_toggled)
	self.enabled = enable.button_pressed
	
	slider_val_changed(slider.value)


func slider_val_changed(value: float) -> void:
	text.text = "Probability: %0.7f" % value
	if self.enabled:
		emit_signal("error_changed", value, self.error_type)

func enable_toggled(pressed: bool) -> void:
	self.enabled = pressed
	if self.enabled:
		var slider: HSlider = get_node("ProbSlider") as HSlider
		emit_signal("error_changed", slider.value, self.error_type)
	else:
		emit_signal("error_changed", 0, self.error_type)
