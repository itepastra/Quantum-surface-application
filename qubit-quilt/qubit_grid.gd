class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 1.5


@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

const qubit_size = 1
var button_group: ButtonGroup

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
			self.add_child(nextQubit)


func _ready():
	var button = get_node("/root/Scene/HUD/Hotbar/X-90")
	button_group = button.button_group


func _on_input_event(_cam: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# the user clicked on the qubit
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# find the selected gate
		var pressed: Button = button_group.get_pressed_button()

		if pressed == null:
			return
		elif pressed.name == "CX":
			print("ADD CX GATE")
		elif pressed.name == "CZ":
			print("ADD CZ GATE")
		else:
			print(pressed.name)
			return  # Unknown button
		
