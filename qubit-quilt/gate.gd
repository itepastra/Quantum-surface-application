class_name Gate
extends Sprite3D


static var scene = preload("res://qubit_gate.tscn")



static func create(start, end) -> Gate:
	var gate = scene.instantiate()
	# get the width of self
	var width = gate.texture.get_width() * gate.pixel_size

	# get the target width
	var target_width = (end-start).length()

	# scale the texture
	var scale_factor = target_width/width

	gate.scale.x *= scale_factor
	gate.scale.y *= scale_factor

	# transform
	var diff = end-start
	var average_vec = start + (diff)/2
	gate.position.x = average_vec.x
	gate.position.y = average_vec.y
	gate.rotate_object_local(Vector3.BACK, atan2(diff.y, diff.x))
	return gate
