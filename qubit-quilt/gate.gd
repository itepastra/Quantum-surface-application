class_name Gate
extends Sprite3D



static var self_scene: PackedScene;


func setup(start, end):
	# get the width of self
	var width = self.texture.get_width() * self.pixel_size

	# get the target width
	var target_width = (end-start).length()

	# scale the texture
	var scale_factor = target_width/width

	self.scale.x *= scale_factor
	self.scale.y *= scale_factor

	# transform
	var diff = end-start
	var average_vec = start + (diff)/2
	self.position.x = average_vec.x
	self.position.y = average_vec.y
	self.rotate_object_local(Vector3.BACK, atan2(diff.y, diff.x))
