class_name Qubit
extends StaticBody3D

@export var x_speed: float = 0.0
@export var y_speed: float = 0.0
@export var z_speed: float = 0.0


func _physics_process(delta: float) -> void:
	var x = deg_to_rad(x_speed * delta)
	var y = deg_to_rad(y_speed * delta)
	var z = deg_to_rad(z_speed * delta)

	# Apply local rotation
	self.rotate_object_local(Vector3.RIGHT, x)
	self.rotate_object_local(Vector3.UP, y)
	self.rotate_object_local(Vector3.BACK, z)
