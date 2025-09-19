class_name SIZE
extends VBoxContainer

@onready var width_label = $width
@onready var width_input = $LineEdit
@onready var height_label = $height
@onready var height_input = $LineEdit2
@onready var create_button = $CREATE

func _ready():
	# Set the text color to black
	width_label.modulate = Color(0,0,0)
	height_label.modulate = Color(0,0,0)
	
