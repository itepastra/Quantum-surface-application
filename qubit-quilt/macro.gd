class_name Macro
extends Button

const DELAY: float = 0.1
var root: int # index of the macro root in the grid
var instructions: Array[QubitOperation] = []
var idx: int # position in macros array
@onready var grid: QubitGrid = get_node("/root/Scene/QubitGrid")

@onready var hotbar: ButtonGroup = preload("res://control_buttons.tres")

func _ready() -> void:
	self.button_group = preload("res://macros.tres")
	print(self.button_group)


func execute(target: int):
	for instr in self.instructions:
		# calculate the offset targets
		var offindex = instr.index - self.root + target
		var offother = instr.other - self.root + target
		
		# check if possible (do I want to check all of them first??)
		if offindex >= len(grid.grid_qubits) or offindex < 0:
			print("offset ", offindex, " outside of array range, ignoring")
			continue
		if (instr.is_two_qubit()) and (offother >= len(grid.grid_qubits) or offother < 0):
			print("offother ", offother, " outside of array range, ignoring")
			continue
		if (grid.grid_qubits[offother] == null) and (instr.is_two_qubit()):
			print("otheridx ", offother, " did not exist in grid: ", grid.grid_qubits[offother])
			continue
		if grid.grid_qubits[offindex] == null:
			print("offsetidx ", offindex, " did not exist in grid: ", grid.grid_qubits[offindex])
			continue
		match instr.operation:
			QubitOperation.Operation.RX:
				grid.rx(offindex)
			QubitOperation.Operation.RY:
				grid.ry(offindex)
			QubitOperation.Operation.RZ:
				grid.rz(offindex)
			QubitOperation.Operation.RH:
				grid.rh(offindex)
			QubitOperation.Operation.RS:
				grid.rs(offindex)
			QubitOperation.Operation.RSD:
				grid.rsd(offindex)
			QubitOperation.Operation.ADD:
				print_debug("TODO: fix ADD in macro")
				var x: int = floori(offindex % grid.x_qubits)
				var y: int = floori(offindex / grid.x_qubits)
				grid.make_qubit(x, y)
			QubitOperation.Operation.DELETE:
				print_debug("TODO: fix DELETE in macro")
				grid.grid_qubits[offindex].queue_free()
				grid.grid_qubits[offindex] = null
			QubitOperation.Operation.CX:
				grid.cx(offindex, offother)
			QubitOperation.Operation.CZ:
				grid.cz(offindex, offother)
			QubitOperation.Operation.MZ:
				grid.measure_z(offindex)
		await get_tree().create_timer(DELAY).timeout

func _on_pressed() -> void:
	if hotbar.get_pressed_button():
		hotbar.get_pressed_button().button_pressed = false
