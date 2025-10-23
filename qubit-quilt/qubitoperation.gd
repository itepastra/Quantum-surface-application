class_name QubitOperation

var operation: Operation
var index: int # arrayindex of the operation
var other: int # only used with 2 qubit operations
var basis: int

enum Operation {RX, RY, RZ, RH, RS, RSD, CX, CZ, DELETE, ADD, MZ}

func _init(operation, index, other = -1, basis = 10):
	self.index = index
	self.other = other
	self.operation = operation
	self.basis = basis
