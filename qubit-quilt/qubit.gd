class_name Qubit
extends StaticBody3D

var button_group: ButtonGroup

const DECAY_SPEED: float = 0.04
# no need to recalculate the angle every time
const angle_90 = deg_to_rad(90)

var array_pos: int # what position this qubit has in the grid array
var rot: Basis # the "target" rotation
var is_rotating: bool

func _ready():
	# this should be any of the buttons in the Hotbar, 
	# they're all linked into a single button_group which gives an easy "select 1" option
	var button = get_node("/root/Scene/HUD/Hotbar/X-90")
	button_group = button.button_group
	
	# connect to the qubit grid for applying the gates
	
	self.rot = self.transform.basis
	self.is_rotating = false

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
		# find the selected rotation direction from the buttongroup
		var pressed: Button = button_group.get_pressed_button()
		if pressed == null: # no pressed button, do nothing
			return
		var grid = get_parent() as QubitGrid
		if pressed.name == "X-90":
			grid.rx(array_pos)
			grid.selected_qubit = -1
		elif pressed.name == "Y-90":
			grid.ry(array_pos)
			grid.selected_qubit = -1
		elif pressed.name == "Z-90":
			grid.rz(array_pos)
			grid.selected_qubit = -1
		elif pressed.name == "CX":
			if grid.selected_qubit == -1:
				grid.selected_qubit = array_pos
			else:
				grid.cx(grid.selected_qubit, array_pos)
				grid.selected_qubit = -1
		elif pressed.name == "CZ":
			if grid.selected_qubit == -1:
				grid.selected_qubit = array_pos
			else:
				grid.cz(grid.selected_qubit, array_pos)
				grid.selected_qubit = -1
		elif pressed.name == "REMOVE":
			grid.grid_qubits[array_pos] = null
			grid.append_or_update(QubitOperation.Operation.DELETE, array_pos, -1, self.rot)
			self.queue_free()
		else:
			return  # Unknown button
