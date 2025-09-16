class_name Qubit
extends StaticBody3D

var button_group: ButtonGroup

const DECAY_SPEED: float = 0.04
# no need to recalculate the angle every time
const angle_90 = deg_to_rad(90)

var rot: Basis # the current "target" rotation
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
	if not self.is_rotating:
		return
	self.transform.basis = self.transform.basis.slerp(rot, 1 - DECAY_SPEED ** delta).orthonormalized()
	if self.transform.basis.is_equal_approx(rot):
		self.is_rotating = false

func _on_input_event(_cam: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# the user clicked on the qubit
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
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
		#actually rotate the qubit
		self.rot = self.rot.rotated(rotation_axis, angle_90)
		self.is_rotating = true
