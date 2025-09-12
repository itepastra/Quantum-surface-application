class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 1.5


@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

const qubit_size = 1

func _on_ready() -> void:
	# Resize the camera to fit with the grid
	var full_grid_size = Vector2(x_qubits * cell_size, y_qubits*cell_size)
	var camera: Camera3D = %Camera
	camera.size = max(full_grid_size.x, full_grid_size.y)*1.05
	# Dynamically change the keep_aspect of the camera to always fit the whole grid
	camera.keep_aspect = camera.KEEP_WIDTH if full_grid_size.x > full_grid_size.y else camera.KEEP_HEIGHT
	
	# initialize the qubits themselves
	for x in x_qubits:
		for y in y_qubits:
			var nextQubit: Qubit = qubit_scene.instantiate()
			nextQubit.name = "Qubit (%d, %d)" % [x,y]
			nextQubit.position.x = x - (x_qubits-1)/2.0
			nextQubit.position.y = y - (y_qubits-1)/2.0
			nextQubit.position *= cell_size
			nextQubit.x_speed = randf_range(-180, 180)
			nextQubit.y_speed = randf_range(-180, 180)
			nextQubit.z_speed = randf_range(-180, 180)
			self.add_child(nextQubit)
	
	# Initialize the horizontal connections
	for x in x_qubits-1:
		for y in y_qubits:
			var startx = (x - (x_qubits-1)/2.0) * cell_size + qubit_size
			var endx = (x +1 - (x_qubits-1)/2.0) * cell_size - qubit_size
			var gatey = (y - (y_qubits-1)/2.0) * cell_size
			var nextGate = gate_scene.instantiate()
			nextGate.setup(Vector2(startx, gatey), Vector2(endx, gatey))
			nextGate.name = "Gate (%d, %d) -> (%d, %d)" % [x,y,x+1,y]
			self.add_child(nextGate)

	# Initialize the vertical connections
	for x in x_qubits:
		for y in y_qubits-1:
			var starty = (y - (y_qubits-1)/2.0) * cell_size + qubit_size
			var endy = (y + 1 - (y_qubits-1)/2.0) * cell_size - qubit_size
			var gatex = (x - (x_qubits-1)/2.0) * cell_size
			var nextGate = gate_scene.instantiate()
			nextGate.setup(Vector2(gatex, starty), Vector2(gatex, endy))
			nextGate.name = "Gate (%d, %d) -> (%d, %d)" % [x,y,x+1,y]
			self.add_child(nextGate)
