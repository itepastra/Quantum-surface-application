extends CodeEdit

@onready var grid: QubitGrid = get_node("/root/Scene/QubitGrid")
var init_string: String
var setup_offset: int

func _on_code_editor_toggled(toggled_on: bool) -> void:
	self.visible = toggled_on


func _on_ready() -> void:
	self.visible = false
	self.init_string = initial_qubit_operations(grid.x_qubits, grid.y_qubits)
	self.setup_offset = len(init_string.split("\n")) - 1
	self.text = init_string

func initial_qubit_operations(width: int, height: int) -> String:
	var fstring: String = "version 3.0

// a basic cQASM example 

/*This is an example 
		creating one of the Bell states */

qubit[%s] q
init q[0:%s]
"
	return fstring % [(width*height), (width*height)-1]

func set_executing(step: int):
	self.clear_executing_lines()
	self.set_line_as_executing(step + setup_offset, true)

func update_qubit_operations(op: QubitOperation) -> void:
	match op.operation:
		QubitOperation.Operation.RX:
			self.text += "X %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.RY:
			self.text += "Y %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.RZ:
			self.text += "Z %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.RH:
			self.text += "H %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.RS:
			self.text += "S %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.CX:
			self.text += "CNOT %s %s" % [grid.pos_to_idx(op.index), grid.pos_to_idx(op.other)]
		QubitOperation.Operation.CZ:
			self.text += "CZ %s %s" % [grid.pos_to_idx(op.index), grid.pos_to_idx(op.other)]
		QubitOperation.Operation.DELETE:
			self.text += "reset %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.ADD:
			self.text += "init %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.MZ:
			self.text += "measure %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.LABELA:
			self.text += "#label ancilla %s" % [grid.pos_to_idx(op.index)]
		QubitOperation.Operation.LABELD:
			self.text += "#label data %s" % [grid.pos_to_idx(op.index)]
	self.text += "\n"
