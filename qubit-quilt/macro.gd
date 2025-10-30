class_name Macro
extends Button

const DELAY: float = 0.1
var root: Vector2i # index of the macro root in the grid
var instructions: Array[QubitOperation] = []
var idx: int # position in macros array
var spread: Array[Vector2i] # stored in rot format
var macro_icon: String # icon for macro

@onready var grid: QubitGrid = get_node("/root/Scene/QubitGrid")
@onready var hotbar: ButtonGroup = preload("res://control_buttons.tres")

func _ready() -> void:
	self.button_group = preload("res://macros.tres")
	self.rebase_to_root()
	self.gen_spread()


func rebase_to_root() -> void:
	for instr in self.instructions:
		instr.index = instr.index - self.root
		instr.other = instr.other - self.root

func gen_spread() -> void:
	for instr in self.instructions:
		if not instr.index in self.spread:
			self.spread.append(instr.index)
		if (not instr.other in self.spread) and (instr.is_two_qubit()):
			self.spread.append(instr.other)
	print(self.spread)

func check_valid(target: Vector2i) -> bool:
	for instr in self.instructions:
		var offindex = instr.index + target
		var offother = instr.other + target
		
		if grid.is_not_in_bounds(offindex):
			return false
		if grid.is_not_in_bounds(offother) and (instr.is_two_qubit()):
			return false
		var index = grid.pos_to_idx(offindex)
		var other = grid.pos_to_idx(offother)
		if (grid.grid_qubits[other] == null) and (instr.is_two_qubit()):
			return false
		if grid.grid_qubits[index] == null:
			return false
	return true

func execute(target: Vector2i) -> void:
	for instr in self.instructions:
		var offindex = instr.index + target
		var offother = instr.other + target
		
		if grid.is_not_in_bounds(offindex):
			continue
		if grid.is_not_in_bounds(offother) and (instr.is_two_qubit()):
			continue
		var index = grid.pos_to_idx(offindex)
		var other = grid.pos_to_idx(offother)
		
		if (grid.grid_qubits[other] == null) and (instr.is_two_qubit()):
			continue
		if grid.grid_qubits[index] == null:
			continue
		
		match instr.operation:
			QubitOperation.Operation.RX:
				grid.rx(index)
			QubitOperation.Operation.RY:
				grid.ry(index)
			QubitOperation.Operation.RZ:
				grid.rz(index)
			QubitOperation.Operation.RH:
				grid.rh(index)
			QubitOperation.Operation.RS:
				grid.rs(index)
			QubitOperation.Operation.RSD:
				grid.rsd(index)
			QubitOperation.Operation.ADD:
				print_debug("TODO: fix ADD in macro")
				grid.make_qubit(offindex.x, offindex.y)
			QubitOperation.Operation.DELETE:
				print_debug("TODO: fix DELETE in macro")
				grid.grid_qubits[index].queue_free()
				grid.grid_qubits[index] = null
			QubitOperation.Operation.CX:
				grid.cx(index, other)
			QubitOperation.Operation.CZ:
				grid.cz(index, other)
			QubitOperation.Operation.MZ:
				grid.measure_z(index)
			QubitOperation.Operation.LABELA:
				grid.grid_qubits[index].toggle_ancilla()
			QubitOperation.Operation.LABELD:
				grid.grid_qubits[index].toggle_data()
		await get_tree().create_timer(DELAY).timeout

func _on_pressed() -> void:
	if hotbar.get_pressed_button():
		hotbar.get_pressed_button().button_pressed = false
		

static func _v2_to_arr(v: Vector2i) -> Array[int]:
	return [v.x, v.y]

static func _arr_to_v2(a: Array) -> Vector2i:
	if a.size() >= 2:
		return Vector2i(int(a[0]), int(a[1]))
	return Vector2i.ZERO

func to_dict() -> Dictionary:
	return {
		"title": self.text, # or another title property you use
		"root": [root.x, root.y],
		"instructions": instructions.map(func (op: QubitOperation): return op.to_dict()),
		"macro_icon": macro_icon,
	}

static func from_dict(d: Dictionary) -> Macro:
	var m := Macro.new()
	m.text = String(d.get("title", "Macro"))
	m.root = _arr_to_v2(d.get("root", [0, 0]))
	m.instructions.clear()
	for it in (d.get("instructions", []) as Array):
		m.instructions.append(QubitOperation.from_dict(it))
	m.macro_icon = String(d.get("macro_icon", null))
	return m
