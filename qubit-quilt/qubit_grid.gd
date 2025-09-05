class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 2.6

@onready var qubit_grid: Node3D = %QubitGrid

@export var qubit_scene: PackedScene

func _on_ready() -> void:
	# Resize the camera to fit with the grid
	var full_grid_size = Vector2(x_qubits * cell_size, y_qubits*cell_size)
	var camera: Camera3D = %Camera
	camera.size = max(full_grid_size.x, full_grid_size.y)*1.05
	# Dynamically change the keep_aspect of the camera to always fit the whole grid
	camera.keep_aspect = camera.KEEP_WIDTH if full_grid_size.x > full_grid_size.y else camera.KEEP_HEIGHT
	
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
			qubit_grid.add_child(nextQubit)
