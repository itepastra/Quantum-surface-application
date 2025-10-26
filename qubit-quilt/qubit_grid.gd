class_name QubitGrid
extends Node3D

@export var x_qubits: int = 1
@export var y_qubits: int = 1

@export var macro_scene: PackedScene
@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

var enabled_gates: Array[String] = ["X", "Y", "Z", "H", "S", "CX", "CZ", "MZ", "ADD", "REMOVE", "LABELA", "LABELD"]

var drag_gate: Gate
var selected_gate_type: Gate.Type

class Egroup:
	extends Node
	var qubits: Array[Qubit] = []
	var eff: int
	var timer: Timer
	var qec: Qec
	
	func _init(qubits: Array[Qubit], grid: QubitGrid, qec: Qec, period: float = 1) -> void:
		self.qubits = qubits
		self.qec = qec
		grid.add_child(self)
		random_rotate()
		timer = Timer.new()
		timer.autostart = true
		timer.wait_time = period
		timer.timeout.connect(_on_timer_timeout)
		self.add_child(timer)
	
	func _on_timer_timeout():
		var qubit_idxs:PackedInt32Array  = []
		for q in qubits:
			qubit_idxs.append(q.array_pos)
		var results = qec.peek_measurement_random(qubit_idxs)
		for i in len(results):
			qubits[i].set_base(results[i] & 0b11111)
		#random_rotate()
	
	func reset():
		if timer:
			timer.stop()
			timer.queue_free()
		self.queue_free()
	
	func random_rotate():
		var qubit_idxs:PackedInt32Array  = []
		for q in qubits:
			qubit_idxs.append(q.array_pos)
		var results = qec.peek_measurement_random(qubit_idxs)
		for i in len(results):
			qubits[i].set_base(results[i]&0b11111)

@onready var codeEdit: CodeEdit = get_node("/root/Scene/HUD/Tabs/QASM")
@onready var play_timer: Timer = Timer.new()
@onready var play_pause: Button = get_node("/root/Scene/HUD/Spacer/TimeControl/PlayPause") as Button
@onready var play_icon: Texture2D = preload("res://assets/media-controls/play.png")
@onready var pause_icon: Texture2D = preload("res://assets/media-controls/pause.png")
@onready var macro_button: Button = get_node("/root/Scene/HUD/Spacer/Macros/RecordMacro") as Button

var recording = false
var macro_instructions: Array[QubitOperation] = []
var macros: Array[Macro] = []
var macro_idx: int = 0

const qubit_size = 1

var button: Button
var two_qubit_mode: bool = false
var selected_qubit: int = -1
var is_playing: bool = false
var two_qubit_gate_type: String = ""
var grid_qubits: Array[Qubit] = []
var start_pos: Vector3
var qec = Qec.new()
var camera: Camera

var operation_idx: int = 0 # index of the operation that the user will be doing
var operations: Array[QubitOperation] = []

var entanglement_groups: Array[Egroup] = []

# works specifically for the cell size (1.8, 0.9), 
# calculated by making a square that looked correct and then the inverse affine transform
# offset is calculated at initialisation, since it depends on the amount of qubits
var aftrans: Transform3D = Transform3D(Basis(
	Vector3(5.0/9.0, -5.0/9.0, 0.0), 
	Vector3(5.0/9.0, 5.0/9.0, 0.0),
	Vector3(0.0, 0.0, 1.0/sqrt(2))
), 
	Vector3(0.0, 0.0, 0.0)
)

func set_to_qec_state():
	var graph: Dictionary[int,PackedInt32Array] = {};
	for i in x_qubits*y_qubits:
		if grid_qubits[i] == null:
			continue
		grid_qubits[i].set_base(qec.get_vop(i))
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
		var qubits: Array[Qubit] = []
		for i in group:
			qubits.append(grid_qubits[i])
		entanglement_groups.append(Egroup.new(qubits, self, qec, randf_range(1.5, 3)))

func pos_to_idx(pos: Vector2i) -> int:
	return pos.x/2 + pos.y * self.x_qubits

