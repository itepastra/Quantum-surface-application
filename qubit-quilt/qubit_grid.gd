class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 1.5

@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

class Egroup:
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
	
	func reset():
		for qubit in qubits:
			qubit.eff_rot = Basis.IDENTITY
		if timer:
			timer.stop()
			timer.queue_free()
		self.queue_free()
	
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

@onready var codeEdit: CodeEdit = get_node("/root/Scene/HUD/CodeEdit")
@onready var play_timer: Timer = Timer.new()
@onready var play_pause: Button = get_node("/root/Scene/HUD/Spacer/TimeControl/PlayPause") as Button
@onready var play_icon: Texture2D = preload("res://assets/media-controls/play.png")
@onready var pause_icon: Texture2D = preload("res://assets/media-controls/pause.png")

const qubit_size = 1

var button: Button
var two_qubit_mode: bool = false
var selected_qubit: int = -1
var is_playing: bool = false
var two_qubit_gate_type: String = ""
var grid_qubits: Array[Qubit] = []
var start_pos: Vector3

var operation_idx: int = 0 # index of the operation that the user will be doing
var operations: Array[QubitOperation] = []

var entanglement_groups: Array[Egroup] = []

func set_to_qec_state():
	var graph: Dictionary[int,PackedInt32Array] = {};
	for i in x_qubits*y_qubits:
		grid_qubits[i].rot = bases[qec.get_vop(i)]
		grid_qubits[i].is_rotating = true
		graph.get_or_add(i, PackedInt32Array())
		graph[i].append_array(qec.get_adjacent(i))
	
	var visited: Dictionary[int, bool] = {};
	var egroups: Array[PackedInt32Array] = [];
	
	for q in graph:
		if not visited.has(q):
			var group: PackedInt32Array = [];
			var queue: Array[int] = [q]
			visited.set(q, true)
			
			while queue.size() > 0:
				var idx = queue.pop_front()
				group.append(idx)
				for neighbor in graph[idx]:
					if not visited.has(neighbor):
						visited.set(neighbor, true)
						queue.append(neighbor)
			egroups.append(group)

	for eg in entanglement_groups:
		eg.reset()
	entanglement_groups.clear()
	for group in egroups:
		if group.size() == 1:
			continue
		var qubits: Array[Qubit] = [];
		for i in group:
			qubits.append(grid_qubits[i])
		entanglement_groups.append(Egroup.new(qubits, self, randf_range(0.4, 1.0)))

func append_or_update(operation: QubitOperation.Operation, qubit_idx: int, target_idx: int=-1, basis: Basis = Basis.IDENTITY) -> void:
	operations.resize(operation_idx + 1)
	operations[operation_idx] = QubitOperation.new(operation, qubit_idx, target_idx, basis)
	operation_idx += 1
	codeEdit.update_qubit_operations(operations)
	codeEdit.set_executing(operation_idx)

var qec = Qec.new()

func _on_ready() -> void:
	self.button = get_node("/root/Scene/HUD/Spacer/Hotbar/ADD")
	qec.init(x_qubits*y_qubits);
	# NOTE: maybe there is a nicer way, but not one I can quickly think of
	var timecontrol = get_node("/root/Scene/HUD/Spacer/TimeControl")
	(timecontrol.get_node("SkipBack") as Button).pressed.connect(_on_skip_back)
	(timecontrol.get_node("StepBack") as Button).pressed.connect(_on_step_back)
	(timecontrol.get_node("PlayPause") as Button).pressed.connect(_on_play_pause)
	(timecontrol.get_node("StepForward") as Button).pressed.connect(_on_step_forward)
	(timecontrol.get_node("SkipForward") as Button).pressed.connect(_on_skip_forward)
	
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
			
	#setup timer
	play_timer.wait_time = 1
	play_timer.one_shot = false
	play_timer.autostart = false
	add_child(play_timer)
	play_timer.timeout.connect(_on_play_timer_timeout)

func _on_skip_back() -> void:
	while self.operation_idx > 0:
		self.handle_undo()

func _on_step_back() -> void:
	self.handle_undo()

func _on_play_pause() -> void:
	# I don't know exactly how to handle the playing, possibly by creating a timer where we do a `self.handle_redo()` every cycle?
	# I think this is for discussing during the meeting and therefore implementing in a seperate PR.
	if is_playing:
		play_timer.stop()
		is_playing = false
		play_pause.icon = play_icon
	else:
		if self.operation_idx < len(self.operations):
			play_timer.start()
			is_playing = true
			play_pause.icon = pause_icon
			

func _on_play_timer_timeout():
	if self.operation_idx < len(self.operations):
		self.handle_redo()
	else:
		play_timer.stop()
		is_playing = false	
		play_pause.icon = play_icon
		

func _on_step_forward() -> void:
	self.handle_redo()

