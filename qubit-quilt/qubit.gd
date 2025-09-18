class_name Qubit
extends StaticBody3D

var button_group: ButtonGroup

# no need to recalculate the angle every time
const angle_radians = deg_to_rad(90)


func _ready():
	# this should be any of the buttons in the Hotbar, 
	# they're all linked into a single button_group which gives an easy "select 1" option
	var button = get_node("/root/Scene/HUD/Hotbar/X-90")
	button_group = button.button_group
	# start by rotating the qubit so blue (|0>) is towards the camera and |+> is on the underside
	self.rotate_object_local(Vector3.RIGHT, angle_radians)
	self.rotate_object_local(Vector3.UP, -angle_radians)
	


func _on_input_event(_cam: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# the user clicked on the qubit
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var grid = get_parent() as QubitGrid
		
		# Check if we're in two-qubit gate mode
		if grid.two_qubit_gate_type != "":
			grid._on_qubit_selected(self)
			return
		
		# find the selected rotation direction from the buttongroup
		var pressed: Button = button_group.get_pressed_button()
		var rotation_axis: Vector3
		if pressed == null: # no pressed button, do nothing (future panning around)
			return
		elif pressed.name == "X-90":
			rotation_axis = Vector3.RIGHT
		elif pressed.name == "Y-90":
			rotation_axis = Vector3.FORWARD
		elif pressed.name == "Z-90":
			rotation_axis = Vector3.UP
		else:
			return  # Unknown button
		
		#actually rotate the qubit
		self.rotate_object_local(rotation_axis, angle_radians)