func idx_to_pos(idx: int) -> Vector2i:
	var y = idx / self.x_qubits
	return Vector2i((idx % self.x_qubits)*2 + (y&1), y)

func append_or_update(operation: QubitOperation.Operation, qubit_idx: int, target_idx: int = 0, basis: int = 10) -> void:
	operations.resize(operation_idx + 1)
	var qubit_loc = idx_to_pos(qubit_idx)
	var target_loc = idx_to_pos(target_idx)
	operations[operation_idx] = QubitOperation.new(operation, qubit_loc, target_loc, basis)
	operation_idx += 1
	if self.recording:
		self.macro_instructions.resize(macro_idx + 1)
		self.macro_instructions[macro_idx] = QubitOperation.new(operation, qubit_loc, target_loc, basis)
		self.macro_idx += 1
	codeEdit.update_qubit_operations(self.operations[-1])
	codeEdit.set_executing(operation_idx)

func parse_js_args() -> void:
	if OS.has_feature("web"):
		var iface = JavaScriptBridge.get_interface("qubits")
		if iface:
			self.x_qubits = iface.width
			self.y_qubits = iface.height
			self.enabled_gates = []
			for i in iface.gates.length:
				self.enabled_gates.append(iface.gates[i])

func _on_ready() -> void:
	parse_js_args()
	init_error_rates()
	
	var hb = get_node("/root/Scene/HUD/Spacer/Hotbar/")
	
	for b in self.enabled_gates:
		var but = hb.get_node(b) as Button
		but.visible = true;
	
	(hb.get_node("CX") as Button).pressed.connect(func(): self.selected_gate_type = Gate.Type.CX)
	(hb.get_node("CZ") as Button).pressed.connect(func(): self.selected_gate_type = Gate.Type.CZ)
	
	self.button = hb.get_node("ADD")
	qec.init(x_qubits*y_qubits);
	# NOTE: maybe there is a nicer way, but not one I can quickly think of
	var timecontrol = get_node("/root/Scene/HUD/Spacer/TimeControl")
	(timecontrol.get_node("SkipBack") as Button).pressed.connect(_on_skip_back)
	(timecontrol.get_node("StepBack") as Button).pressed.connect(_on_step_back)
	(timecontrol.get_node("PlayPause") as Button).pressed.connect(_on_play_pause)
	(timecontrol.get_node("StepForward") as Button).pressed.connect(_on_step_forward)
	(timecontrol.get_node("SkipForward") as Button).pressed.connect(_on_skip_forward)
	macro_button.pressed.connect(_on_macro_button)
	
	
	self.camera = %Camera as Camera
	# Resize the camera to fit with the grid
	var full_grid_size = Vector2(x_qubits * cell_size.x, y_qubits*cell_size.y)
	
	self.start_pos = Vector3(-(x_qubits-1)/2.0, -(y_qubits-1)/2.0, 0)
	self.aftrans.origin = aftrans * (-self.start_pos * cell_size)
	# initialize the qubits themselves
	for y in y_qubits:
		for x in x_qubits:
			make_qubit(Vector2i(2*x,y))
	#setup timer
	play_timer.wait_time = 1
	play_timer.one_shot = false
	play_timer.autostart = false
	add_child(play_timer)
	play_timer.timeout.connect(_on_play_timer_timeout)

var error_rates: PackedFloat32Array;

func init_error_rates() -> void:
	for type in ErrorControl.ErrType:
		error_rates.append(0)

func handle_error_changed(value: float, err_type: ErrorControl.ErrType) -> void:
	error_rates[err_type] = value


func _on_macro_button() -> void:
	if self.recording:
		stop_record_macro()
	else:
		start_record_macro()

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


func start_record_macro():
	self.macro_instructions = [] # reset the macro instructions
	self.macro_idx = 0
	self.recording = true

func stop_record_macro():
	self.recording = false
	if len(self.macro_instructions) == 0:
		return
	var macro: Macro = macro_scene.instantiate()
	macro.root = self.macro_instructions[0].index
	macro.instructions = self.macro_instructions
	self.macro_instructions = []
	macro.text = "M%d" % (len(macros) + 1)
	macro.name = "%d" % len(macros)
	macro.idx = len(macros)
	self.macros.append(macro)
	get_node("/root/Scene/HUD/Spacer/Macros").add_child(macro)