func _on_skip_forward() -> void:
	while self.operation_idx < len(self.operations):
		self.handle_redo()

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
		codeEdit.set_executing(operation_idx)
		match selected_op.operation:
			QubitOperation.Operation.RX:
				rx(selected_op.index, false)
			QubitOperation.Operation.RY:
				ry(selected_op.index, false)
			QubitOperation.Operation.RZ:
				rz(selected_op.index, false)
			QubitOperation.Operation.RH:
				rh(selected_op.index, false)
			QubitOperation.Operation.RS:
				rsd(selected_op.index, false)
			QubitOperation.Operation.RSD:
				rs(selected_op.index, false)
			QubitOperation.Operation.ADD:
				grid_qubits[selected_op.index].queue_free()
				grid_qubits[selected_op.index] = null
			QubitOperation.Operation.DELETE:
				var x: int = selected_op.index % x_qubits
				var y: int = selected_op.index / x_qubits
				make_qubit(x, y, selected_op.basis)
			QubitOperation.Operation.CX:
				cx(selected_op.index, selected_op.other, false)
			QubitOperation.Operation.CZ:
				cz(selected_op.index, selected_op.other, false)

func handle_redo() -> void:
	if self.operation_idx >= len(operations):
		print("redo without any future")
		return
	else:
		var selected_op = operations[self.operation_idx]
		match selected_op.operation:
			QubitOperation.Operation.RX:
				rx(selected_op.index, false)
			QubitOperation.Operation.RY:
				ry(selected_op.index, false)
			QubitOperation.Operation.RZ:
				rz(selected_op.index, false)
			QubitOperation.Operation.RH:
				rh(selected_op.index, false)
			QubitOperation.Operation.RS:
				rs(selected_op.index, false)
			QubitOperation.Operation.RSD:
				rsd(selected_op.index, false)
			QubitOperation.Operation.ADD:
				var x: int = floori(selected_op.index % x_qubits)
				var y: int = floori(selected_op.index / x_qubits)
				make_qubit(x, y)
			QubitOperation.Operation.DELETE:
				grid_qubits[selected_op.index].queue_free()
				grid_qubits[selected_op.index] = null
			QubitOperation.Operation.CX:
				cx(selected_op.index, selected_op.other, false)
			QubitOperation.Operation.CZ:
				cz(selected_op.index, selected_op.other, false)
		operation_idx += 1 # redo "what the user will be doing"
		codeEdit.set_executing(operation_idx)

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


func rx(qubit: int, update: bool = true):
	var q = grid_qubits[qubit]
	qec.xgate(qubit)
	q.rot = bases[qec.get_vop(qubit)]
	q.is_rotating = true;
	if update:
		append_or_update(QubitOperation.Operation.RX, qubit)


func ry(qubit: int, update: bool = true):
	var q = grid_qubits[qubit]
	qec.ygate(qubit)
	q.rot = bases[qec.get_vop(qubit)]
	q.is_rotating = true;
	if update:
		append_or_update(QubitOperation.Operation.RY, qubit)

func rz(qubit: int, update: bool = true):
	var q = grid_qubits[qubit]
	# the qubit's z-axis is the y axis in godot
	qec.zgate(qubit)
	q.rot = bases[qec.get_vop(qubit)]
	q.is_rotating = true;
	if update:
		append_or_update(QubitOperation.Operation.RZ, qubit)

func rh(qubit: int, update: bool = true):
	var q = grid_qubits[qubit]
	qec.hadamard(qubit)
	q.rot = bases[qec.get_vop(qubit)]
	q.is_rotating = true;
	if update:
		append_or_update(QubitOperation.Operation.RH, qubit)

func rs(qubit: int, update: bool = true):
	var q = grid_qubits[qubit]
	qec.phase(qubit)
	q.rot = bases[qec.get_vop(qubit)]
	q.is_rotating = true;
	if update:
		append_or_update(QubitOperation.Operation.RS, qubit)

func rsd(qubit: int, update: bool = true):
	var q = grid_qubits[qubit]
	qec.phase_dag(qubit)
	q.rot = bases[qec.get_vop(qubit)]
	q.is_rotating = true;
	if update:
		append_or_update(QubitOperation.Operation.RSD, qubit)

func cx(control: int, target: int, update: bool = true):
	if not check_orthogonal_neighbors(control, target, x_qubits):
		print_debug("Not nearest neighbors in this grid configuration")
		return
	
	add_cx_cz_visuals(control, target, false)
	
	# apply cx between control and target
	var qc = grid_qubits[control]
	var qt = grid_qubits[target]
	qec.cnot(control, target)
	set_to_qec_state()
	if update:
		append_or_update(QubitOperation.Operation.CX, control, target)

func cz(control: int, target: int, update: bool = true):
	if not check_orthogonal_neighbors(control, target, x_qubits):
		print_debug("Not nearest neighbors in this grid configuration")
		return
	
	add_cx_cz_visuals(control, target, true)
	
	# apply cz between control and target
	var qc = grid_qubits[control]
	var qt = grid_qubits[target]
	qec.cphase(control, target)
	set_to_qec_state()
	if update:
		append_or_update(QubitOperation.Operation.CZ, control, target)

func check_orthogonal_neighbors(qubit1_pos: int, qubit2_pos: int, width: int) -> bool:
	return true
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

const bases = {
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
