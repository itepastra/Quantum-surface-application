class_name Gate
extends Node3D

const DECAY_SPEED: float = 0.5

var intensity: float = 1.0


@onready var left: Sprite3D = get_node("Left") as Sprite3D
@onready var middle: Sprite3D = get_node("Middle") as Sprite3D
@onready var right: Sprite3D = get_node("Right") as Sprite3D

enum Type {
	CX,
	CZ
}

func setup(start: Vector3, end: Vector3, type: Type):
	# get the width of self
	
	var start_width: float = left.region_rect.size.x * left.pixel_size
	var mid_width: float = middle.region_rect.size.x * middle.pixel_size

	match type:
		Type.CX:
			pass
		Type.CZ:
			right.region_rect = left.region_rect
			right.rotate_object_local(Vector3.BACK, PI)

	var end_width: float = right.region_rect.size.x * right.pixel_size
	# get the target width
	var diff: Vector3 = end-start
	var target_width: float = (diff).length()

	# scale the texture
	var scale_factor: float = target_width/mid_width

	# transform
	var ndiff: Vector3 = diff.normalized()
	var average_vec: Vector3 = start + (diff)/2
	var angle: float = atan2(diff.y, diff.x)
	var spos: Vector3 = start + start_width/2 * ndiff
	left.rotate_object_local(Vector3.BACK, angle)
	left.position = spos
	middle.rotate_object_local(Vector3.BACK, angle)
	middle.position = average_vec
	middle.scale_object_local(Vector3(scale_factor, 1.0, 1.0))
	var epos: Vector3 = end - (start_width/2 * ndiff)
	right.rotate_object_local(Vector3.BACK, angle)
	right.position = epos

func _process(delta: float) -> void:
	if self.intensity < 0.01:
		self.queue_free()
	self.intensity = self.intensity * (1 - DECAY_SPEED) ** delta
	left.modulate.a = self.intensity
	middle.modulate.a = self.intensity
	right.modulate.a = self.intensity
