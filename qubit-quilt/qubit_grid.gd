class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 1.5

@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

const qubit_size = 1
const angle_90 = deg_to_rad(90)

var button: Button
var two_qubit_mode: bool = false
var selected_qubit: int = -1
var two_qubit_gate_type: String = ""
var grid_qubits: Array[Qubit] = []
var start_pos: Vector3

var operation_idx: int = 0 # index of the operation that the user will be doing
var operations: Array[QubitOperation] = []

func append_or_update(operation: QubitOperation.Operation, qubit_idx: int, target_idx: int=-1, basis: Basis = Basis.IDENTITY) -> void:
	operations.resize(operation_idx + 1)
	operations[operation_idx] = QubitOperation.new(operation, qubit_idx, target_idx, basis)
	operation_idx += 1

var qec = Qec.new()

func _on_ready() -> void:
	self.button = get_node("/root/Scene/HUD/Hotbar/ADD")
	# Resize the camera to fit with the grid
	var full_grid_size = Vector2(x_qubits * cell_size, y_qubits*cell_size)
	var camera: Camera3D = %Camera
	camera.size = max(full_grid_size.x, full_grid_size.y)*1.05
	# Dynamically change the keep_aspect of the camera to always fit the whole grid
	camera.keep_aspect = camera.KEEP_WIDTH if full_grid_size.x > full_grid_size.y else camera.KEEP_HEIGHT
	
	self.start_pos = Vector3(-(x_qubits-1)/2.0, -(y_qubits-1)/2.0, 0)
	# initialize the qubits themselves
	for y in y_qubits:
		for x in x_qubits:
			make_qubit(x,y)

func make_qubit(x: int, y: int, basis: Basis = Basis(Vector3(-0,-1,-0), Vector3(0,-0,1), Vector3(-1,0,0))):
	var nextQubit: Qubit = qubit_scene.instantiate()
	nextQubit.name = "Qubit (%d, %d)" % [x,y]
	nextQubit.position.x = x + start_pos.x
	nextQubit.position.y = y + start_pos.y
	nextQubit.position *= cell_size
	nextQubit.array_pos = y*x_qubits + x
	nextQubit.transform.basis = basis
	if len(grid_qubits) <= nextQubit.array_pos:
		grid_qubits.append(nextQubit)
	else:
		grid_qubits[nextQubit.array_pos] = nextQubit
	self.add_child(nextQubit)

func handle_undo() -> void:
	if self.operation_idx <= 0:
		print("undo without any action")
		return
	else:
		operation_idx -= 1 # go from "what the user will be doing" to "what the user just did" to undo that
		var selected_op = operations[self.operation_idx]
		match selected_op.operation:
			QubitOperation.Operation.RX:
				rq(grid_qubits[selected_op.index], grid_qubits[selected_op.index].rot.x, -angle_90)
			QubitOperation.Operation.RY:
				rq(grid_qubits[selected_op.index], -grid_qubits[selected_op.index].rot.z, -angle_90)
			QubitOperation.Operation.RZ:
				rq(grid_qubits[selected_op.index], grid_qubits[selected_op.index].rot.y, -angle_90)
			QubitOperation.Operation.ADD:
				grid_qubits[selected_op.index].queue_free()
				grid_qubits[selected_op.index] = null
			QubitOperation.Operation.DELETE:
				var x: int = selected_op.index % x_qubits
				var y: int = selected_op.index / x_qubits
				make_qubit(x, y, selected_op.basis)

func handle_redo() -> void:
	if self.operation_idx >= len(operations):
		print("redo without any future")
		return
	else:
		var selected_op = operations[self.operation_idx]
		match selected_op.operation:
			QubitOperation.Operation.RX:
				rq(grid_qubits[selected_op.index], grid_qubits[selected_op.index].rot.x, angle_90)
			QubitOperation.Operation.RY:
				rq(grid_qubits[selected_op.index], -grid_qubits[selected_op.index].rot.z, angle_90)
			QubitOperation.Operation.RZ:
				rq(grid_qubits[selected_op.index], grid_qubits[selected_op.index].rot.y, angle_90)
			QubitOperation.Operation.ADD:
				var x: int = floori(selected_op.index % x_qubits)
				var y: int = floori(selected_op.index / x_qubits)
				make_qubit(x, y)
			QubitOperation.Operation.DELETE:
				grid_qubits[selected_op.index].queue_free()
				grid_qubits[selected_op.index] = null
		operation_idx += 1 # redo "what the user will be doing"

func _input(event: InputEvent) -> void:
	# if ctrl + z is pressed
	if event.is_action_pressed("undo", false, true):
		handle_undo()
		return
	# if ctrl + shift + z is pressed
	if event.is_action_pressed("redo", false, true):
		handle_redo()
		return
	# filter out all the input events that aren't mouse clicks with the create button selected
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and self.button.button_pressed:
		# get the position in grid space of the click
		var camera: Camera3D = %Camera
		var mevent = event as InputEventMouseButton
		var world_pos: Vector3 = camera.project_position(mevent.position, 10)/cell_size - start_pos
		# get the closest qubit clamped to the size of the grid
		var snapped_pos = world_pos.snapped(Vector3(1, 1, 1)).clamp(
			Vector3(0,0,0), Vector3(x_qubits-1,y_qubits-1,0))
		# check if any qubit in the grid has the coordinates we would be creating it at
		var collision = false
		for qubit in grid_qubits:
			if qubit == null:
				continue
			elif qubit.position.is_equal_approx((snapped_pos + start_pos)*cell_size):
				collision = true
		# create a qubit at the correct position
		if not collision:
			var x = roundi(snapped_pos.x)
			var y = roundi(snapped_pos.y)
			make_qubit(x, y)
			append_or_update(QubitOperation.Operation.ADD, y*x_qubits + x)


func rx(qubit: int):
	var q = grid_qubits[qubit]
	rq(q, q.rot.x)
	append_or_update(QubitOperation.Operation.RX, qubit)


func ry(qubit: int):
	var q = grid_qubits[qubit]
	# the qubit's y-axis is the -z axis in godot
	rq(q, -q.rot.z)
	append_or_update(QubitOperation.Operation.RY, qubit)

func rz(qubit: int):
	var q = grid_qubits[qubit]
	# the qubit's z-axis is the y axis in godot
	rq(q, q.rot.y)
	append_or_update(QubitOperation.Operation.RZ, qubit)

func rq(qubit: Qubit, axis: Vector3, angle=angle_90):
	qubit.rot = qubit.rot.rotated(axis, angle).orthonormalized()
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
	append_or_update(QubitOperation.Operation.CX, control, target)
	
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
	append_or_update(QubitOperation.Operation.CZ, control, target)

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
