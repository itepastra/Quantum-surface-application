class_name Macro
extends Button

const DELAY: float = 0.1
var root: Vector2i # index of the macro root in the grid
var instructions: Array[QubitOperation] = []
var idx: int # position in macros array
var spread: Array[Vector2i]

@onready var grid: QubitGrid = get_node("/root/Scene/QubitGrid")
@onready var hotbar: ButtonGroup = preload("res://control_buttons.tres")

func _ready() -> void:
	self.button_group = preload("res://macros.tres")
	self.gen_spread()

func gen_spread() -> void:
	for instr in self.instructions:
		var offindex = instr.index - self.root
		var offother = instr.other - self.root
		
		if not offindex in self.spread:
			self.spread.append(offindex)
		if (not offother in self.spread) and (instr.is_two_qubit()):
			self.spread.append(offother)

func check_valid(target: Vector2i) -> bool:
	for instr in self.instructions:
		var offindex = instr.index - self.root + target
		var offother = instr.other - self.root + target
		
		if offindex.x < 0 or offindex.x >= grid.x_qubits or offindex.y < 0 or offindex.y >= grid.y_qubits:
			return false
		if (offother.x < 0 or offother.x >= grid.x_qubits or offother.y < 0 or offother.y >= grid.y_qubits) and (instr.is_two_qubit()):
			return false
		var index = offindex.x + offindex.y * grid.x_qubits 
		var other = offother.x + offother.y * grid.x_qubits
		if (grid.grid_qubits[other] == null) and (instr.is_two_qubit()):
			return false
		if grid.grid_qubits[index] == null:
			return false
	return true

func execute(target: Vector2i) -> void:
	for instr in self.instructions:
		var offindex = instr.index - self.root + target
		var offother = instr.other - self.root + target
		
		if offindex.x < 0 or offindex.x >= grid.x_qubits or offindex.y < 0 or offindex.y >= grid.y_qubits:
			continue
		if (offother.x < 0 or offother.x >= grid.x_qubits or offother.y < 0 or offother.y >= grid.y_qubits) and (instr.is_two_qubit()):
			continue
		var index = offindex.x + offindex.y * grid.x_qubits 
		var other = offother.x + offother.y * grid.x_qubits
		
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
		await get_tree().create_timer(DELAY).timeout

func _on_pressed() -> void:
	if hotbar.get_pressed_button():
		hotbar.get_pressed_button().button_pressed = false
