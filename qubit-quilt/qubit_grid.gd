class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 1.5

@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

const qubit_size = 1
const angle_90 = deg_to_rad(90)

var button_group: ButtonGroup
var two_qubit_mode: bool = false
var selected_qubit: int = -1
var two_qubit_gate_type: String = ""
var grid_qubits: Array[Qubit] = []

var qec = Qec.new()

func _on_ready() -> void:
	# Resize the camera to fit with the grid
	var full_grid_size = Vector2(x_qubits * cell_size, y_qubits*cell_size)
	var camera: Camera3D = %Camera
	camera.size = max(full_grid_size.x, full_grid_size.y)*1.05
	# Dynamically change the keep_aspect of the camera to always fit the whole grid
	camera.keep_aspect = camera.KEEP_WIDTH if full_grid_size.x > full_grid_size.y else camera.KEEP_HEIGHT
	
	# initialize the qubits themselves
	for y in y_qubits:
		for x in x_qubits:
			var nextQubit: Qubit = qubit_scene.instantiate()
			nextQubit.name = "Qubit (%d, %d)" % [x,y]
			nextQubit.position.x = x - (x_qubits-1)/2.0
			nextQubit.position.y = y - (y_qubits-1)/2.0
			nextQubit.position *= cell_size
			nextQubit.array_pos = y * x_qubits+x
			grid_qubits.append(nextQubit)
			self.add_child(nextQubit)


func _ready():
	# Connect to the CX button
	var cx_button = get_node("/root/Scene/HUD/Hotbar/CX")
	cx_button.connect("pressed", Callable(self, "_on_cx_button_pressed"))
	
	var cz_button = get_node("/root/Scene/HUD/Hotbar/CZ")
	cz_button.connect("pressed", Callable(self, "_on_cz_button_pressed"))

func rx(qubit: int):
	var q = grid_qubits[qubit]
	rq(q, q.rot.x)

func ry(qubit: int):
	var q = grid_qubits[qubit]
	# the qubit's y-axis is the -z axis in godot
	rq(q, -q.rot.z)

func rz(qubit: int):
	var q = grid_qubits[qubit]
	# the qubit's z-axis is the y axis in godot
	rq(q, q.rot.y)

func rq(qubit: Qubit, axis: Vector3):
	qubit.rot = qubit.rot.rotated(axis, angle_90).orthonormalized()
	qubit.is_rotating = true

func cx(control: int, target: int):
	if not check_orthogonal_neighbors(control, target, x_qubits):
		print_debug("Not nearest neighbors in this grid configuration")
		return
		
	# apply cx between control and target
	var qc = grid_qubits[control]
	var qt = grid_qubits[target]
	# TODO DO STIM STUFF HERE
	
	print_debug("control basis", qc.basis)
	print_debug("target basis", qt.basis)

func cz(control: int, target: int):
	if not check_orthogonal_neighbors(control, target, x_qubits):
		print_debug("Not nearest neighbors in this grid configuration")
		return
		
	# apply cz between control and target
	var qc = grid_qubits[control]
	var qt = grid_qubits[target]
	# TODO DO STIM STUFF HERE
	
	print_debug("control basis", qc.basis)
	print_debug("target basis", qt.basis)

func check_orthogonal_neighbors(qubit1_pos: int, qubit2_pos: int, width: int) -> bool:
	# Calculate row and column positions
	var row1 = qubit1_pos / width
	var col1 = qubit1_pos % width
	var row2 = qubit2_pos / width
	var col2 = qubit2_pos % width
	
	# Check if they are adjacent, includes diagonally
	var row_diff = abs(row1 - row2)
	var col_diff = abs(col1 - col2)
	
	# check Manhattan distance of 1 (orthogonal) or sqrt(2) (diagonal)
	# but for nearest neighbor in grid orthogonal neighbors
	return (row_diff == 0 and col_diff == 1) or (row_diff == 1 and col_diff == 0)
