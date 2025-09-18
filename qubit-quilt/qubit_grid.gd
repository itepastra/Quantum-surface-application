class_name QubitGrid
extends Node3D

@export var x_qubits: int = 8
@export var y_qubits: int = 4
@export var cell_size: float = 1.5


@export var qubit_scene: PackedScene
@export var gate_scene: PackedScene

@onready var cx_button = $B

const qubit_size = 1
var button_group: ButtonGroup
var two_qubit_mode: bool = false
var selected_qubits: Array[Qubit] = []
var two_qubit_gate_type: String = ""

var qec = Qec.new()

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
	# Connect to the CX button
	var cx_button = get_node("/root/Scene/HUD/Hotbar/CX")
	cx_button.connect("pressed", Callable(self, "_on_cx_button_pressed"))
	
	var cz_button = get_node("/root/Scene/HUD/Hotbar/CZ")
	cz_button.connect("pressed", Callable(self, "_on_cz_button_pressed"))
	
func _on_cx_button_pressed():
	two_qubit_gate_type = "CX"
	selected_qubits.clear()
	print("Select two qubits for CX gate")

func _on_cz_button_pressed():
	two_qubit_gate_type = "CZ"
	selected_qubits.clear()
	print("Select two qubits for CZ gate")

func _on_qubit_selected(qubit: Qubit):
	if two_qubit_gate_type != "" and qubit not in selected_qubits:
		selected_qubits.append(qubit)
		
		if selected_qubits.size() == 2:
			add_two_qubit_gate(selected_qubits[0], selected_qubits[1])
			selected_qubits.clear()
			two_qubit_gate_type = ""

func add_two_qubit_gate(qubit1: Qubit, qubit2: Qubit):
	# check qubits are nearest neighbors
	var pos1 = get_qubit_grid_position(qubit1)
	var pos2 = get_qubit_grid_position(qubit2)

	var dx = abs(pos1.x - pos2.x)
	var dy = abs(pos1.y - pos2.y)
	

	if (dx == 1 and dy == 0) or (dx == 0 and dy == 1):
		var gate_instance = gate_scene.instantiate()
		add_child(gate_instance)
		
		if dx == 1: # horizontal connection
			var x = min(pos1.x, pos2.x)
			var y = pos1.y
			var startx = (x - (x_qubits-1)/2.0) * cell_size + qubit_size
			var endx = (x + 1 - (x_qubits-1)/2.0) * cell_size - qubit_size
			var gatey = (y - (y_qubits-1)/2.0) * cell_size

			# flip the gate based on selection order
			var flip_horizontal = pos1.x < pos2.x
			if flip_horizontal:
				# swap start and end to flip the gate
				var temp = startx
				startx = endx
				endx = temp
			gate_instance.setup(Vector3(startx, gatey, 0), Vector3(endx, gatey, 0))
			
		else: # vertical connection
			var x = pos1.x
			var y = min(pos1.y, pos2.y)
			var gatex = (x - (x_qubits-1)/2.0) * cell_size
			var starty = (y - (y_qubits-1)/2.0) * cell_size + qubit_size
			var endy = (y + 1 - (y_qubits-1)/2.0) * cell_size - qubit_size

			# flip gate based on order
			var flip_vertical = pos1.y < pos2.y
			if flip_vertical:
				var temp = starty
				starty = endy
				endy = temp

			gate_instance.setup(Vector3(gatex, starty, 0), Vector3(gatex, endy, 0))
		
		# WIP, need module to work
		if two_qubit_gate_type == "CX":
			print("IMPLEMENT QEC CX")
			#qec.apply_cx(qubit1, qubit2)
		elif two_qubit_gate_type == "CZ":
			print("IMPLEMENT QEC CZ")
			#qec.apply_cz(qubit1, qubit2)
		
		print("Added %s gate between %s and %s" % [two_qubit_gate_type, qubit1.name, qubit2.name])
	else:
		print("Qubits are not adjacent. Cannot add gate.")
		selected_qubits.clear()
		two_qubit_gate_type = ""

func get_qubit_grid_position(qubit: Qubit) -> Vector2:
	# Calculate grid position
	var grid_x = round((qubit.position.x / cell_size) + (x_qubits - 1) / 2.0)
	var grid_y = round((qubit.position.y / cell_size) + (y_qubits - 1) / 2.0)
	return Vector2(grid_x, grid_y)
