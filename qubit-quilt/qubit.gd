class_name Qubit
extends Node3D

@onready var button_group: ButtonGroup = preload("res://control_buttons.tres")
@onready var macro_group: ButtonGroup = preload("res://macros.tres")

const DECAY_SPEED: float = 0.04
# no need to recalculate the angle every time
const angle_90 = deg_to_rad(90)

var sound: AudioStreamPlayer
var array_pos: int # what position this qubit has in the grid array
var rot: Basis # the "target" rotation
var is_rotating: bool

@onready var qb: StaticBody3D = get_node("QubitBody")
@onready var label: Label3D = get_node("QubitText")

func _ready():
	self.sound = get_node("/root/Scene/SoundSource")

	# connect to the qubit grid for applying the gates
	
	self.rot = qb.transform.basis
	self.is_rotating = false

func set_base(num: int) -> void:
	self.rot = bases[num]
	self.is_rotating = true
	self.label.text = labels[num]

func _process(delta: float) -> void:
	# don't do the calculations if the qubit is in a stationary state
	if not self.is_rotating:
		return
	# interpolate between the current and the target rotations and update the current rotation
	qb.transform.basis = qb.transform.basis.slerp(rot, 1 - DECAY_SPEED ** delta).orthonormalized()
	# if the target rotation is reached, stop updating the qubit
	if qb.transform.basis.is_equal_approx(rot):
		self.is_rotating = false

func _on_input_event(_cam: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# the user clicked on the qubitg
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# find the selected rotation direction from the buttongroup
		var pressed: Button = button_group.get_pressed_button()
		var macro: Button = macro_group.get_pressed_button()
		if pressed == null: # no pressed button, do nothing
			self.handle_macro(macro)
			return
		var grid = get_parent() as QubitGrid
		match pressed.name:
			"X":
				grid.rx(array_pos)
				grid.selected_qubit = -1
			"Y":
				grid.ry(array_pos)
				grid.selected_qubit = -1
			"Z":
				grid.rz(array_pos)
				grid.selected_qubit = -1
			"H":
				grid.rh(array_pos)
				grid.selected_qubit = -1
			"S":
				grid.rs(array_pos)
				grid.selected_qubit = -1
			"CX":
				if grid.selected_qubit == -1:
					grid.selected_qubit = array_pos
				else:
					grid.cx(grid.selected_qubit, array_pos)
					grid.selected_qubit = -1
			"CZ":
				if grid.selected_qubit == -1:
					grid.selected_qubit = array_pos
				else:
					grid.cz(grid.selected_qubit, array_pos)
					grid.selected_qubit = -1
			"REMOVE":
				grid.grid_qubits[array_pos] = null
				grid.append_or_update(QubitOperation.Operation.DELETE, array_pos, -1, grid.qec.get_vop(self.array_pos))
				self.queue_free()
			"MZ":
				grid.measure_z(array_pos)
				grid.selected_qubit = -1
			_:
				return
		sound.play()

func handle_macro(macro: Button):
	if macro == null:
		return
	print(macro.idx)
	var grid = get_parent() as QubitGrid
	grid.macros[macro.idx].execute(array_pos)

const labels: Dictionary[int, String] = {
	0: "+",
	1: "+",
	2: "-",
	3: "-",
	4: "+i",
	5: "+i",
	6: "-i",
	7: "-i",
	8: "1",
	9: "1",
	10: "0",
	11: "0",
	12: "-",
	13: "-",
	14: "+",
	15: "+",
	16: "-i",
	17: "-i",
	18: "+i",
	19: "+i",
	20: "0",
	21: "0",
	22: "1",
	23: "1"
}


const bases: Dictionary[int, Basis] = {
	0: Basis(Vector3(0,0,1),Vector3(0,-1,0), Vector3(1,0,0)),
	1: Basis(Vector3(0,0,1),Vector3(0,1,0),Vector3(-1,0,0)),
	2: Basis(Vector3(0,0,-1),Vector3(0,1,0),Vector3(1,0,0)),
	3: Basis(Vector3(0,0,-1),Vector3(0,-1,0), Vector3(-1,0,0)),
	4: Basis(Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1)),
	5: Basis(Vector3(-1,0,0),Vector3(0,-1,0), Vector3(0,0,1)),
	6: Basis(Vector3(1,0,0),Vector3(0,-1,0), Vector3(0,0,-1)),
	7: Basis(Vector3(-1,0,0),Vector3(0,1,0), Vector3(0,0,-1)),
	8: Basis(Vector3(0,1,0), Vector3(0,0,-1), Vector3(-1,0,0)),
	9: Basis(Vector3(0,-1,0), Vector3(0,0,-1), Vector3(1,0,0)),
	10: Basis(Vector3(0,-1,0), Vector3(0,0,1), Vector3(-1,0,0)),
	11: Basis(Vector3(0,1,0), Vector3(0,0,1), Vector3(1,0,0)),
	12: Basis(Vector3(0,0,-1), Vector3(1,0,0), Vector3(0,-1,0)),
	13: Basis(Vector3(0,0,-1), Vector3(-1,0,0), Vector3(0,1,0)),
	14: Basis(Vector3(0,0,1), Vector3(1,0,0), Vector3(0,1,0)),
	15: Basis(Vector3(0,0,1), Vector3(-1,0,0), Vector3(0,-1,0)),
	16: Basis(Vector3(0,-1,0), Vector3(-1,0,0), Vector3(0,0,-1)),
	17: Basis(Vector3(0,1,0), Vector3(1,0,0), Vector3(0,0,-1)),
	18: Basis(Vector3(0,1,0), Vector3(-1,0,0), Vector3(0,0,1)),
	19: Basis(Vector3(0,-1,0), Vector3(1,0,0), Vector3(0,0,1)),
	20: Basis(Vector3(-1,0,0), Vector3(0,0,1), Vector3(0,1,0)),
	21: Basis(Vector3(1,0,0), Vector3(0,0,1), Vector3(0,-1,0)),
	22: Basis(Vector3(-1,0,0),Vector3(0,0,-1), Vector3(0,-1,0)),
	23: Basis(Vector3(1,0,0),Vector3(0,0,-1), Vector3(0,1,0)),
}
