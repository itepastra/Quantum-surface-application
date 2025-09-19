class_name Qubit
extends StaticBody3D

var button_group: ButtonGroup

const DECAY_SPEED: float = 0.04
# no need to recalculate the angle every time
const angle_90 = deg_to_rad(90)

var rot: Basis # the "target" rotation
var is_rotating: bool

func _ready():
	# this should be any of the buttons in the Hotbar, 
	# they're all linked into a single button_group which gives an easy "select 1" option
	var button = get_node("/root/Scene/HUD/Hotbar/X-90")
	button_group = button.button_group
	# start by rotating the qubit so blue (|0>) is towards the camera and |+> is on the underside
	self.rotate_object_local(Vector3.RIGHT, angle_90)
	self.rotate_object_local(Vector3.UP, -angle_90)
	self.rot = self.transform.basis

func _process(delta: float) -> void:
	# don't do the calculations if the qubit is in a stationary state
	if not self.is_rotating:
		return
	# interpolate between the current and the target rotations and update the current rotation
	self.transform.basis = self.transform.basis.slerp(rot, 1 - DECAY_SPEED ** delta).orthonormalized()
	# if the target rotation is reached, stop updating the qubit
	if self.transform.basis.is_equal_approx(rot):
		self.is_rotating = false

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
			rotation_axis = self.rot.x
		elif pressed.name == "Y-90":
			rotation_axis = -self.rot.z
		elif pressed.name == "Z-90":
			rotation_axis = self.rot.y
		else:
			return  # Unknown button

		# calculate the new target rotation for the qubit and set it to be rotating
		self.rot = self.rot.rotated(rotation_axis, angle_90)
		self.is_rotating = true