const cell_size: Vector3 = Vector3(1.8, 0.9, 1.0)

func make_qubit(pos: Vector2i, basis: int = 10):
	var nextQubit: Qubit = qubit_scene.instantiate()
	nextQubit.name = "Qubit %s" % [pos]
	nextQubit.position.x = pos.x / 2 + start_pos.x + (pos.y & 0b1) * 0.5
	nextQubit.position.y = pos.y + start_pos.y
	nextQubit.position *= cell_size
	nextQubit.array_pos = pos_to_idx(pos)
	nextQubit.rot = nextQubit.bases[basis]
	
	if self.camera.minvec.x > nextQubit.position.x:
		self.camera.minvec.x = nextQubit.position.x
	if self.camera.minvec.y > nextQubit.position.y:
		self.camera.minvec.y = nextQubit.position.y
	if self.camera.maxvec.x < nextQubit.position.x:
		self.camera.maxvec.x = nextQubit.position.x
	if self.camera.maxvec.y < nextQubit.position.y:
		self.camera.maxvec.y = nextQubit.position.y
	
	if len(grid_qubits) <= nextQubit.array_pos:
		grid_qubits.append(nextQubit)
	else:
		grid_qubits[nextQubit.array_pos] = nextQubit
	self.add_child(nextQubit)

func undo_operation(op: QubitOperation):
	# undo what errors did
	var esize = op.errors.size()
	for sub_op_idx in range(esize-1, -1, -1):
		undo_operation(op.errors[sub_op_idx])
	
	var op_idx = pos_to_idx(op.index)
	var op_tgt = pos_to_idx(op.other)
	match op.operation:
		QubitOperation.Operation.RX:
			rx(op_idx, false, false)
		QubitOperation.Operation.RY:
			ry(op_idx, false, false)
		QubitOperation.Operation.RZ:
			rz(op_idx, false, false)
		QubitOperation.Operation.RH:
			rh(op_idx, false, false)
		QubitOperation.Operation.RS:
			rsd(op_idx, false, false)
		QubitOperation.Operation.RSD:
			rs(op_idx, false, false)
		QubitOperation.Operation.ADD:
			grid_qubits[op_idx].queue_free()
			grid_qubits[op_idx] = null
		QubitOperation.Operation.DELETE:
			make_qubit(op.index, op.basis)
		QubitOperation.Operation.CX:
			cx(op_idx, op_tgt, false, false)
		QubitOperation.Operation.CZ:
			cz(op_idx, op_tgt, false, false)
		QubitOperation.Operation.MZ:
			if op.snap:
				qec.restore_entanglement_group(op.snap)
				set_to_qec_state()
			else:
				print_debug("Missing snapshot for MZ at op index %d" % operation_idx)
	op.errors = []

func handle_undo() -> void:
	if self.operation_idx <= 0:
		return
	else:
		operation_idx -= 1 # go from "what the user will be doing" to "what the user just did" to undo that
		var selected_op = operations[self.operation_idx]
		codeEdit.set_executing(operation_idx)
		undo_operation(selected_op)

func is_not_in_bounds(pos: Vector2i) -> bool:
	return pos.x < 0 or pos.x/2 >= self.x_qubits or pos.y < 0 or pos.y >= self.y_qubits

