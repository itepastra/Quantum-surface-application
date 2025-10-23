class_name ErrorSlider
extends HBoxContainer

@onready var text: Label = get_node("Label") as Label

@export var STATIC: String

signal error_changed(value: float)

func _ready() -> void:
	var slider: HSlider = get_node("HSlider") as HSlider
	slider.min_value = 1e-6
	slider.step = 1e-6
	slider.max_value = 1.0
	slider.tick_count = 7
	slider.value = 0.001

	text.text = STATIC % slider.value
	emit_signal("error_changed", slider.value)


func _on_h_slider_value_changed(value: float) -> void:
	text.text = STATIC % value
	emit_signal("error_changed", value)
