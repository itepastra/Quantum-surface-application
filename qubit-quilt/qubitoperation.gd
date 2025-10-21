class_name QubitOperation

var operation: Operation
var index: Vector2i # arrayindex of the operation
var other: Vector2i # only used with 2 qubit operations
var basis: int

enum Operation {RX, RY, RZ, RH, RS, RSD, CX, CZ, DELETE, ADD, MZ, LABELA, LABELD}

func _init(operation: Operation, index: Vector2i, other: Vector2i = Vector2i(0,0), basis = 10):
	self.index = index
	self.other = other
	self.operation = operation
	self.basis = basis

func is_two_qubit() -> bool:
	return self.operation in [Operation.CX, Operation.CZ]