func handle_redo() -> void:
	if self.operation_idx >= len(operations):
		return
	else:
		var selected_op = operations[self.operation_idx]
		operation_idx += 1 # redo "what the user will be doing"
		codeEdit.set_executing(operation_idx)
		var op_idx = pos_to_idx(selected_op.index)
		var op_tgt = pos_to_idx(selected_op.other)
		match selected_op.operation:
			QubitOperation.Operation.RX:
				rx(op_idx, false)
			QubitOperation.Operation.RY:
				ry(op_idx, false)
			QubitOperation.Operation.RZ:
				rz(op_idx, false)
			QubitOperation.Operation.RH:
				rh(op_idx, false)
			QubitOperation.Operation.RS:
				rs(op_idx, false)
			QubitOperation.Operation.RSD:
				rsd(op_idx, false)
			QubitOperation.Operation.ADD:
				make_qubit(selected_op.index.x, selected_op.index.y)
			QubitOperation.Operation.DELETE:
				grid_qubits[op_idx].queue_free()
				grid_qubits[op_idx] = null
			QubitOperation.Operation.CX:
				cx(op_idx, op_tgt, false)
			QubitOperation.Operation.CZ:
				cz(op_idx, op_tgt, false)
			QubitOperation.Operation.MZ:
				measure_z(op_idx, false)

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
		var mevent: InputEventMouseButton = event as InputEventMouseButton
		var world_pos: Vector3 = camera.project_position(mevent.position, 10)
		var transformed: Vector3 = (aftrans * world_pos).snapped(Vector3(1.0, 1.0, 1.0))
		var pos: Vector2i = Vector2i((transformed.x - transformed.y), (transformed.x + transformed.y))
		var idx: int = pos_to_idx(pos)
		if self.is_not_in_bounds(pos):
			pass
		elif grid_qubits[idx] == null:
			make_qubit(Vector2i((transformed.x - transformed.y), (transformed.x + transformed.y)))
			append_or_update(QubitOperation.Operation.ADD, idx)
	elif self.selected_qubit != -1 and event is InputEventMouseMotion:
		if drag_gate == null:
			drag_gate = gate_scene.instantiate()
			drag_gate.process_mode = Node.PROCESS_MODE_DISABLED
			self.add_child(drag_gate)
		var world_pos: Vector3 = camera.project_position(event.position, 7)
		var pos1: Vector3 = grid_qubits[self.selected_qubit].position + Vector3(0, 0, 3)
		var ndiff: Vector3 = (world_pos - pos1).normalized()
		drag_gate.setup(pos1 + ndiff/3, world_pos, selected_gate_type)

func rx(qubit: int, update: bool = true, do_errors: bool = true):
	if update:
		append_or_update(QubitOperation.Operation.RX, qubit)
	var q = grid_qubits[qubit]
	qec.xgate(qubit)
	if do_errors:
		do_errors(qubit)
	q.set_base(qec.get_vop(qubit))


func ry(qubit: int, update: bool = true, do_errors: bool = true):
	if update:
		append_or_update(QubitOperation.Operation.RY, qubit)
	var q = grid_qubits[qubit]
	qec.ygate(qubit)
	if do_errors: 
		do_errors(qubit)
	q.set_base(qec.get_vop(qubit))

func rz(qubit: int, update: bool = true, do_errors: bool = true):
	if update:
		append_or_update(QubitOperation.Operation.RZ, qubit)
	var q = grid_qubits[qubit]
	# the qubit's z-axis is the y axis in godot
	qec.zgate(qubit)
	if do_errors: 
		do_errors(qubit)
	q.set_base(qec.get_vop(qubit))

func rh(qubit: int, update: bool = true, do_errors: bool = true):
	if update:
		append_or_update(QubitOperation.Operation.RH, qubit)
	var q = grid_qubits[qubit]
	qec.hadamard(qubit)
	if do_errors: 
		do_errors(qubit)
	q.set_base(qec.get_vop(qubit))

func rs(qubit: int, update: bool = true, do_errors: bool = true):
	if update:
		append_or_update(QubitOperation.Operation.RS, qubit)
	var q = grid_qubits[qubit]
	qec.phase(qubit)
	if do_errors: 
		do_errors(qubit)
	q.set_base(qec.get_vop(qubit))

func rsd(qubit: int, update: bool = true, do_errors: bool = true):
	if update:
		append_or_update(QubitOperation.Operation.RSD, qubit)
	var q = grid_qubits[qubit]
	qec.phase_dag(qubit)
	if do_errors: 
		do_errors(qubit)
	q.set_base(qec.get_vop(qubit))

