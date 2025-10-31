class_name Qubit
extends Node3D

@onready var button_group: ButtonGroup = preload("res://control_buttons.tres")
@onready var macro_group: ButtonGroup = preload("res://macros.tres")

const DECAY_SPEED: float = 0.04
# no need to recalculate the angle every time
const angle_90 = deg_to_rad(90)

var sound: AudioStreamPlayer
var array_pos: int # what position this qubit has in the grid array
var pos: Vector2i # what position this qubit has in 2d coordinates
var rot: Basis # the "target" rotation
var is_rotating: bool = false
var is_hovered: bool = false

@onready var qb: StaticBody3D = get_node("QubitBody")
@onready var label: Label3D = get_node("QubitText")
@onready var grid: QubitGrid = get_parent() as QubitGrid
@onready var particle_color: BaseMaterial3D = preload("res://qubit_particle.tres") as BaseMaterial3D
@onready var meas_res: Label3D = get_node("MRes") as Label3D

func _ready():
	self.sound = get_node("/root/Scene/SoundSource")
	# connect to the qubit grid for applying the gates
	qb.transform.basis = self.rot
	self.is_rotating = false
	self.pos = grid.idx_to_pos(self.array_pos)

func set_base(num: int) -> void:
	self.rot = bases[num]
	self.is_rotating = true
	self.label.text = labels[num]


func highlight(is_warn: bool) -> void:
	pass

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
	# the user clicked on the qubit
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if grid.macro_running:
			grid.macro_running.skipping = true
			while grid.macro_running:
				await get_tree().create_timer(0.1).timeout

		# find the selected rotation direction from the buttongroup
		var pressed: Button = button_group.get_pressed_button()
		var macro: Button = macro_group.get_pressed_button()
		if pressed == null: # no pressed button, do nothing
			self.handle_macro(macro)
			return
		match pressed.name:
			"X":
				grid.rx(array_pos)
			"Y":
				grid.ry(array_pos)
			"Z":
				grid.rz(array_pos)
			"H":
				grid.rh(array_pos)
			"S":
				grid.rs(array_pos)
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
				var snap = grid.qec.snapshot_entanglement_group(array_pos)
				grid.qec.mz(array_pos)
				grid.grid_qubits[array_pos] = null
				grid.append_or_update(QubitOperation.Operation.DELETE, array_pos, -1, grid.qec.get_vop(self.array_pos))
				grid.operations[grid.operation_idx-1].snap = snap
				self.queue_free()
				grid.set_to_qec_state()
			"MZ":
				grid.measure_z(array_pos)
				self.set_label(grid.qec.get_vop(self.array_pos))
			"LABELA":
				grid.append_or_update(QubitOperation.Operation.LABELA, array_pos)
				self.toggle_ancilla()
			"LABELD":
				grid.append_or_update(QubitOperation.Operation.LABELD, array_pos)
				self.toggle_data()
			_:
				return
		sound.play()

func set_label(vop: int):
	meas_res.text = labels[vop]

func toggle_ancilla():
	(self.get_node("BG") as Node3D).visible = not (self.get_node("BG") as Node3D).visible

func toggle_data():
	(self.get_node("BORDER") as Node3D).visible = not (self.get_node("BORDER") as Node3D).visible


func handle_macro(macro: Button):
	if macro == null:
		return
	grid.macros[macro.idx].execute(self.pos)
	

const labels: Dictionary[int, String] = {
	-1: "",
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

func _on_macro_rotate() -> void:
	var macro: Macro = macro_group.get_pressed_button()
	if macro == null:
		return
		
	# remove old spread
	var spread = macro.get_spread()
	for s in spread:
		var offset: Vector2i = self.pos + s
		if grid.is_not_in_bounds(offset):
			continue
		var other = self.grid.pos_to_idx(offset)
		if grid.grid_qubits[other] == null:
			continue
		var glow = grid.grid_qubits[other].get_node("Glow") as GPUParticles3D
		glow.emitting = false
	
	macro.rotate()
	
	_on_qubit_body_mouse_entered()


func _on_qubit_body_mouse_entered() -> void:
	var macro: Macro = macro_group.get_pressed_button()
	if macro == null:
		return
	
	if not grid.rotate_macro.is_connected(_on_macro_rotate):
		grid.rotate_macro.connect(_on_macro_rotate)
	
	var all_valid: bool = true
	var to_toggle: Array[Qubit] = []
	var spread = macro.get_spread()
	for s in spread:
		var offset: Vector2i = self.pos + s
		if grid.is_not_in_bounds(offset):
			all_valid = false
			continue
		var other = self.grid.pos_to_idx(offset)
		if grid.grid_qubits[other] == null:
			all_valid = false
			continue
		to_toggle.append(grid.grid_qubits[other])
	if all_valid:
		particle_color.albedo_color = Color(0,1,0)
	else:
		particle_color.albedo_color = Color(1,0,1)
	for q in to_toggle:
		var glow = q.get_node("Glow") as GPUParticles3D
		glow.emitting = true

func _on_qubit_body_mouse_exited() -> void:
	var macro: Macro = macro_group.get_pressed_button()
	if macro == null:
		return

	if grid.rotate_macro.is_connected(_on_macro_rotate):
		grid.rotate_macro.disconnect(_on_macro_rotate)

	is_hovered = false
	
	var to_toggle: Array[Qubit] = []
	
	var rspread = macro.get_spread()
	for s in rspread:
		var offset: Vector2i = self.pos + s
		if grid.is_not_in_bounds(offset):
			continue
		var other = self.grid.pos_to_idx(offset)
		if grid.grid_qubits[other] == null:
			continue
		to_toggle.append(grid.grid_qubits[other])
	
	for q in to_toggle:
		var glow = q.get_node("Glow") as GPUParticles3D
		glow.emitting = false
	# get the selected macro spread
	
	# for each qubit in the spread
		# disable the emitter
