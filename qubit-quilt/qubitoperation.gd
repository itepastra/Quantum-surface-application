class_name QubitOperation

var operation: Operation
var index: int # arrayindex of the operation
var other: int # only used with 2 qubit operations
var basis: Basis

enum Operation {RX, RY, RZ, RH, RS, CX, CZ, DELETE, ADD}

func _init(operation, index, other = -1, basis = Basis.IDENTITY):
	self.index = index
	self.other = other
	self.operation = operation
	self.basis = basis