func cx(control: int, target: int, update: bool = true, do_errors: bool = true):
	if not check_orthogonal_neighbors(control, target, x_qubits):
		print_debug("Not nearest neighbors in this grid configuration")
		return
	if update:
		append_or_update(QubitOperation.Operation.CX, control, target)
	add_cx_cz_visuals(control, target, Gate.Type.CX)
	qec.cnot(control, target)
	if do_errors: 
		do_errors(control)
		do_errors(target)
	set_to_qec_state()

func cz(control: int, target: int, update: bool = true, do_errors: bool = true):
	if not check_orthogonal_neighbors(control, target, x_qubits):
		print_debug("Not nearest neighbors in this grid configuration")
		return
	if update:
		append_or_update(QubitOperation.Operation.CZ, control, target)
	
	add_cx_cz_visuals(control, target, Gate.Type.CZ)
	
	qec.cphase(control, target)
	if do_errors: 
		do_errors(control)
		do_errors(target)
	set_to_qec_state()

func measure_z(qubit: int, update: bool = true, do_errors: bool = true):
	var snap: Dictionary = qec.snapshot_entanglement_group(qubit)
	if update:
		append_or_update(QubitOperation.Operation.MZ, qubit)
	qec.mz(qubit)
	if do_errors:
		do_errors(qubit)
	self.operations[operation_idx-1].snap = snap
	set_to_qec_state()

func check_orthogonal_neighbors(qubit1_pos: int, qubit2_pos: int, width: int) -> bool:
	return qubit1_pos != qubit2_pos

func do_bitflip_error(qubit: int):
	self.operations[operation_idx-1].errors.append(QubitOperation.new(QubitOperation.Operation.RX, idx_to_pos(qubit)))
	qec.xgate(qubit)
	self.grid_qubits[qubit].set_base(qec.get_vop(qubit))

func do_phaseflip_error(qubit: int):
	self.operations[operation_idx-1].errors.append(QubitOperation.new(QubitOperation.Operation.RZ, idx_to_pos(qubit)))
	qec.zgate(qubit)
	self.grid_qubits[qubit].set_base(qec.get_vop(qubit))

func do_relaxation_error(qubit: int):
	var new_op = QubitOperation.new(QubitOperation.Operation.MZ, idx_to_pos(qubit))
	new_op.snap = qec.snapshot_entanglement_group(qubit)
	self.operations[operation_idx-1].errors.append(new_op)
	qec.relax(qubit)
	self.grid_qubits[qubit].set_base(qec.get_vop(qubit))

func do_errors(qubit: int):
	# reset the errors that may exist from earlier
	self.operations[operation_idx-1].errors.clear()
	for i in self.error_rates.size():
		if randf() < self.error_rates[i]:
			match i:
				ErrorControl.ErrType.BITFLIP_GATE:
					do_bitflip_error(qubit)
				ErrorControl.ErrType.PHASEFLIP_GATE:
					do_phaseflip_error(qubit)
				ErrorControl.ErrType.RELAXATION_GATE:
					do_relaxation_error(qubit)
				ErrorControl.ErrType.BITFLIP_ANY:
					var target = randi_range(0, grid_qubits.size() - 1)
					if grid_qubits[target] != null:
						do_bitflip_error(target)
				ErrorControl.ErrType.PHASEFLIP_ANY:
					var target = randi_range(0, grid_qubits.size() - 1)
					if grid_qubits[target] != null:
						do_phaseflip_error(target)
				ErrorControl.ErrType.RELAXATION_ANY:
					var target = randi_range(0, grid_qubits.size() - 1)
					if grid_qubits[target] != null:
						do_relaxation_error(target)
				_:
					print("unhandled error type %d" % i)

func add_cx_cz_visuals(control: int, target: int, gate_type: Gate.Type) -> void:
	var pos1: Vector3 = grid_qubits[control].position + Vector3(0, 0, 3)
	var pos2: Vector3 = grid_qubits[target].position + Vector3(0, 0, 3)
	var ndiff: Vector3 = (pos2 - pos1).normalized()
	var g = self.gate_scene.instantiate()
	self.add_child(g)
	g.setup(pos1 + ndiff/3, pos2 - ndiff/3, gate_type)
	if self.drag_gate != null:
		self.drag_gate.queue_free()
