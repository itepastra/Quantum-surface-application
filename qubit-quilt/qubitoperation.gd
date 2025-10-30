class_name QubitOperation

var operation: Operation
var index: Vector2i # arrayindex of the operation
var other: Vector2i # only used with 2 qubit operations
var basis: int
var snap: Dictionary

var errors: Array[QubitOperation] = []

enum Operation {RX, RY, RZ, RH, RS, RSD, CX, CZ, DELETE, ADD, MZ, LABELA, LABELD}

func _init(operation: Operation, index: Vector2i, other: Vector2i = Vector2i(0,0), basis = 10):
	self.index = index
	self.other = other
	self.operation = operation
	self.basis = basis

func is_two_qubit() -> bool:
	return self.operation in [Operation.CX, Operation.CZ]

func print_op(indent: int = 0):
	print("%sOperation %d between %v and %v" % [" ".repeat(indent), self.operation, self.index, self.other])
	if self.errors.size() > 0:
		print("%sErrors:" % " ".repeat(indent))
		for e in errors:
			e.print_op(indent + 4)

static func _v2_to_arr(v: Vector2i) -> Array[int]:
	return [v.x, v.y]

static func _arr_to_v2(a: Array) -> Vector2i:
	if a.size() >= 2:
		return Vector2i(int(a[0]), int(a[1]))
	return Vector2i.ZERO

static func op_to_str(op: Operation) -> String:
	return Operation.keys()[int(op)]

static func op_from_str(s: String) -> Operation:
	var key := s.strip_edges()  # keep whitespace-tolerant
	# key must match an enum key exactly as declared
	assert(Operation.has(key), "QubitOperation: unknown operation '%s'. Allowed: %s" % [key, ", ".join(Operation.keys())])
	return Operation[key]

func to_dict() -> Dictionary:
	return {
		"operation": QubitOperation.op_to_str(self.operation),
		"index": _v2_to_arr(self.index),
		"other": _v2_to_arr(self.other),
	}

static func from_dict(d: Dictionary) -> QubitOperation:
	assert(d.has("operation"), "QubitOperation.from_dict: missing 'operation'")
	var op := QubitOperation.op_from_str(String(d["operation"]))
	var idx := _arr_to_v2(d.get("index", [0, 0]))
	var oth := _arr_to_v2(d.get("other", [0, 0]))
	return QubitOperation.new(op, idx, oth)
