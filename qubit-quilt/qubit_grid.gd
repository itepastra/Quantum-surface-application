class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 1.5

@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

class EGroup:
	extends Node
	var qubits: Array[Qubit] = []
	var eff: Basis
	var timer: Timer
	
	func _init(qubits: Array[Qubit], grid: QubitGrid, period: float = 1) -> void:
		self.qubits = qubits
		grid.add_child(self)
		timer = Timer.new()
		timer.autostart = true
		timer.wait_time = period
		timer.timeout.connect(_on_timer_timeout)
		self.add_child(timer)
	
	func _on_timer_timeout():
		random_rotate()
	
	func random_rotate():
		#if len(qubits) <= 1:
			#qubits.map(func (qubit): qubit.eff_rot = Basis.IDENTITY)
			#return
		var rand = RandomNumberGenerator.new()
		var theta = rand.randf_range(0, PI*2)
		var phi = rand.randf_range(0, PI*2)
		var psi = rand.randf_range(0, PI*2)
		eff = Basis.from_euler(Vector3(theta, phi, psi))
		qubits.map(func (qubit): qubit.eff_rot = eff)
		qubits.map(func (qubit): qubit.is_rotating = true)

const qubit_size = 1
const angle_90 = deg_to_rad(90)

var button_group: ButtonGroup
var two_qubit_mode: bool = false
var selected_qubit: int = -1
var two_qubit_gate_type: String = ""
var grid_qubits: Array[Qubit] = []
var entanglement_groups: Array[EGroup] = []

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
	
	# add qubits to EGroups
	var group: int = 1
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("QubitQuilt")
	var row: Array[Qubit] = []
	for qubit in grid_qubits:
		row.append(qubit)
		if len(row) == 4:
			entanglement_groups.append(EGroup.new(row, self, randf_range(0.5,3.0)))
			group += 1
			row = []
	entanglement_groups.append(EGroup.new(row, self))


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
		
	add_cx_cz_visuals(control, target, false)
	
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
		
	add_cx_cz_visuals(control, target, true)
	
	# apply cz between control and target
	var qc = grid_qubits[control]
	var qt = grid_qubits[target]
	# TODO DO STIM STUFF HERE
	
	print_debug("control basis", qc.basis)
	print_debug("target basis", qt.basis)

func check_orthogonal_neighbors(qubit1_pos: int, qubit2_pos: int, width: int) -> bool:
	# Calculate row and column positions
	var row1: int = qubit1_pos / width
	var col1: int = qubit1_pos % width
	var row2: int = qubit2_pos / width
	var col2: int = qubit2_pos % width
	
	# Check if they are orthogonal neighbors
	var row_diff = abs(row1 - row2)
	var col_diff = abs(col1 - col2)
	if (row_diff + col_diff) != 1:  # Manhattan distance 1
		return false
	
	return true

func get_qubit_position_from_index(qubit_index: int) -> Vector2i:
	var col = qubit_index % x_qubits
	var row = qubit_index / x_qubits
	return Vector2i(col, row)

func add_cx_cz_visuals(control: int, target: int, gate_is_cz: bool) -> void:
	var pos1 = get_qubit_position_from_index(control)
	var pos2 = get_qubit_position_from_index(target)
	var dx = abs(pos1.x - pos2.x)
	var dy = abs(pos1.y - pos2.y)
	
	var gate_instance = gate_scene.instantiate()
	add_child(gate_instance)
	
	if dx == 1: # horizontal connection
		var x = min(pos1.x, pos2.x)
		var y = pos1.y
		var startx = (x - (x_qubits-1)/2.0) * cell_size + qubit_size
		var endx = (x + 1 - (x_qubits-1)/2.0) * cell_size - qubit_size
		var gatey = (y - (y_qubits-1)/2.0) * cell_size
		
		# flip the gate based on selection order so that 
		# we have first control then target
		var flip_horizontal = pos1.x < pos2.x
		if flip_horizontal:
			# swap start and end to flip the gate
			var temp = startx
			startx = endx
			endx = temp
		gate_instance.setup(Vector3(startx, gatey, 0), Vector3(endx, gatey, 0))
		
	else: # vertical connection
		var x = pos1.x
		var y = min(pos1.y, pos2.y)
		var gatex = (x - (x_qubits-1)/2.0) * cell_size
		var starty = (y - (y_qubits-1)/2.0) * cell_size + qubit_size
		var endy = (y + 1 - (y_qubits-1)/2.0) * cell_size - qubit_size

		# flip if needed
		var flip_vertical = pos1.y < pos2.y
		if flip_vertical:
			var temp = starty
			starty = endy
			endy = temp
			
		gate_instance.setup(Vector3(gatex, starty, 0), Vector3(gatex, endy, 0))
	
	if gate_is_cz:
		gate_instance.texture = preload("res://assets/cz.png")
